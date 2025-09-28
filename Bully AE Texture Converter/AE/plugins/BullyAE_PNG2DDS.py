# this is using the quicktex

from PIL import Image
import subprocess, os, sys

def png2dds(input_file, format="bc1"):
    # flip PNG
    im = Image.open(input_file)
    im = im.transpose(Image.FLIP_TOP_BOTTOM)
    temp_file = "temp_" + os.path.basename(input_file)
    im.save(temp_file)


    output_file = os.path.splitext(input_file)[0] + ".dds"
    subprocess.run([
        "quicktex", "encode", format, temp_file,
    ], check=True)

    os.remove(temp_file)
    print(f"{input_file} > {output_file} ({format}) [succesfully converted]")

if __name__ == "__main__":
    if len(sys.argv)<2:
        print("Usage: python BullyAE_PNG2DDS.py <file.png> [bc1|bc2|bc3|bc4|bc5]")
    else:
        input_file = sys.argv[1]
        format = sys.argv[2] if len(sys.argv)>2 else "bc1"
        png2dds(input_file, format)
        
