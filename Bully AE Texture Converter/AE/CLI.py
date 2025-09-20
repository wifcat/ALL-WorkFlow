#!/usr/bin/env python3
# A small cli used for converting textures with python plugins (dds2tex, tex2png)
# Written by aqua (@aqxua)
# Github: wifcat
# my discord server: https://discord.gg/v2GG2xhZ
# Usage if you dont have the packages: python install.py
# UPDATE 8/9/25 - pvr fix with tex2ddecoder
# UPDATE 19/9/25 - New! CLI Update for Settings output
# python install2.py

import os
import subprocess
import shutil
import sys
import json

# ----------------------------
# Paths and settings handling
# ----------------------------
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SETTINGS_FILE = os.path.join(SCRIPT_DIR, ".cli_settings.json")

DEFAULT_SETTINGS = {
    "output_mode": 1,
    "converted_prefix": "Converted_"
}

def load_settings():
    try:
        if os.path.isfile(SETTINGS_FILE):
            with open(SETTINGS_FILE, "r", encoding="utf-8") as f:
                s = json.load(f)
            for k, v in DEFAULT_SETTINGS.items():
                if k not in s:
                    s[k] = v
            return s
    except Exception:
        pass
    return DEFAULT_SETTINGS.copy()

def save_settings(s):
    try:
        with open(SETTINGS_FILE, "w", encoding="utf-8") as f:
            json.dump(s, f, indent=2)
    except Exception as e:
        print(f"[Warn] Failed to save settings: {e}")

SETTINGS = load_settings()

PLUGIN_DIR = os.path.join(SCRIPT_DIR, "plugins")
os.makedirs(PLUGIN_DIR, exist_ok=True)

def get_plugin(name):
    p1 = os.path.join(PLUGIN_DIR, name)
    if os.path.isfile(p1):
        return p1
    p2 = os.path.join(SCRIPT_DIR, name)
    if os.path.isfile(p2):
        return p2

    print(f"[Warn] Plugins {name} not found in {PLUGIN_DIR} or {SCRIPT_DIR}; trying '{name}' from path")
    return name

def get_base_output_path():
    mode = int(SETTINGS.get("output_mode", 1))
    if mode == 1:
        return os.path.join(SCRIPT_DIR, "output")
    elif mode == 2:
        # each conversion uses folder name directly next to cli.py
        return SCRIPT_DIR
    elif mode == 3:
        # single folder for all (no subfolders)
        return os.path.join(SCRIPT_DIR, "output")
    else:  # mode == 4
        # single folder next to cli.py, everything in SCRIPT_DIR
        return SCRIPT_DIR

def apply_converted_prefix(name):
    mode = int(SETTINGS.get("output_mode", 1))
    if mode == 4:
        prefix = SETTINGS.get("converted_prefix", "Converted_")
        return prefix + name
    return name

def makedir(subfolder=None):
    base = get_base_output_path()
    mode = int(SETTINGS.get("output_mode", 1))

    if mode == 1:
        # output/<subfolder>
        path = os.path.join(base, subfolder) if subfolder else base
    elif mode == 2:
        # <subfolder> next to cli.py (no top-level 'output')
        path = os.path.join(base, subfolder) if subfolder else base
    elif mode == 3:
        # mode 3: everything in single folder (no subfolders)
        path = base  # ignore subfolder
    else:
        # mode 4: everything in SCRIPT_DIR (no subfolders)
        path = base
    os.makedirs(path, exist_ok=True)
    return path

def get_output_preview(subfolder=None):
    base = get_base_output_path()
    mode = int(SETTINGS.get("output_mode", 1))
    if mode in (1,2):
        return os.path.join(base, subfolder) if subfolder else base
    else:
        return base

def run_tex2dds(tex_file, output_sub=None):
    if output_sub is None:
        output_sub = "tex2png"
    base_name = os.path.splitext(os.path.basename(tex_file))[0]
    out_folder = makedir(output_sub)
 
    out_base_name = apply_converted_prefix(base_name)
    out_base = os.path.join(out_folder, out_base_name)

    dds_file = out_base + ".dds"
    # Skip if DDS already exists at destination
    if os.path.exists(dds_file):
        print(f"[Skip] {dds_file} already exists, skipping TEX->DDS conversion.")
        return dds_file

    plugin = get_plugin("BullyAE_TEX2DDS.py")
    cmd = [sys.executable, plugin, tex_file, out_base, "--png"]

    print("Running:", " ".join(cmd))
    subprocess.run(cmd, check=True)

    return dds_file


def run_dds2png(dds_file, output_sub=None):
    if output_sub is None:
        output_sub = "tex2png"

    base_name = os.path.splitext(os.path.basename(dds_file))[0]
    folder = os.path.dirname(dds_file) or "."

    out_folder = makedir(output_sub)
    final_png_name = apply_converted_prefix(base_name) + ".png"
    final_png = os.path.join(out_folder, final_png_name)

    # Skip if final PNG already exists
    if os.path.exists(final_png):
        print(f"[Skip] {final_png} already exists, skipping DDS->PNG conversion.")
        if output_sub == "tex2png" and os.path.exists(dds_file):
            try:
                os.remove(dds_file)
                print(f"Removed temporary DDS: {dds_file}")
            except Exception as e:
                print(f"[Warn] Failed to remove {dds_file}: {e}")
        return final_png

    plugin = get_plugin("BullyAE_DDS2PNG.py")
    cmd = [sys.executable, plugin, dds_file]
    print("Running:", " ".join(cmd))
    subprocess.run(cmd, check=True)
    temp_png = os.path.join(folder, base_name + ".png")
    abs_temp = os.path.abspath(temp_png)
    abs_final = os.path.abspath(final_png)
    if abs_temp == abs_final:
        if os.path.exists(temp_png):
            print(f"[Info] Temp PNG already at final location: {final_png}")
        else:
            print(f"[Warn] Expected PNG not found at {temp_png}")
    else:
        if os.path.exists(temp_png):
            try:
                os.makedirs(os.path.dirname(final_png), exist_ok=True)
                shutil.move(temp_png, final_png)
                print(f"Moved PNG: {temp_png} -> {final_png}")
            except Exception as e:
                try:
                    shutil.copy(temp_png, final_png)
                    print(f"Copied PNG: {temp_png} -> {final_png} (fallback)")
                except Exception as e2:
                    print(f"[Warn] Failed to move/copy PNG: {e2}")
        else:
            print(f"[Warn] Expected PNG not found at {temp_png}")
    if output_sub == "tex2png" and os.path.exists(dds_file):
        try:
            os.remove(dds_file)
            print(f"Removed temporary DDS: {dds_file}")
        except Exception as e:
            print(f"[Warn] Failed to remove {dds_file}: {e}")
    return final_png

def run_dds2tex(dds_file, use_flag=False, output_sub=None):
    if output_sub is None:
        output_sub = "dds2tex"

    base_tex = os.path.join(PLUGIN_DIR, "base.tex")
    base_name = os.path.splitext(os.path.basename(dds_file))[0]
    out_folder = makedir(output_sub)
    final_name = apply_converted_prefix(base_name) + ".tex"
    final_tex = os.path.join(out_folder, final_name)

    # Skip if TEX already exists
    if os.path.exists(final_tex):
        print(f"[Skip] {final_tex} already exists, skipping DDS->TEX conversion.")
        return final_tex

    plugin = get_plugin("BullyAE_DDS2TEX.py")
    cmd = [sys.executable, plugin, "-i", dds_file, "-o", base_tex]
    if use_flag:
        cmd.append("-c")
    print("Running:", " ".join(cmd))
    subprocess.run(cmd, check=True)

    if os.path.exists(base_tex):
        shutil.copy(base_tex, final_tex)
        print(f"Saved TEX to: {final_tex}")
    else:
        print(f"[Warn] base.tex not found after conversion at {base_tex}")
    return final_tex
    

def run_png2dds(png_file, output_sub=None):
    if output_sub is None:
        output_sub = "png2dds"

    base_name = os.path.splitext(os.path.basename(png_file))[0]
    out_folder = makedir(output_sub)
    dds_name = apply_converted_prefix(base_name) + ".dds"
    dds_file = os.path.join(out_folder, dds_name)

    # Skip if DDS already exists
    if os.path.exists(dds_file):
        print(f"[Skip] {dds_file} already exists, skipping PNG->DDS conversion.")
        return dds_file

    png_folder = os.path.dirname(os.path.abspath(png_file)) or "."
    plugin = get_plugin("BullyAE_PNG2DDS.py")
    cmd = [sys.executable, plugin, os.path.abspath(png_file)]
    print("Running:", " ".join(cmd), " (cwd:", png_folder, ")")
    subprocess.run(cmd, check=True, cwd=png_folder)
    keys = ["", "temp_", "flipped_"]
    candidates = []
    for p in keys:
        candidates.append(os.path.join(png_folder, p + base_name + ".dds"))
    cli_cwd = os.getcwd()
    for p in keys:
        candidates.append(os.path.join(cli_cwd, p + base_name + ".dds"))
    found = None
    for path in candidates:
        if os.path.exists(path):
            found = path
            break
    if found:
        if os.path.exists(dds_file):
            os.remove(dds_file)
        shutil.move(found, dds_file)
        print(f"Moved DDS: {found} -> {dds_file}")
    else:
        print(f"[Warn] DDS not found. Checked candidates:\n" + "\n".join(candidates))
    return dds_file


def batch_convert(extension, func, output_sub=None, **kwargs):
    if isinstance(extension, str):
        files = [f for f in os.listdir(".") if f.lower().endswith(extension)]
    else:
        files = [f for f in os.listdir(".") if f.lower().endswith(tuple(extension))]
    if not files:
        print(f"No {extension} files found for batch conversion!")
        return
    for f in files:
        input_path = os.path.abspath(f)
        print(f"\nProcessing {f} ...")
        func(input_path, output_sub=output_sub, **kwargs)

def batch_tex2png():
    tex_files = [f for f in os.listdir(".") if f.lower().endswith(".tex")]
    if not tex_files:
        print("No TEX files found for batch conversion!")
        return
    for f in tex_files:
        print(f"\nProcessing {f} ...")
        dds_file = run_tex2dds(f, output_sub="tex2png")
        png_file = run_dds2png(dds_file, output_sub="tex2png")
        if os.path.exists(dds_file):
            os.remove(dds_file)

def settings_menu():
    while True:
        current = int(SETTINGS.get("output_mode", 1))
        print("\n╔════════════════════════════════════════════════════════════╗")
        print("║                              SETTINGS                      ║")
        print("╠════════════════════════════════════════════════════════════╣")
        print("║ 1. Default (Output & Subfolders)                           ║")
        print("║ 2. Subfolders (Conversion name folder no Output)           ║")
        print("║ 3. Single (no subfolders but inside Output)                ║")
        print("║ 4. Single next to CLI.py (but all output 'Converted_')     ║")
        print("║ 5. Show current settings file location                     ║")
        print("║ 6. Back                                                    ║")
        print("╠════════════════════════════════════════════════════════════╣")
        print("║ Output mode (current: {}):                                  ║".format(current))
        print("╚════════════════════════════════════════════════════════════╝")
        print("")
        choice = input("Choose option (1/2/3/4/5/6): ").strip()
        if choice in ("1","2","3","4"):
            SETTINGS["output_mode"] = int(choice)
            save_settings(SETTINGS)
            print(f"[Info] Saved output_mode = {choice} to {SETTINGS_FILE}")
        elif choice == "5":
            print(f"Settings file: {SETTINGS_FILE}")
            print(json.dumps(SETTINGS, indent=2))
        elif choice == "6":
            break
        else:
            print("Invalid choice!")


def main():
    os.makedirs(PLUGIN_DIR, exist_ok=True)
    makedir()  
    while True:
        print("╔══════════════════════════════════╗")
        print("║      BULLY AE TEXTURE CONVERTER  ║")
        print("╠══════════════════════════════════╣")
        print("║ 0. Settings                      ║")
        print("║ 1. TEX → PNG (manual)            ║")
        print("║ 2. DDS → TEX (manual)            ║")
        print("║ 3. PNG → DDS (manual)            ║")
        print("║ 4. DDS → PNG (manual)            ║")
        print("║ 5. Batch conversion              ║")
        print("║ 6. Exit                          ║")
        print("╚══════════════════════════════════╝")

        print("")
        choice = input("Choose option (0/1/2/3/4/5/6): ").strip()
        if choice == "0":
            settings_menu()
        elif choice == "1":
            tex_file = input("Enter .tex file: ").strip()
            if not os.path.isfile(tex_file):
                print("Error: File not found!")
            else:
                dds_file = run_tex2dds(tex_file)
                run_dds2png(dds_file, output_sub="tex2png")
                print(f"Saved output in: {get_output_preview('tex2png')}")
                if int(SETTINGS.get("output_mode",1)) == 4:
                    print(f"All filenames in this folder will be prefixed with '{SETTINGS.get('converted_prefix')}'")
        elif choice == "2":
            dds_file = input("Enter .dds file: ").strip()
            if not os.path.isfile(dds_file):
                print("Error: File not found!")
            else:
                use_flag = input("Use -c (compress zlib) flag? (y/n): ").strip().lower() == "y"
                final_tex = run_dds2tex(dds_file, use_flag, output_sub="dds2tex")
                print(f"Saved output in: {get_output_preview('dds2tex')}")
                if int(SETTINGS.get("output_mode",1)) == 4:
                    print(f"All filenames in this folder will be prefixed with '{SETTINGS.get('converted_prefix')}'")
        elif choice == "3":
            png_file = input("Enter .png/.jpg file: ").strip()
            if not os.path.isfile(png_file):
                print("Error: File not found!")
            else:
                run_png2dds(png_file, output_sub="png2dds")
                print(f"Saved output in: {get_output_preview('png2dds')}")
                if int(SETTINGS.get("output_mode",1)) == 4:
                    print(f"All filenames in this folder will be prefixed with '{SETTINGS.get('converted_prefix')}'")
        elif choice == "4":
            dds_file = input("Enter .dds file: ").strip()
            if not os.path.isfile(dds_file):
                print("Error: File not found!")
            else:
                run_dds2png(dds_file, output_sub="dds2png")
                print(f"Saved output in: {get_output_preview('dds2png')}")
                if int(SETTINGS.get("output_mode",1)) == 4:
                    print(f"All filenames in this folder will be prefixed with '{SETTINGS.get('converted_prefix')}'")
        elif choice == "5":
            print("\n╔════════════════════════════════════════════════════════════╗")
            print("║                  BATCH CONVERSION                          ║")
            print("╠════════════════════════════════════════════════════════════╣")
            print("║ 1. All TEX → PNG                                           ║")
            print("║ 2. All PNG → DDS                                           ║")
            print("║ 3. All DDS → TEX                                           ║")
            print("║ 4. All DDS → PNG                                           ║")
            print("╚════════════════════════════════════════════════════════════╝")

            print("")
            batch_choice = input("Choose batch option (1/2/3/4): ").strip().lower()
            if batch_choice == "1":
                batch_tex2png()
            elif batch_choice == "2":
                batch_convert((".png", ".jpg"), run_png2dds, output_sub="png2dds")
            elif batch_choice == "3":
                use_flag = input("Use -c (compress zlib) flag for all? (y/n): ").strip().lower() == "y"
                batch_convert(".dds", run_dds2tex, output_sub="dds2tex", use_flag=use_flag)
            elif batch_choice == "4":
                batch_convert(".dds", run_dds2png, output_sub="dds2png")
            else:
                print("Invalid batch choice!")
        elif choice == "6":
            print("Thank u for using this tool")
            print("tool made by @aqxua on yt\n")
            break
        else:
            print("Invalid choice!")

if __name__ == "__main__":
    main()
                  
