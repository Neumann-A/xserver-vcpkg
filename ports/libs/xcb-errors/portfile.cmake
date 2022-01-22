if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxcb-errors
    REF  5d660ebe872cadcdc85de9d6f9afe05de629c030 
    SHA512 459e658224e291ec68d772877952752c90663ec5bc9169600bdbc4259bcf9ce8f35de04c81fdbcb8148b0f9d721303041eb6c567cb28de52fcb9a64680b0469f
    HEAD_REF master
    PATCHES fix_path.patch
) 

file(TOUCH "${SOURCE_PATH}/m4/dummy")
set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

set(ENV{XCBPROTO_XCBINCLUDEDIR} "${CURRENT_INSTALLED_DIR}/share/xcb-proto/xcb")
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS "XCBPROTO_XCBINCLUDEDIR=${CURRENT_INSTALLED_DIR}/share/xcb-proto/xcb"
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
endif()
