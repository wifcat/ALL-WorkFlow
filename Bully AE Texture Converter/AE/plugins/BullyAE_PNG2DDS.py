from PIL import Image
import subprocess, os, sys

def png2dds(input_file, format="bc3"):
    im = Image.open(input_file).convert("RGBA")
    im = im.transpose(Image.FLIP_TOP_BOTTOM)
    temp_file = os.path.splitext(input_file)[0] + "_tmp.png"
    im.save(temp_file)


    output_file = os.path.splitext(input_file)[0] + ".dds"

    subprocess.run([
        "quicktex", "encode", format, temp_file, "-o", output_file
    ], check=True)

    os.remove(temp_file)
    print(f"{input_file} > {output_file} ({format}) [successfully converted]")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python BullyAE_PNG2DDS.py <file.png|jpg> [bc1|bc2|bc3|bc4|bc5]")
    else:
        input_file = sys.argv[1]
        format = sys.argv[2] if len(sys.argv) > 2 else "bc3"
        png2dds(input_file, format)