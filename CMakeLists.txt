
cmake_minimum_required(VERSION 3.21)
include(FetchContent)
FetchContent_Declare(
    vcpkg
    GIT_REPOSITORY https://github.com/microsoft/vcpkg.git
    GIT_TAG        9f04533f307a8560cc1cc5c1fdee0d88d6d7d818 # 2022-01-11
)
if(NOT CMAKE_TOOLCHAIN_FILE)
    if(NOT vcpkg_POPULATED)
        FetchContent_Populate(vcpkg)
        set(CMAKE_TOOLCHAIN_FILE "${vcpkg_SOURCE_DIR}/scripts/buildsystems/vcpkg.cmake" CACHE STRING "")
    endif()
endif()

set(VCPKG_OVERLAY_PORTS "${CMAKE_CURRENT_SOURCE_DIR}/ports/libs;${CMAKE_CURRENT_SOURCE_DIR}/ports/app" CACHE STRING "")
set(VCPKG_MANIFEST_DIR "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg-manifest" CACHE STRING "")

project(xserver-vcpkg LANGUAGE None)