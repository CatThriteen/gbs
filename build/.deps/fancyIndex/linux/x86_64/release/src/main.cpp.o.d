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
    depfiles_gcc = "main.o: src/main.cpp src/fancyIndex.h\
",
    files = {
        "src/main.cpp"
    }
}