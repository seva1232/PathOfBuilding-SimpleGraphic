cmake_minimum_required(VERSION 3.21)

foreach(required_variable
        SOURCE_APP
        POB_SOURCE_DIR
        VCPKG_LIBRARY_DIR
        SIMPLEGRAPHIC_LIBRARY
        EGL_LIBRARY
        LCURL_MODULE
        LZIP_MODULE
        LUA_UTF8_MODULE
        SOCKET_MODULE)
    if (NOT DEFINED ${required_variable} OR NOT EXISTS "${${required_variable}}")
        message(FATAL_ERROR "${required_variable} is missing or does not exist: ${${required_variable}}")
    endif()
endforeach()

if (NOT DEFINED OUTPUT_APP OR OUTPUT_APP STREQUAL "")
    message(FATAL_ERROR "OUTPUT_APP is not set")
endif()

if (NOT DEFINED POB_UPDATE_BRANCH OR POB_UPDATE_BRANCH STREQUAL "")
    message(FATAL_ERROR "POB_UPDATE_BRANCH is not set")
endif()

set(contents_dir "${OUTPUT_APP}/Contents")
set(frameworks_dir "${contents_dir}/Frameworks")
set(pob_dir "${contents_dir}/Resources/PathOfBuilding")
set(runtime_dir "${pob_dir}/runtime")
set(native_lua_dir "${runtime_dir}/lua-native")

file(REMOVE_RECURSE "${OUTPUT_APP}")
file(MAKE_DIRECTORY "${frameworks_dir}" "${native_lua_dir}/lcurl" "${native_lua_dir}/socket")
file(COPY "${SOURCE_APP}/" DESTINATION "${OUTPUT_APP}")

file(COPY "${POB_SOURCE_DIR}/src" DESTINATION "${pob_dir}")
file(COPY "${POB_SOURCE_DIR}/runtime/SimpleGraphic" DESTINATION "${runtime_dir}")
file(COPY "${POB_SOURCE_DIR}/runtime/lua" DESTINATION "${runtime_dir}")

foreach(default_file changelog.txt help.txt LICENSE.md)
    if (EXISTS "${POB_SOURCE_DIR}/${default_file}")
        file(COPY_FILE
            "${POB_SOURCE_DIR}/${default_file}"
            "${pob_dir}/src/${default_file}"
            ONLY_IF_DIFFERENT)
    endif()
endforeach()

file(READ "${POB_SOURCE_DIR}/manifest.xml" pob_manifest)
string(REGEX REPLACE
    "<Version number=\"([^\"]+)\"[^>]*/>"
    "<Version number=\"\\1\" branch=\"${POB_UPDATE_BRANCH}\" platform=\"macos\" />"
    pob_manifest
    "${pob_manifest}")
file(WRITE "${pob_dir}/src/manifest.xml" "${pob_manifest}")
file(WRITE "${pob_dir}/src/installed.cfg" "")

file(COPY "${SIMPLEGRAPHIC_LIBRARY}" DESTINATION "${frameworks_dir}" FOLLOW_SYMLINK_CHAIN)

file(GLOB dependency_libraries "${VCPKG_LIBRARY_DIR}/*.dylib")
foreach(dependency_library IN LISTS dependency_libraries)
    file(COPY "${dependency_library}" DESTINATION "${frameworks_dir}" FOLLOW_SYMLINK_CHAIN)
endforeach()

file(COPY_FILE "${EGL_LIBRARY}" "${frameworks_dir}/libEGL.dylib" ONLY_IF_DIFFERENT)
file(COPY_FILE "${LCURL_MODULE}" "${native_lua_dir}/lcurl/safe.so" ONLY_IF_DIFFERENT)
file(COPY_FILE "${LZIP_MODULE}" "${native_lua_dir}/lzip.so" ONLY_IF_DIFFERENT)
file(COPY_FILE "${LUA_UTF8_MODULE}" "${native_lua_dir}/lua-utf8.so" ONLY_IF_DIFFERENT)
file(COPY_FILE "${SOCKET_MODULE}" "${native_lua_dir}/socket/core.so" ONLY_IF_DIFFERENT)

find_program(otool_program otool REQUIRED)
find_program(install_name_tool_program install_name_tool REQUIRED)

file(GLOB_RECURSE bundled_files LIST_DIRECTORIES false "${OUTPUT_APP}/Contents/*")
foreach(bundled_file IN LISTS bundled_files)
    execute_process(
        COMMAND "${otool_program}" -l "${bundled_file}"
        RESULT_VARIABLE otool_result
        OUTPUT_VARIABLE load_commands
        ERROR_QUIET
    )
    if (NOT otool_result EQUAL 0)
        continue()
    endif()

    string(REGEX MATCHALL "path [^\n]+ \\(offset" rpath_entries "${load_commands}")
    foreach(rpath_entry IN LISTS rpath_entries)
        string(REGEX REPLACE "^path (.+) \\(offset$" "\\1" rpath "${rpath_entry}")
        if (IS_ABSOLUTE "${rpath}")
            execute_process(
                COMMAND "${install_name_tool_program}" -delete_rpath "${rpath}" "${bundled_file}"
                COMMAND_ERROR_IS_FATAL ANY
            )
        endif()
    endforeach()
endforeach()

find_program(codesign_program codesign REQUIRED)
execute_process(
    COMMAND "${codesign_program}" --force --deep --sign - "${OUTPUT_APP}"
    COMMAND_ERROR_IS_FATAL ANY
)

message(STATUS "Standalone app assembled at ${OUTPUT_APP}")
