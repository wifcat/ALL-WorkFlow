package com.aqua.luacompiler;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.Settings;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.appbar.MaterialToolbar;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.checkbox.MaterialCheckBox;
import com.google.android.material.progressindicator.LinearProgressIndicator;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MainActivity extends AppCompatActivity {
    private static final String TAG = "MainActivity";
    private static final int REQ_PERMS = 1000;

    static {
        System.loadLibrary("lua");
        System.loadLibrary("luac");
        System.loadLibrary("luac_jni");
    }

    // JNI native: pastikan signature ini sesuai dengan JNI C kamu
    public native int compileLua(String inputPath, String outputPath, boolean strip);

    private final List<String> picked = new ArrayList<>();
    private FileAdapter adapter;
    private final ExecutorService exec = Executors.newSingleThreadExecutor();

    private ActivityResultLauncher<String[]> pickMultiple;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // toolbar
        MaterialToolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        // PERMISSION: jika Android >= R, minta All Files Access (user harus konfirmasi di Settings)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            if (!Environment.isExternalStorageManager()) {
                // buka layar Settings untuk All Files Access
                Intent intent = new Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION);
                intent.setData(Uri.parse("package:" + getPackageName()));
                startActivity(intent);
                Toast.makeText(this, "Please grant All Files Access for writing to /storage/emulated/0", Toast.LENGTH_LONG).show();
            }
        } else {
            // Android < R: pastikan runtime permission READ/WRITE
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED ||
                    ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this,
                        new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE},
                        REQ_PERMS);
            }
        }

        // views (harus setelah setContentView)
        MaterialCheckBox checkboxStrip = findViewById(R.id.stripDebug);
        RecyclerView rv = findViewById(R.id.recycler);
        adapter = new FileAdapter(picked);
        rv.setLayoutManager(new LinearLayoutManager(this));
        rv.setAdapter(adapter);

        MaterialButton btnPick = findViewById(R.id.btnPick);
        MaterialButton btnCompile = findViewById(R.id.btnCompile);
        // gunakan LinearProgressIndicator sesuai XML modernmu
        LinearProgressIndicator progress = findViewById(R.id.progress);

        // Multiple pick: using ACTION_OPEN_DOCUMENT with multiple URIs
        pickMultiple = registerForActivityResult(
                new ActivityResultContracts.OpenMultipleDocuments(),
                uris -> {
                    if (uris == null || uris.isEmpty()) return;
                    picked.clear();
                    for (Uri u : uris) {
                        String saved = copyToCache(u);
                        if (saved != null) picked.add(saved);
                    }
                    adapter.notifyDataSetChanged();
                    Toast.makeText(this, "Selected: " + picked.size() + " file", Toast.LENGTH_SHORT).show();
                });

        btnPick.setOnClickListener(v -> {
            // accept any type but recommend text/* or */*
            pickMultiple.launch(new String[]{"*/*"});
        });

        btnCompile.setOnClickListener(v -> {
            if (picked.isEmpty()) {
                Toast.makeText(this, "No file .lua selected.. ", Toast.LENGTH_SHORT).show();
                return;
            }

            // disable UI
            btnPick.setEnabled(false);
            btnCompile.setEnabled(false);
            progress.setVisibility(View.VISIBLE);
            progress.setIndeterminate(false);
            progress.setMax(picked.size());
            progress.setProgress(0);

            // Prepare output directory once (try root /storage/emulated/0/LuaCompiled first)
            File externalOutDir = null;
            try {
                boolean allowedRoot = false;
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    allowedRoot = Environment.isExternalStorageManager();
                } else {
                    // for < R check WRITE permission
                    allowedRoot = ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED;
                }

                if (allowedRoot) {
                    File sdRoot = Environment.getExternalStorageDirectory(); // /storage/emulated/0
                    File candidate = new File(sdRoot, "LuaCompiled");
                    if (!candidate.exists()) {
                        if (!candidate.mkdirs()) {
                            Log.w(TAG, "mkdirs failed on /storage root, fallback later");
                            candidate = null;
                        }
                    }
                    externalOutDir = candidate;
                }

                // if couldn't use root, try app external files dir
                if (externalOutDir == null) {
                    File appExternal = getExternalFilesDir("LuaCompiled");
                    if (appExternal != null && !appExternal.exists()) {
                        appExternal.mkdirs();
                    }
                    externalOutDir = appExternal;
                }

                // final fallback to cache
                if (externalOutDir == null) {
                    externalOutDir = getCacheDir();
                }

                final File finalOutDir = externalOutDir;
                Log.i(TAG, "Using output dir: " + finalOutDir.getAbsolutePath());
                if (Environment.getExternalStorageDirectory() != null && finalOutDir.getAbsolutePath().startsWith(Environment.getExternalStorageDirectory().getAbsolutePath())) {
                    // If we are not writing to root and user wanted root, show info
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && !Environment.isExternalStorageManager()) {
                        runOnUiThread(() -> Toast.makeText(MainActivity.this,
                                "Not allowed to write to /storage/emulated/0 — saving to: " + finalOutDir.getAbsolutePath(),
                                Toast.LENGTH_LONG).show());
                    }
                }
            } catch (Exception e) {
                Log.w(TAG, "Failed to prepare externalOutDir", e);
                externalOutDir = getCacheDir();
            }

            File outDir = new File(getExternalFilesDir(null), "LuaCompiled");
            if (!outDir.exists()) outDir.mkdirs();
            Log.i(TAG, "Using output dir: " + outDir.getAbsolutePath());


                exec.submit(() -> {
                    int successCount = 0;

                    for (int i = 0; i < picked.size(); i++) {
                        String cachePath = picked.get(i); // file di cache
                        File inFile = new File(cachePath);
                        Log.i(TAG, "Preparing compile for: " + cachePath);

                        // 1) cek input file ada dan readable
                        if (!inFile.exists() || !inFile.canRead()) {
                            final String msg = "Input missing or unreadable: " + cachePath;
                            Log.w(TAG, msg);
                            runOnUiThread(() -> Toast.makeText(MainActivity.this, msg, Toast.LENGTH_LONG).show());
                            continue;
                        }

                        // basename
                        String base = inFile.getName();
                        int dot = base.lastIndexOf('.');
                        if (dot > 0) base = base.substring(0, dot);

                        // 2) buat output pada parent folder dari input (sesuai request kamu)
                        File outFile = new File(outDir, base + ".luac");
                        String outPath = outFile.getAbsolutePath();


                        // pastikan parent writable (biasanya cache parent pasti writable)
                        File parent = outFile.getParentFile();
                        if (!parent.exists()) {
                            if (!parent.mkdirs()) {
                                final String msg = "Cannot create output parent: " + parent.getAbsolutePath();
                                Log.w(TAG, msg);
                                runOnUiThread(() -> Toast.makeText(MainActivity.this, msg, Toast.LENGTH_LONG).show());
                                continue;
                            }
                        }
                        if (!parent.canWrite()) {
                            final String msg = "Cannot write to output folder: " + parent.getAbsolutePath();
                            Log.w(TAG, msg);
                            runOnUiThread(() -> Toast.makeText(MainActivity.this, msg, Toast.LENGTH_LONG).show());
                            continue;
                        }

                        // jika file out sudah ada, hapus dulu (untuk memastikan file baru dibuat)
                        if (outFile.exists()) {
                            boolean deleted = outFile.delete();
                            Log.i(TAG, "Deleting existing outFile: " + outFile.getAbsolutePath() + " -> " + deleted);
                        }

                        // baca checkbox
                        boolean strip = checkboxStrip.isChecked();

                        // LOG sebelum panggil native
                        Log.i(TAG, "Calling native compileLua() -> in: " + inFile.getAbsolutePath() + " out: " + outPath + " strip: " + strip);

                        int res;
                        try {
                            res = compileLua(inFile.getAbsolutePath(), outPath, strip);
                        } catch (Throwable t) {
                            Log.e(TAG, "compileLua threw exception", t);
                            res = -1;
                        }

                        // cek file out hasilnya
                        boolean outExists = new File(outPath).exists();

                        if (res == 0 && outExists) {
                            successCount++;
                            String okMsg = "Compiled OK: " + outPath;
                            Log.i(TAG, okMsg);
                            runOnUiThread(() -> Toast.makeText(MainActivity.this, okMsg, Toast.LENGTH_SHORT).show());
                        } else {
                            String failMsg = "Compile failed (res=" + res + ") in=" + cachePath + " outExists=" + outExists;
                            Log.w(TAG, failMsg);
                            runOnUiThread(() -> Toast.makeText(MainActivity.this, failMsg, Toast.LENGTH_LONG).show());
                        }

                        final int prog = i + 1;
                        runOnUiThread(() -> progress.setProgress(prog));
                    }

                    final int sc = successCount;
                    runOnUiThread(() -> {
                        btnPick.setEnabled(true);
                        btnCompile.setEnabled(true);
                        progress.setVisibility(View.GONE);
                        Toast.makeText(MainActivity.this,
                                "Done compiling: " + sc + "/" + picked.size() + " Success",
                                Toast.LENGTH_LONG).show();
                    });
                });
            });
 
    }

    // helper: copy content URI to cache to get real path for native .so usage
    private String copyToCache(Uri uri) {
        try {
            InputStream in = getContentResolver().openInputStream(uri);
            String name = "input.lua";
            try (android.database.Cursor c = getContentResolver()
                    .query(uri, null, null, null, null)) {
                if (c != null && c.moveToFirst()) {
                    int idx = c.getColumnIndex(android.provider.OpenableColumns.DISPLAY_NAME);
                    if (idx != -1) name = c.getString(idx);
                }
            }
            File file = new File(getCacheDir(), name);
            try (FileOutputStream out = new FileOutputStream(file)) {
                byte[] buf = new byte[4096];
                int len;
                while ((len = in.read(buf)) > 0) out.write(buf, 0, len);
            }
            if (in != null) in.close();
            return file.getAbsolutePath();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
