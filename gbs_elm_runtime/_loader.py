from __future__ import annotations
import os
import sys
import platform
from pathlib import Path
from typing import Optional
import importlib.machinery as mach

_NATIVE: Optional[object] = None

def _os_id() -> str:
    if sys.platform.startswith("win"):
        return "windows"
    if sys.platform == "darwin":
        return "macos"
    if sys.platform.startswith("linux"):
        return "linux"
    raise RuntimeError(f"Unsupported platform: {sys.platform}")

def _arch_id() -> str:
    m = platform.machine().lower()
    if m == "amd64":
        return "x86_64"
    if m in ("x86_64", "arm64", "aarch64"):
        return m
    return m

def _py_tag() -> str:
    return f"cp{sys.version_info[0]}{sys.version_info[1]}"

def _has_extmod(dirpath: Path) -> bool:
    if not dirpath.exists():
        return False
    for suf in mach.EXTENSION_SUFFIXES:
        # e.g. fancyIndex4py.cpython-310-darwin.so / fancyIndex4py.cp310-win_amd64.pyd
        if list(dirpath.glob(f"fancyIndex4py*{suf}")):
            return True
    return False

def load_native(prebuilt_root: Optional[str] = None):
    global _NATIVE
    if _NATIVE is not None:
        return _NATIVE

    repo_root = Path(__file__).resolve().parent.parent
    root = Path(prebuilt_root) if prebuilt_root else Path(os.getenv("GBS_ELM_PREBUILT_ROOT", repo_root / "prebuilt"))

    osid = _os_id()
    arch = _arch_id()
    pytag = _py_tag()

    cand = root / f"{osid}-{arch}" / pytag

    if not _has_extmod(cand):
        raise RuntimeError(
            "Native binary not found.\n"
            f"  platform={osid} arch={arch} python={sys.version_info[0]}.{sys.version_info[1]}\n"
            f"  expected_dir={cand}\n"
            f"  extension_suffixes={mach.EXTENSION_SUFFIXES}\n"
            f"  prebuilt_root={root}\n"
        )

    sys.path.insert(0, str(cand))

    try:
        import fancyIndex4py as m
    except Exception as e:
        raise RuntimeError(
            "Failed to import fancyIndex4py.\n"
            f"  tried_dir={cand}\n"
            f"  sys.path[0]={sys.path[0]}\n"
            f"  error={repr(e)}\n"
        ) from e

    _NATIVE = m
    return m
