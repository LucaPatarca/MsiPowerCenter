cmake_minimum_required(VERSION 3.0.0)
project(PowerCenter VERSION 0.1.0)

add_executable(PowerCenter src/main.c src/profile.h src/profile.c src/ec.h src/ec.c src/cpupower.h src/cpupower.c)

set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)

find_package(PkgConfig REQUIRED)
pkg_check_modules(dep REQUIRED IMPORTED_TARGET glib-2.0)
target_link_libraries(PowerCenter PkgConfig::dep)
