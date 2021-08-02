cmake_minimum_required(VERSION 3.0.0)
project(powercenter VERSION 0.1.0)

add_executable(backend src/main.c src/profile.c src/ec.c src/cpupower.c src/util.c src/lib.c)
target_include_directories(backend PRIVATE include)
target_include_directories(backend PRIVATE src)

add_library(msictrl SHARED src/profile.c src/ec.c src/cpupower.c src/util.c src/lib.c)
set_target_properties(msictrl PROPERTIES PUBLIC_HEADER include/lib.h)
target_include_directories(msictrl PRIVATE include)
target_include_directories(msictrl PRIVATE src)

set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)

find_package(PkgConfig REQUIRED)
pkg_check_modules(dep REQUIRED IMPORTED_TARGET glib-2.0)
target_link_libraries(backend PkgConfig::dep)
target_link_libraries(msictrl PkgConfig::dep)
