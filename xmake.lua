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

local use_system = get_config("use_system_deps")
local eigen_inc = os.getenv("EIGEN_INCLUDE")
local eigen3_inc = os.getenv("EIGEN3_INCLUDE")
local pybind_inc = os.getenv("PYBIND11_INCLUDE")
local python_inc = os.getenv("PYTHON_INCLUDE")
local python_libdir = os.getenv("PYTHON_LIBDIR")
local python_libname = os.getenv("PYTHON_LIBNAME")

-- 如果用户只给了 EIGEN_INCLUDE，但里面含 eigen3 子目录，则自动补一个兼容路径
if not eigen3_inc and eigen_inc and os.isdir(path.join(eigen_inc, "eigen3")) then
    eigen3_inc = path.join(eigen_inc, "eigen3")
end

-- xmake-repo 里更通用的包名是 eigen（不是 eigen3）
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
    if is_plat("windows") then
        add_cxxflags("/openmp")
        add_ldflags("/openmp")
    elseif is_plat("macosx") then
        add_cxxflags("-Xpreprocessor", "-fopenmp")
        add_ldflags("-lomp")
    else
        add_cxxflags("-fopenmp")
        add_ldflags("-fopenmp")
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
    set_kind("shared")
    set_basename("fancyIndex4py")
    set_prefixname("")
    if is_plat("windows") then
        set_extension(".pyd")
    else
        set_extension(".so")
    end

    -- 关键：不要把 main.cpp 编进 Python 扩展
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

    -- macOS 上通常不强制链接 libpython，允许 undefined dynamic_lookup 更稳
    if is_plat("macosx") then
        add_ldflags("-undefined", "dynamic_lookup", {force = true})
    elseif python_libdir and python_libname then
        add_linkdirs(python_libdir)
        add_links(python_libname)
    end

    apply_openmp()
