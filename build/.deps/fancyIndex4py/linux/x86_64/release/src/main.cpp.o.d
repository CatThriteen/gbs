{
    depfiles_gcc = "main.o: src/main.cpp src/fancyIndex.h\
",
    files = {
        "src/main.cpp"
    },
    values = {
        "/usr/bin/gcc",
        {
            "-m64",
            "-fPIC",
            "-std=gnu++23",
            "-I/usr/include/eigen3",
            "-DEIGEN_NO_DEBUG",
            "-isystem",
            "/home/g/.xmake/packages/p/pybind11/v2.13.6/8d7565588f4b45f7a0635954fd1f2205/include",
            "-isystem",
            "/home/g/.xmake/packages/p/python/3.13.0/b7dd8beff26a4c82bc950462214dc4e3/include/python3.13",
            "-isystem",
            "/home/g/.xmake/packages/o/openssl/1.1.1-w/6c51ab6278e2479b883dffafac69fdaf/include",
            "-fopenmp",
            "-O3",
            "-DNDEBUG"
        }
    }
}