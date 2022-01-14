function(vcpkg_get_python_package PYTHON_DIR )
    cmake_parse_arguments(PARSE_ARGV 0 _vgpp "" "PYTHON_EXECUTABLE" "PACKAGES")
    
    if(NOT _vgpp_PYTHON_EXECUTABLE)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} requires parameter PYTHON_EXECUTABLE!")
    endif()
    if(NOT _vgpp_PACKAGES)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} requires parameter PACKAGES!")
    endif()
    if(NOT _vgpp_PYTHON_DIR)
        get_filename_component(_vgpp_PYTHON_DIR "${_vgpp_PYTHON_EXECUTABLE}" DIRECTORY)
    endif()

    if (WIN32)
        set(PYTHON_OPTION "")
    else()
        set(PYTHON_OPTION "--user")
    endif()

    if("${_vgpp_PYTHON_DIR}" MATCHES "${DOWNLOADS}") # inside vcpkg
        if(NOT EXISTS "${_vgpp_PYTHON_DIR}/easy_install${VCPKG_HOST_EXECUTABLE_SUFFIX}")
            if(NOT EXISTS "${_vgpp_PYTHON_DIR}/Scripts/pip${VCPKG_HOST_EXECUTABLE_SUFFIX}")
                vcpkg_from_github(
                    OUT_SOURCE_PATH PYFILE_PATH
                    REPO pypa/get-pip
                    REF 309a56c5fd94bd1134053a541cb4657a4e47e09d #2019-08-25
                    SHA512 bb4b0745998a3205cd0f0963c04fb45f4614ba3b6fcbe97efe8f8614192f244b7ae62705483a5305943d6c8fedeca53b2e9905aed918d2c6106f8a9680184c7a
                    HEAD_REF master
                )
                execute_process(COMMAND "${_vgpp_PYTHON_EXECUTABLE}" "${PYFILE_PATH}/get-pip.py" ${PYTHON_OPTION})
            endif()
            foreach(_package IN LISTS _vgpp_PACKAGES)
                execute_process(COMMAND "${_vgpp_PYTHON_DIR}/Scripts/pip${VCPKG_HOST_EXECUTABLE_SUFFIX}" install ${_package} ${PYTHON_OPTION})
            endforeach()
        else()
            foreach(_package IN LISTS _vgpp_PACKAGES)
                execute_process(COMMAND "${_vgpp_PYTHON_DIR}/easy_install${VCPKG_HOST_EXECUTABLE_SUFFIX}" ${_package})
            endforeach()
        endif()
        if(NOT VCPKG_TARGET_IS_WINDOWS)
            execute_process(COMMAND pip3 install ${_vgpp_PACKAGES})
        endif()
    else() # outside vcpkg
        foreach(_package IN LISTS _vgpp_PACKAGES)
            execute_process(COMMAND ${_vgpp_PYTHON_EXECUTABLE} -c "import ${_package}" RESULT_VARIABLE HAS_ERROR)
            if(HAS_ERROR)
                message(FATAL_ERROR "Python package '${_package}' needs to be installed for port '${PORT}'.\nComplete list of required python packages: ${_vgpp_PACKAGES}")
            endif()
        endforeach()
    endif()
endfunction()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(PATCHES windows.patch windows2.patch win_random.patch)
endif()

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xorg/xserver
    REF  85397cc2efe8fa73461cd21afe700829b2eca768
    SHA512 768ffab51bcc336987ed79fd5937d1ff7699099ac80bd4f8eb2b0d36ee3c7f7eec8502ee04bd6af25522d97101195aadb9086bad7f91768ad0374a7a69550e50
    HEAD_REF master # branch name
    PATCHES ${PATCHES} 
) 
#https://gitlab.freedesktop.org/xkeyboard-config/xkeyboard-config
set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")
vcpkg_add_to_path("${PYTHON3_DIR}/Scripts")
vcpkg_host_path_list(APPEND ENV{PYTHONPATH} "${CURRENT_INSTALLED_DIR}/share/opengl")

set(ENV{PYTHON} "${PYTHON3}")
set(ENV{PYTHON3} "${PYTHON3}")

vcpkg_get_python_package(PYTHON_EXECUTABLE "${PYTHON3}" PACKAGES env lxml)

vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_DIR "${BISON}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${BISON_DIR}")

if(WIN32) # WIN32 HOST probably has win_flex and win_bison!
    if(NOT EXISTS "${FLEX_DIR}/flex${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        file(CREATE_LINK "${FLEX}" "${FLEX_DIR}/flex${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    endif()
    if(NOT EXISTS "${BISON_DIR}/BISON${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        file(CREATE_LINK "${BISON}" "${BISON_DIR}/bison${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    endif()
endif()
#xvfb
# Dropped?
if("xwayland" IN_LIST FEATURES)
    #list(APPEND OPTIONS -Dxwayland=true)
else()
    #list(APPEND OPTIONS -Dxwayland=false)
endif()
if("xnest" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dxnest=true)
else()
    list(APPEND OPTIONS -Dxnest=false)
endif()
if("xephyr" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dxephyr=true)
else()
    list(APPEND OPTIONS -Dxephyr=false)
endif()
if("xorg" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dxorg=true)
else()
    list(APPEND OPTIONS -Dxorg=false)
endif()
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS -Dglx=true) #Requires Mesa3D for gl.pc
    list(APPEND OPTIONS -Dsecure-rpc=false) #Problem encountered: secure-rpc requested, but neither libtirpc or libc RPC support were found
    list(APPEND OPTIONS -Dlisten_tcp=true)
    list(APPEND OPTIONS -Dlisten_local=false)
    list(APPEND OPTIONS -Dxwin=true)
    set(ENV{INCLUDE} "$ENV{INCLUDE};${CURRENT_INSTALLED_DIR}/include")
else()
    if("xwin" IN_LIST FEATURES)
        list(APPEND OPTIONS -Dxwin=true)
    else()
        list(APPEND OPTIONS -Dxwin=false)
    endif()
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${OPTIONS}
        -Dlisten_tcp=true
        -Ddocs=false
        # Note: xserver will overwrite the base settings by trying to be relocatable.
        # To start the server you need to copy over xkbcomp + deps from tools/xkbcomp/bin
        # and you need to copy the rules from share/X11/xkb to tools/xserver/xkb
        #-Dlog_dir=logs
        #-Dxkb_dir=../../share/X11/xkb
        #-Dxkb_output_dir=xkb/out
        #-Dxkb_bin_dir=../xkbcomp/bin
)
vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/var" "${CURRENT_PACKAGES_DIR}/var")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")
set(TOOLS cvt gtf Xorg Xvfb Xwayland Xwin Xming xwinclip)
foreach(_tool ${TOOLS})
    if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        if(VCPKG_TARGET_IS_WINDOWS)
            file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${_tool}.pdb" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${_tool}.pdb")
        endif()
    endif()
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        if(VCPKG_TARGET_IS_WINDOWS)
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/${_tool}.pdb" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/${_tool}.pdb")
        endif()
        if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
            file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/debug/bin/${_tool}.pdb")
        endif()
    endif()
endforeach()

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/xserver")

file(GLOB_RECURSE BIN_FILES "${CURRENT_PACKAGES_DIR}/bin")
if(NOT BIN_FILES)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()