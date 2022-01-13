if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxshmfence
    REF  f38b2e73071ba516127f8f5ae47f48df58dc9d53 #1.3
    SHA512 d3342db68b24b2b139977655fc42fde9b22cc1b786e1df6f14c5084e195d2208c11391b9a1769b4d6f9d41d21c163c1d9aa92f72059ada468375daaeee8dffdb
    HEAD_REF master # branch name
    PATCHES windows.patch
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_backup_env_variables(VARS INCLUDE LIBS)
    vcpkg_host_path_list(PREPEND ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include/mman")
    vcpkg_host_path_list(PREPEND ENV{LIBS} "-lmman")
endif()
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS_RELEASE
    OPTIONS_DEBUG
)

vcpkg_install_make()
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_restore_env_variables(VARS INCLUDE LIBS)
    set(pcfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/xshmfence.pc")
    if(EXISTS "${pcfile}")
        vcpkg_replace_string("${pcfile}" "Cflags:" "Cflags: -I\"\${includedir}/mman\"")
        vcpkg_replace_string("${pcfile}" "Libs.private:" "Libs.private: -lmman")
    endif()
    set(pcfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/xshmfence.pc")
    if(EXISTS "${pcfile}")
        vcpkg_replace_string("${pcfile}" "Cflags:" "Cflags: -I\"\${includedir}/mman\"")
        vcpkg_replace_string("${pcfile}" "Libs.private:" "Libs.private: -lmman")
    endif()
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}/")
file(TOUCH "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright") #already installed by xproto
endif()

