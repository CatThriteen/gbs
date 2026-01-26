{
    values = {
        "/usr/bin/g++",
        {
            "-shared",
            "-m64",
            "-fPIC",
            "-L/usr/local/lib",
            "-L/home/g/.xmake/packages/p/python/3.13.0/b7dd8beff26a4c82bc950462214dc4e3/lib",
            "-L/home/g/.xmake/packages/o/openssl/1.1.1-w/6c51ab6278e2479b883dffafac69fdaf/lib",
            "-s",
            "-lgomp",
            "-lpython3.13",
            "-lssl",
            "-lcrypto",
            "-lutil",
            "-lpthread",
            "-ldl"
        }
    },
    files = {
        "build/.objs/fancyIndex4py/linux/x86_64/release/src/fancyIndex.cpp.o",
        "build/.objs/fancyIndex4py/linux/x86_64/release/src/pywrap.cpp.o",
        "build/.objs/fancyIndex4py/linux/x86_64/release/src/main.cpp.o"
    }
}