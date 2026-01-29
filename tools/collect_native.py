#!/usr/bin/env python3
import argparse
import glob
import importlib.machinery as mach
import shutil
from pathlib import Path

def norm_arch(arch: str) -> str:
    a = arch.lower()
    if a in ("amd64",):
        return "x86_64"
    if a in ("x86_64", "arm64", "aarch64"):
        return a
    return a

def is_extension_module(p: Path) -> bool:
    name = p.name
    if not name.startswith("fancyIndex4py"):
        return False
    return any(name.endswith(suf) for suf in mach.EXTENSION_SUFFIXES)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", required=True)
    ap.add_argument("--dst", required=True)
    ap.add_argument("--os", required=True, choices=["linux", "macos", "windows"])
    ap.add_argument("--arch", required=True)
    ap.add_argument("--py", required=True)  # 310/311/312...
    args = ap.parse_args()

    src = Path(args.src).resolve()
    dst = Path(args.dst).resolve()
    arch = norm_arch(args.arch)
    pytag = f"cp{args.py}"

    if not src.exists():
        raise SystemExit(f"[collect_native] src not found: {src}")

    outdir = dst / f"{args.os}-{arch}" / pytag
    outdir.mkdir(parents=True, exist_ok=True)

    # 统一：先把 build 里所有 fancyIndex4py* 找出来，再用 EXTENSION_SUFFIXES 过滤
    matched = [Path(p) for p in glob.glob(str(src / "**/fancyIndex4py*"), recursive=True)]
    extmods = [p for p in matched if p.is_file() and is_extension_module(p)]

    # 可选：也收集 CLI 可执行程序
    binaries = []
    if args.os == "windows":
        binaries = [Path(p) for p in glob.glob(str(src / "**/fancyIndex*.exe"), recursive=True)]
    else:
        binaries = [Path(p) for p in glob.glob(str(src / "**/fancyIndex"), recursive=True)]

    binaries = [p for p in binaries if p.is_file()]

    if not extmods:
        raise SystemExit(
            "[collect_native] no extension module found under build.\n"
            f"  src={src}\n"
            f"  EXTENSION_SUFFIXES={mach.EXTENSION_SUFFIXES}\n"
            "  hint: ensure fancyIndex4py target is built."
        )

    copied = []
    for f in sorted(set(extmods + binaries)):
        target = outdir / f.name
        shutil.copy2(f, target)
        copied.append(str(target))

    print("[collect_native] outdir:", outdir)
    print("[collect_native] copied:")
    for c in copied:
        print("  ", c)

if __name__ == "__main__":
    main()
