#!/usr/bin/env python3
import argparse
import glob
import os
import shutil
from pathlib import Path

def norm_arch(arch: str) -> str:
    a = arch.lower()
    if a in ("amd64",):
        return "x86_64"
    if a in ("x86_64", "arm64", "aarch64"):
        return a
    return a

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", required=True, help="xmake build root, e.g. <XMAKE_DIR>/build")
    ap.add_argument("--dst", required=True, help="prebuilt root, e.g. <repo>/prebuilt")
    ap.add_argument("--os", required=True, choices=["linux", "macos", "windows"])
    ap.add_argument("--arch", required=True, help="x86_64/arm64/aarch64")
    ap.add_argument("--py", required=True, help="310/312 ...")
    args = ap.parse_args()

    src = Path(args.src).resolve()
    dst = Path(args.dst).resolve()
    arch = norm_arch(args.arch)
    pytag = f"cp{args.py}"

    if not src.exists():
        raise SystemExit(f"[collect_native] src not found: {src}")

    outdir = dst / f"{args.os}-{arch}" / pytag
    outdir.mkdir(parents=True, exist_ok=True)

    patterns = []
    if args.os == "windows":
        patterns += ["**/fancyIndex4py*.pyd", "**/fancyIndex4py*.dll", "**/fancyIndex*.exe"]
    else:
        patterns += ["**/fancyIndex4py*.so", "**/fancyIndex*"]

    matched = []
    for pat in patterns:
        matched.extend([Path(p) for p in glob.glob(str(src / pat), recursive=True)])

    files = []
    for p in matched:
        if p.is_file():
            # 过滤掉无关文件（例如 .a/.o/.dSYM 等）
            if p.suffix in (".o", ".obj", ".a", ".d", ".log"):
                continue
            if p.name.endswith((".lib", ".exp")):
                # Windows: .lib/.exp 不是用户 import 所需，但可保留；这里先不拷
                continue
            files.append(p)

    if not files:
        raise SystemExit(f"[collect_native] no outputs found under: {src}")

    copied = []
    for f in sorted(set(files)):
        target = outdir / f.name
        shutil.copy2(f, target)
        copied.append(str(target))

    print("[collect_native] copied:")
    for c in copied:
        print("  ", c)

if __name__ == "__main__":
    main()
