{
    values = {
        "/usr/bin/gcc",
        {
            "-m64",
            "-fvisibility=hidden",
            "-fvisibility-inlines-hidden",
            "-O3",
            "-std=gnu++23",
            "-DEIGEN_NO_DEBUG",
            "-fopenmp",
            "-DNDEBUG"
        }
    },
    depfiles_gcc = "fancyIndex.o: src/fancyIndex.cpp src/fancyIndex.h\
",
    files = {
        "src/fancyIndex.cpp"
    }
}