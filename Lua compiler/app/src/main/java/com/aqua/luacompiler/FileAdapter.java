package com.aqua.luacompiler;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.util.List;

public class FileAdapter extends RecyclerView.Adapter<FileAdapter.VH> {
    private final List<String> files;
    public FileAdapter(List<String> files) { this.files = files; }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_file, parent, false);
        return new VH(v);
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        String path = files.get(position);
        holder.tvName.setText(path.substring(path.lastIndexOf('/') + 1));
        holder.tvPath.setText(path);
    }

    @Override public int getItemCount() { return files.size(); }

    static class VH extends RecyclerView.ViewHolder {
        TextView tvName, tvPath;
        VH(View v) {
            super(v);
            tvName = v.findViewById(R.id.tvName);
            tvPath = v.findViewById(R.id.tvPath);
        }
    }
}
