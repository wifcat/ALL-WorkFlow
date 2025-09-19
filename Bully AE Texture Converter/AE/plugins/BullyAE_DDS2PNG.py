# dds to PNG
# Output file will have the same name as input but with .png extension.
# written by @aqxua (aqua)
import sys
import os
from PIL import Image

def dds2png(dds_path):
    try:
        base, _ = os.path.splitext(dds_path)
        png_path = base + ".png"
        img = Image.open(dds_path)

        img.save(png_path, "PNG")
        print(f"Successfully converted '{dds_path}' to '{png_path}'")
    except FileNotFoundError:
        print(f"Error: DDS file not found at '{dds_path}'")
    except Exception as e:
        print(f"An error occurred during conversion: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python dds2png.py <file.dds>")
    else:
        dds2png(sys.argv[1])
