#!/usr/bin/env python3
# UPDATE 8/9/25 - pvr fix with tex2ddecoder
import struct, os, sys, argparse, zlib, re

try:
    from PIL import Image
except Exception:
    Image = None


def read_u32(f):
    b = f.read(4)
    if len(b) != 4:
        raise EOFError("Unexpected EOF")
    return struct.unpack("<I", b)[0]

def clamp(v, lo, hi):
    return max(lo, min(hi, v))

def try_zlib_prefix_len_blob(raw):

    if len(raw) < 5:
        return raw, False
    orig_len = struct.unpack_from("<I", raw, 0)[0]
    comp = raw[4:]
    try:
        dec = zlib.decompress(comp)
        if len(dec) == orig_len:
            return dec, True
    except Exception:
        pass
    return raw, False

def _bgra_to_rgba(bgra_bytes):
    # Convert BGRA TO RGBA
    ln = len(bgra_bytes)
    out = bytearray(ln)
    for i in range(0, ln, 4):
        b = bgra_bytes[i]
        g = bgra_bytes[i+1]
        r = bgra_bytes[i+2]
        a = bgra_bytes[i+3]
        out[i]   = r
        out[i+1] = g
        out[i+2] = b
        out[i+3] = a
    return bytes(out)

def decode_pvrtc_blob(blob, w, h, is2bpp=True):
    try:
        import texture2ddecoder
        bgra = texture2ddecoder.decode_pvrtc(blob, w, h, bool(is2bpp))
        if bgra is None:
            raise RuntimeError("texture2ddecoder.decode_pvrtc returned None")
        if len(bgra) < w*h*4:
            raise RuntimeError("texture2ddecoder returned unexpected size")
        return _bgra_to_rgba(bgra[:w*h*4])
    except Exception:
        pass
    raise RuntimeError(
        "No PVRTC decoder found. Install a Python package that can decode PVRTC (e.g. 'tex2img' or 'texture2ddecoder').\n"
        "On Android/pydroid, try: pip install tex2img\n"
        "If you can't install packages, fallback remains: the script will save raw .pvr files.\n"
        "Reference: PVRTC decoding is non-trivial (PowerVR formats PVRTC/PVRTC2)."
    )

def create_dds_header(width, height, mips, fourcc=None, rgb_bitcount=32,
                      r_mask=0x00FF0000, g_mask=0x0000FF00, b_mask=0x000000FF, a_mask=0xFF000000,
                      luminance=False):
    DDS_MAGIC = b"DDS "
    size = 124
    flags = 0x0002100F  
    caps1 = 0x1000
    caps2 = 0
    if mips and mips > 1:
        caps1 |= 0x8 | 0x400000  
    pitch_or_linear = 0

    h = bytearray()
    h += DDS_MAGIC
    h += struct.pack("<I", size)
    h += struct.pack("<I", flags)
    h += struct.pack("<I", height)
    h += struct.pack("<I", width)
    h += struct.pack("<I", pitch_or_linear)
    h += struct.pack("<I", 0)
    h += struct.pack("<I", mips if mips > 0 else 1)
    h += b"\x00"*44


    pf_size = 32
    if fourcc:
        pf_flags = 0x4
        pf_fourcc = fourcc
        pf_rgbbitcount = 0
        pf_r = pf_g = pf_b = pf_a = 0
    else:

        pf_fourcc = b"\x00"*4
        pf_rgbbitcount = rgb_bitcount
        if luminance:

            pf_flags = 0x20000

            pf_r = 0x000000FF
            pf_g = 0
            pf_b = 0
            pf_a = 0
        else:
            pf_flags = 0x40  
            pf_r = r_mask; pf_g = g_mask; pf_b = b_mask; pf_a = a_mask
            if a_mask:
                pf_flags |= 0x1 

    h += struct.pack("<I", pf_size)
    h += struct.pack("<I", pf_flags)
    h += pf_fourcc
    h += struct.pack("<I", pf_rgbbitcount)
    h += struct.pack("<I", pf_r)
    h += struct.pack("<I", pf_g)
    h += struct.pack("<I", pf_b)
    h += struct.pack("<I", pf_a)

    h += struct.pack("<I", caps1)
    h += struct.pack("<I", caps2)
    h += struct.pack("<I", 0)
    h += struct.pack("<I", 0)
    h += struct.pack("<I", 0)
    return bytes(h)


def write_pvr_v2(path, width, height, data, bpp=2):

  
    PVR_MAGIC = 0x21525650  
    header = struct.pack("<13I",
        PVR_MAGIC,     
        0,             
        0,             
        0, 0, 0, 0, 0, 
        0, 0, 0, 0, 0 
    )
    with open(path, "wb") as f:
        
        f.write(data)
   
    return

def parse_info_text(txt):
    
    low = txt.lower()
    comp = False
    m = re.search(r'compressondisk\s*=\s*(true|false)', low)
    if not m:
        m = re.search(r'compressondisk\((bool)?\)\s*=\s*(true|false)', low)
    if m:
        comp = (m.group(1) or m.group(2) or "").lower() == "true" or (m.group(0).endswith("= true"))

    imp = ""
    m2 = re.search(r'importfilepath.*?=\s*"(.*?)"', txt, flags=re.IGNORECASE|re.DOTALL)
    if m2:
        imp = m2.group(1)
    return comp, imp

def read_tex_header(fp):
    fileVer = read_u32(fp)
    fileCount_plus1 = read_u32(fp)
    fileId = read_u32(fp) 
    infoOffset = read_u32(fp)
    fileCount = max(0, fileCount_plus1 - 1)

    fileFmt = []
    fileOffset = []
    for i in range(fileCount):
        fileFmt.append(read_u32(fp))
        fileOffset.append(read_u32(fp))

    return {
        "ver": fileVer,
        "count": fileCount,
        "id": fileId,
        "infoOfs": infoOffset,
        "fmts": fileFmt,
        "ofs": fileOffset
    }

def load_block(fp, offset, compressOnDisk):
    fp.seek(offset)
    texFmt = read_u32(fp)
    w = read_u32(fp)
    h = read_u32(fp)
    mips = read_u32(fp)
    size = read_u32(fp)
    if compressOnDisk:
        decSize = read_u32(fp)
        comp = fp.read(max(0, size - 4))
        try:
            data = zlib.decompress(comp)
            if len(data) != decSize:

                data = comp
        except Exception:
            data = comp
    else:
        data = fp.read(size)

        data, _ = try_zlib_prefix_len_blob(data)
    return texFmt, w, h, mips, data

def texfmt_to_dds_params(fmt):

    if fmt == 5:   # DXT1 (BC1) - compressed, no alpha (or 1-bit alpha)
        return True, b"DXT1", 0, (0,0,0,0), None

    if fmt == 6:   # DXT3 (BC2) - compressed, explicit alpha
        return True, b"DXT3", 0, (0,0,0,0), None

    if fmt == 7:   # DXT5 (BC3) - compressed, interpolated alpha
        return True, b"DXT5", 0, (0,0,0,0), None

    if fmt == 0:   # RGBA8888 (32-bit, R=8,G=8,B=8,A=8)
        return False, None, 32, (0x000000FF,0x0000FF00,0x00FF0000,0xFF000000), None

    if fmt == 1:   # RGB888 (24-bit, R=8,G=8,B=8)
        return False, None, 24, (0x000000FF,0x0000FF00,0x00FF0000,0x00000000), None

    if fmt == 3:   # RGB565 (16-bit, R=5,G=6,B=5)

        return False, None, 16, (0xF800, 0x07E0, 0x001F, 0x0000), "B5G6R5"

    if fmt == 4:   # RGBA4444 (16-bit, R=4,G=4,B=4,A=4)
        return False, None, 16, (0x000F, 0x00F0, 0x0F00, 0xF000), "A4R4G4B4"

    if fmt == 8:   # Alpha8 (8-bit grayscale alpha)
        return False, None, 8,  (0x00000000,0x00000000,0x00000000,0x000000FF), "A8"

    if fmt == 9:   # PVRTC2 (compressed, iOS/PowerVR specific)
        return None, None, 0,  (0,0,0,0), "PVRTC2"

    # Default fallback (RGBA8888)
    return False, None, 32, (0x000000FF,0x0000FF00,0x00FF0000,0xFF000000), None
    # supports dxt1, dxt5, rgba4444, rgba8888, rgb888, a8, rgb565, pvrtc 4bpp(?)

def expand_raw_to_rgba(fmt_special, data, w, h):

    if fmt_special == "B5G6R5":
        exp = w*h*2
        if len(data) < exp: raise RuntimeError("Not enough B5G6R5 data")
        out = bytearray(w*h*4)
        di = 0; oi = 0
        for _ in range(w*h):
            v = data[di] | (data[di+1]<<8); di+=2
            r5 = (v>>11)&0x1F; g6=(v>>5)&0x3F; b5=v&0x1F
            r=(r5*255+15)//31; g=(g6*255+31)//63; b=(b5*255+15)//31
            out[oi+0]=r; out[oi+1]=g; out[oi+2]=b; out[oi+3]=255; oi+=4
        return bytes(out)
    if fmt_special == "A4B4G4R4":
        exp = w*h*2
        if len(data) < exp: raise RuntimeError("Not enough A4B4G4R4 data")
        out = bytearray(w*h*4)
        di=0; oi=0
        for _ in range(w*h):
            v = data[di] | (data[di+1]<<8); di+=2
            a = ((v>>12)&0xF)*17; b=((v>>8)&0xF)*17; g=((v>>4)&0xF)*17; r=(v&0xF)*17
            out[oi+0]=r; out[oi+1]=g; out[oi+2]=b; out[oi+3]=a; oi+=4
        return bytes(out)
    if fmt_special == "A8":
        exp = w*h
        if len(data) < exp: raise RuntimeError("Not enough A8 data")
        out = bytearray(w*h*4)
        for i,a in enumerate(data[:exp]):
            j=i*4
            out[j+0]=a; out[j+1]=a; out[j+2]=a; out[j+3]=a
        return bytes(out)
    return None

def write_one_block(out_base, name_hint, idx, texFmt, w, h, mips, blob, want_png=False):
    is_comp, fourcc, rgb_bits, masks, special = texfmt_to_dds_params(texFmt)

    if idx is None or idx == (hdr['count']-1):
        base_noext = out_base 
    else:
        base_noext = f"{out_base}_{idx:02d}"

    out_dds = base_noext + ".dds"
    out_png = base_noext + ".png"
    out_pvr = base_noext + ".pvr"

    if special == "PVRTC2":

            try:
                rgba = decode_pvrtc_blob(blob, w, h, is2bpp=True)
 
                hdr = create_dds_header(w, h, max(1, mips), fourcc=None, rgb_bitcount=32,
                                        r_mask=0x00FF0000, g_mask=0x0000FF00, b_mask=0x000000FF, a_mask=0xFF000000)
                with open(out_dds, "wb") as fo:
                    fo.write(hdr)
                    fo.write(rgba)
                print(f"[ok] PVRTC2 decoded -> DDS RGBA32 -> {out_dds}")
                if want_png and Image is not None:
                    try:
                        Image.frombytes("RGBA", (w, h), rgba).save(out_png)
                        print(f"[ok] PVRTC2 decoded -> PNG -> {out_png}")
                    except Exception as e:
                        print(f"[warn] PVRTC2 PNG export failed: {e}")
                return
            except Exception as e:
                print(f"[warn] PVRTC2 decode failed or decoder not available: {e}")
                write_pvr_v2(out_pvr, w, h, blob, bpp=2)
                print(f"[ok] PVRTC2 saved as PVR > {out_pvr}  (raw blob fallback)")
                return


    payload = blob
    if special in ("B5G6R5", "A4B4G4R4", "A8"):
        try:
            rgba = expand_raw_to_rgba(special, blob, w, h)
            if rgba is not None:
    
                hdr = create_dds_header(w, h, max(1, mips), fourcc=None,
                                        rgb_bitcount=32,
                                        r_mask=0x00FF0000, g_mask=0x0000FF00,
                                        b_mask=0x000000FF, a_mask=0xFF000000)
                with open(out_dds, "wb") as fo:
                    fo.write(hdr); fo.write(rgba)
                print(f"[ok] Wrote DDS (expanded {special} -> RGBA32) -> {out_dds}")
                if want_png and Image is not None:
                    Image.frombytes("RGBA", (w,h), rgba).save(out_png)
                    print(f"[ok] Wrote PNG -> {out_png}")
                return
        except Exception as e:
            print(f"[warn] expand {special} failed ({e}), writing raw bytes into DDS header (viewer may not like it)")


    if is_comp:
        hdr = create_dds_header(w, h, max(1, mips), fourcc=fourcc)
    else:

        if rgb_bits == 8 and special == "A8":
            hdr = create_dds_header(w, h, max(1, mips), fourcc=None, rgb_bitcount=8, luminance=True)
        elif rgb_bits in (24, 32, 16, 8):
            r,g,b,a = masks
            hdr = create_dds_header(w, h, max(1, mips), fourcc=None,
                                    rgb_bitcount=rgb_bits, r_mask=r, g_mask=g, b_mask=b, a_mask=a)
        else:

            hdr = create_dds_header(w, h, max(1, mips), fourcc=None,
                                    rgb_bitcount=32, r_mask=0x00FF0000, g_mask=0x0000FF00, b_mask=0x000000FF, a_mask=0xFF000000)

    with open(out_dds, "wb") as fo:
        fo.write(hdr)
        fo.write(payload)
    print(f"[ok] Wrote DDS -> {out_dds}")


    if (not is_comp) and Image is not None and (rgb_bits in (24,32) or special in ("B5G6R5","A4B4G4R4","A8")) and want_png:
        try:
            if special in ("B5G6R5","A4B4G4R4","A8"):
                rgba = expand_raw_to_rgba(special, blob, w, h)
                if rgba is not None:
                    Image.frombytes("RGBA", (w,h), rgba).save(out_png)
                    print(f"[ok] Wrote PNG -> {out_png}")
            elif rgb_bits == 32:
                exp = w*h*4
                if len(blob) >= exp:
       
                    rgba = bytearray(exp)
                    for i in range(0, exp, 4):
                        a=blob[i+0]; r=blob[i+1]; g=blob[i+2]; b=blob[i+3]
                        rgba[i+0]=r; rgba[i+1]=g; rgba[i+2]=b; rgba[i+3]=a
                    Image.frombytes("RGBA", (w,h), bytes(rgba)).save(out_png)
                    print(f"[ok] Wrote PNG -> {out_png}")
            elif rgb_bits == 24:
                exp = w*h*3
                if len(blob) >= exp:
                    Image.frombytes("RGB", (w,h), blob[:exp]).save(out_png)
                    print(f"[ok] Wrote PNG -> {out_png}")
        except Exception as e:
            print(f"[warn] PNG export failed: {e}")

def main():
    ap = argparse.ArgumentParser(description="Bully AE TEX -> DDS/PVR (Edness-like)")
    ap.add_argument("tex_in", help="input .tex")
    ap.add_argument("out_base", help="output base name (without extension)")
    ap.add_argument("--index", type=int, default=None, help="export only a specific texture index (0-based)")
    ap.add_argument("--all", action="store_true", help="export all texture blocks")
    ap.add_argument("--png", action="store_true", help="also export PNG for raw formats (if Pillow installed)")
    args = ap.parse_args()

    if not os.path.isfile(args.tex_in):
        print("Input missing."); sys.exit(2)

    with open(args.tex_in, "rb") as f:
        hdr = read_tex_header(f)
        filesize = os.path.getsize(args.tex_in)


        compressOnDisk = False
        importPath = ""
        if 0 < hdr["infoOfs"] < filesize:
            try:
                f.seek(hdr["infoOfs"])
                info_len = read_u32(f)
                info_len = clamp(info_len, 0, min(info_len, filesize - f.tell()))
                info_txt = f.read(info_len).decode(errors="ignore")
                compressOnDisk, importPath = parse_info_text(info_txt)
            except Exception:
                pass

        print(f"[info] ver=0x{hdr['ver']:X} count={hdr['count']} infoOfs=0x{hdr['infoOfs']:X} compressOnDisk={compressOnDisk}")
        if importPath:
            print(f"[info] importFilePath: {importPath}")

        indices = []
        if args.all:
            indices = list(range(hdr["count"]))
        elif args.index is not None:
            if args.index < 0 or args.index >= hdr["count"]:
                print(f"Index {args.index} out of range (0..{hdr['count']-1})."); sys.exit(3)
            indices = [args.index]
        else:
            indices = [hdr["count"]-1] if hdr["count"] > 0 else []


        if not indices:
            print("[warn] No texture blocks found."); return

        for i in indices:
            texFmt, w, h, mips, data = load_block(f, hdr["ofs"][i], compressOnDisk)
            print(f"[info] block#{i} fmt={texFmt} {w}x{h} mips={mips} blob={len(data)}")
            
            out_base = args.out_base

            write_one_block(out_base, os.path.splitext(os.path.basename(args.tex_in))[0], i if len(indices)>1 or (args.index is not None and hdr["count"]>1) else None,
                            texFmt, w, h, mips, data, want_png=args.png)

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print("Error:", e)
        sys.exit(3)
