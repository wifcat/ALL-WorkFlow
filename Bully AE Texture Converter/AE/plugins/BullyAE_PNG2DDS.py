from PIL import Image
import subprocess, os, sys
import shutil

def png2dds(input_file, format="bc3"): 
    im = Image.open(input_file).convert("RGBA")
    im = im.transpose(Image.FLIP_TOP_BOTTOM)
    base_temp = "temp_" + os.path.splitext(os.path.basename(input_file))[0]
    temp_file = base_temp + ".png"
    im.save(temp_file, "PNG")
    try:
        subprocess.run(["quicktex", "encode", format, temp_file], check=True)
    except subprocess.CalledProcessError as e:
      
        if os.path.exists(temp_file):
            os.remove(temp_file)
        print(f"[Err] quicktex failed (returncode={e.returncode})")
        raise
    expected_dds_from_temp = base_temp + ".dds"
    desired_dds = os.path.splitext(input_file)[0] + ".dds"
    if os.path.exists(expected_dds_from_temp):
        if os.path.exists(desired_dds):
            os.remove(desired_dds)
        shutil.move(expected_dds_from_temp, desired_dds)
    else:
        dds_candidates = [f for f in os.listdir(".") if f.lower().endswith(".dds")]
        if dds_candidates:
            newest = max(dds_candidates, key=lambda f: os.path.getmtime(f))
            if os.path.abspath(newest) != os.path.abspath(desired_dds):
                if os.path.exists(desired_dds):
                    os.remove(desired_dds)
                shutil.move(newest, desired_dds)
        else:
            print("[Warn] .dds output not found")

    if os.path.exists(temp_file):
        os.remove(temp_file)

    print(f"{input_file} > {desired_dds} ({format}) [successfully converted]")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python BullyAE_PNG2DDS.py <file.png> [bc1|bc2|bc3|bc4|bc5]")
    else:
        input_file = sys.argv[1]
        format = sys.argv[2] if len(sys.argv) > 2 else "bc3"
        png2dds(input_file, format)
