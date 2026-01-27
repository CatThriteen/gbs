set_project("GBS_ELM")
add_rules("mode.debug", "mode.release")
set_languages("c++17")

option("use_system_deps")
    set_default(false)
    set_showmenu(true)
    set_description("Use system-installed eigen/pybind11 instead of downloading")
option_end()

option("with_openmp")
    set_default(true)
    set_showmenu(true)
    set_description("Enable OpenMP")
option_end()

local use_system     = get_config("use_system_deps")
local eigen_inc      = os.getenv("EIGEN_INCLUDE")
local eigen3_inc     = os.getenv("EIGEN3_INCLUDE")
local pybind_inc     = os.getenv("PYBIND11_INCLUDE")
local python_inc     = os.getenv("PYTHON_INCLUDE")
local python_libdir  = os.getenv("PYTHON_LIBDIR")
local python_libname = os.getenv("PYTHON_LIBNAME")

if not eigen3_inc and eigen_inc and os.isdir(path.join(eigen_inc, "eigen3")) then
    eigen3_inc = path.join(eigen_inc, "eigen3")
end

if not eigen_inc then
    add_requires("eigen", {system = use_system})
end
if not pybind_inc then
    add_requires("pybind11", {system = use_system})
end

local function apply_openmp()
    if not get_config("with_openmp") then
        return
    end
    add_defines("GBS_USE_OPENMP")

    if is_plat("windows") then
        -- MSVC: /openmp
        add_cxxflags("/openmp")
    elseif is_plat("macosx") then
        -- 如果你未来想在 macOS 打开 OpenMP，需要额外装 libomp
        add_cxxflags("-Xpreprocessor", "-fopenmp")
        add_ldflags("-lomp")
        add_shflags("-lomp")
    else
        add_cxxflags("-fopenmp")
        add_ldflags("-fopenmp")
        add_shflags("-fopenmp")
        add_links("gomp")
    end
end

target("fancyIndex")
    set_kind("binary")
    add_files("src/main.cpp", "src/fancyIndex.cpp")
    add_defines("EIGEN_NO_DEBUG")

    if not eigen_inc then
        add_packages("eigen")
    else
        add_includedirs(eigen_inc, {public = true})
    end
    if eigen3_inc then
        add_includedirs(eigen3_inc, {public = true})
    end

    apply_openmp()

target("fancyIndex4py")
    -- 用 python.module（若你的 xmake 太旧没有该规则，可改回 python.library）
    add_rules("python.module", {soabi = true}) -- 生成 cpython-310/312 的 soabi 名称 :contentReference[oaicite:2]{index=2}

    add_files("src/*.cpp", {exclude = "src/main.cpp"})
    add_defines("EIGEN_NO_DEBUG")

    if not eigen_inc then
        add_packages("eigen")
    else
        add_includedirs(eigen_inc, {public = true})
    end
    if eigen3_inc then
        add_includedirs(eigen3_inc, {public = true})
    end

    if not pybind_inc then
        add_packages("pybind11")
    else
        add_includedirs(pybind_inc, {public = true})
    end

    if python_inc then
        add_includedirs(python_inc, {public = true})
    end

    -- ✅ macOS: Python 扩展模块不要在链接期强行解析 _Py*，用 dynamic_lookup
    if is_plat("macosx") then
        add_shflags("-undefined", "dynamic_lookup", {force = true})
    end

    -- ✅ Windows: MSVC 下需要显式链接 pythonXY.lib（workflow 会导出这两个环境变量）
    if is_plat("windows") and python_libdir and python_libname then
        add_linkdirs(python_libdir)
        add_links(python_libname)
    end

    apply_openmp()
