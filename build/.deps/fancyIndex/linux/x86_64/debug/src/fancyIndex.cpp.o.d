{
    depfiles_gcc = "fancyIndex.o: src/fancyIndex.cpp src/fancyIndex.h\
",
    values = {
        "/usr/bin/gcc",
        {
            "-m64",
            "-g",
            "-O0",
            "-std=gnu++23",
            "-DEIGEN_NO_DEBUG",
            "-fopenmp"
        }
    },
    files = {
        "src/fancyIndex.cpp"
    }
}