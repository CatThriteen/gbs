import sys
import platform
from gbs_elm_runtime import load_native

def main():
    print(f"platform={sys.platform} machine={platform.machine()} python={sys.version.split()[0]}")
    m = load_native()
    print(f"loaded: {m.__name__} from {getattr(m, '__file__', None)}")

    # 只做最小 smoke：确保符号存在（不强行调用，避免你这边函数签名变化导致误报）
    if hasattr(m, "getResult"):
        print("symbol: getResult = OK")
    else:
        print("warning: getResult not found (check your pywrap exports)")

if __name__ == "__main__":
    main()
