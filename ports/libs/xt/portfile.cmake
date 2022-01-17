if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Does not support cl due to one singular asm instruction. 
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxt
    REF edd70bdfbbd16247e3d9564ca51d864f82626eb7 # 1.2.1
    SHA512  c49876253dfd187e7d56a098d3d992157daefa2c25ee732eaae5818ee04513bedd807d2f265085db2e82c0b1821e152a88fb4998c0002f6ac57204543fe18566
    HEAD_REF master # branch name
    PATCHES windows_build.patch # Still needs a fix for the asm on x64
            xt.patch
            include.patch
) 

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(stringsfile "${SOURCE_PATH}/util/string.list")
    vcpkg_replace_string("${SOURCE_PATH}/util/string.list" "#externref extern" "#externref __declspec(dllexport) extern ")
    vcpkg_replace_string("${SOURCE_PATH}/util/StrDefs.ct" "#define Const const" "#define Const __declspec(dllexport) const")
endif()
#externref extern
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS 
        --with-xfile-search-path=X11
        --with-appdefaultdir=share/X11/app-defaults
        --enable-malloc0returnsnull=yes
        xorg_cv_malloc0_returns_null=yes
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/X11/StringDefs.h" "__declspec(dllexport)" "__declspec(dllimport)")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
endif()
