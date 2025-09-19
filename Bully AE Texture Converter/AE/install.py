# UPDATE 8/9/25 - pvr fix with tex2ddecoder

import subprocess
import sys
packages = ["Pillow", "imageio", "quicktex", "texture2ddecoder"]

for package in packages:
    try:
        print(f"Installing {package}...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])
    except subprocess.CalledProcessError:
        print(f"Failed to install {package}, skipping...")
print("All packages installed successfully!")
print("Run operation: python cli.py")
