# This takes the configure files from http://gnuwin32.sourceforge.net/packages/regex.htm
# and updates the regex sources with the ones from glibc version 2.37
#https://downloads.sourceforge.net/project/gnuwin32/regex/2.7/regex-2.7-src.zip?ts=gAAAAABh30AsfSdobmGiaf0s8Vo1w0tPkj0IdV2AnPmg-Z3kFPQ3SEA-pk4brXDyDIPLDG8P6gGQiO9TgsRtdktf84FAz3Js0Q%3D%3D&r=
# https%3A%2F%2Fsourceforge.net%2Fprojects%c%2Ffiles%2Fregex%2F2.7%2Fregex-2.7-src.zip%2Fdownload
vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gnuwin32/regex
    FILENAME "regex-2.7-src.zip"
    REF 2.7
    SHA512 ea144e02addb71746a5aeecf42f603bc350d4aff3425d6b0eabd509fcc0b590fdccba71c0950c938232736f4409c0b32b7906084c2b4252cf69550b920e45480
    NO_REMOVE_ONE_LEVEL
    PATCHES version.patch
)
vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnu.org/gnu/glibc/glibc-2.34.tar.xz"
    FILENAME "glibc-2.34.tar.xz"
    SHA512 15252affd9ef4523a8001db16d497f4fdcb3ddf4cde7fe80e075df0bd3cc6524dc29fbe20229dbf5f97af580556e6b1fac0de321a5fe25322bc3e72f93beb624
)
vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH_GLIBC
    PATCHES exports.patch
)

set(regex_files re_comp.h
                regcomp.c
                regex.c
                regex.h
                regex_internal.c
                regex_internal.h
                regexec.c)

list(TRANSFORM regex_files PREPEND "${SOURCE_PATH_GLIBC}/posix/")
set(regex_source_base_path "${SOURCE_PATH}/src/regex/2.7/regex-2.7-src")
file(COPY ${regex_files} DESTINATION "${regex_source_base_path}/src")
file(COPY "${regex_source_base_path}/../regex-2.7/resource/" DESTINATION "${regex_source_base_path}/src")

vcpkg_configure_make(
    SOURCE_PATH "${regex_source_base_path}"
    AUTOCONFIG
    OPTIONS
        #ac_cv_prog_cc_c11='-std:c11'
        #ac_cv_c_restrict='__restrict'
)
vcpkg_backup_env_variables(VARS INCLUDE)
vcpkg_host_path_list(PREPEND ENV{INCLUDE} "${SOURCE_PATH_GLIBC}")
vcpkg_host_path_list(PREPEND ENV{INCLUDE} "${SOURCE_PATH_GLIBC}/posix")
vcpkg_host_path_list(PREPEND ENV{INCLUDE} "${SOURCE_PATH_GLIBC}/catgets")
vcpkg_host_path_list(PREPEND ENV{INCLUDE} "${SOURCE_PATH_GLIBC}/locale")
vcpkg_host_path_list(PREPEND ENV{INCLUDE} "${SOURCE_PATH_GLIBC}/include")
vcpkg_install_make()
vcpkg_restore_env_variables(VARS INCLUDE)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${regex_source_base_path}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
