if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libpciaccess
    REF  fbd1f0fe79ba25b72635f8e36a6c33d7e0ca19f6 #0.16
    SHA512 e148e513453e4d6c131287d69910fa14b66557039acdfe3c59ec8de280841a62b9c727203331ebc2e9f0f1797dccbe22ca99aeecae78314448ef3cca017bc883
    HEAD_REF master # branch name
) 
#file(TOUCH ${SOURCE_PATH}/m4/dummy)
set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS_DEBUG
        --with-zlib=${CURRENT_INSTALLED_DIR}
    OPTIONS_RELEASE
        --with-zlib=${CURRENT_INSTALLED_DIR}/debug
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}/")
file(TOUCH "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright") #already installed by xproto
endif()
