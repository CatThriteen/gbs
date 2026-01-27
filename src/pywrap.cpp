#include <pybind11/pybind11.h>
#include <pybind11/eigen.h>
#include <pybind11/stl.h>
#include <pybind11/complex.h>
#include "fancyIndex.h"


namespace py = pybind11;



PYBIND11_MODULE(fancyIndex4py, m) {
    m.doc() = "pybind11 example plugin"; // 可选的模块文档字符串

    m.def("fancyIndex", &fancyIndex, "fancy index");
    m.def("getResult", &getResult, "get result");

}
