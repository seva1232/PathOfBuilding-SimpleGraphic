cmake_minimum_required(VERSION 3.15)
project(SimpleGraphic C CXX)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)

if (APPLE)
    enable_language(OBJCXX)
endif ()

if (MSVC)
    add_compile_options("/Zi")
    add_link_options("/DEBUG:FULL")
endif ()

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

include(${PROJECT_SOURCE_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake)

set(CMAKE_INSTALL_SYSTEM_RUNTIME_DESTINATION ".")
include(InstallRequiredSystemLibraries)
add_subdirectory(dep/glm)

set(SIMPLEGRAPHIC_SOURCES
    "config.h"
    "dep/stb/stb_image.h"
    "dep/stb/stb_image_resize.h"
    "dep/stb/stb_image_write.h"
    "engine/common.h"
    "engine/common/base64.c"
    "engine/common/base64.h"
    "engine/common/common.cpp"
    "engine/common/console.cpp"
    "engine/common/console.h"
    "engine/common/keylist.h"
    "engine/common/memtrak3.cpp"
    "engine/common/memtrak3.h"
    "engine/common/streams.cpp"
    "engine/common/streams.h"
    "engine/core/core_compress.cpp"
    "engine/core/core_compress.h"
    "engine/core/core_config.cpp"
    "engine/core/core_config.h"
    "engine/core/core_image.cpp"
    "engine/core/core_image.h"
    "engine/core/core_main.cpp"
    "engine/core/core_main.h"
    "engine/core/core_tex_manipulation.cpp"
    "engine/core/core_tex_manipulation.h"
    "engine/core/core_video.cpp"
    "engine/core/core_video.h"
    "engine/render/r_font.cpp"
    "engine/render/r_font.h"
    "engine/render/r_main.cpp"
    "engine/render/r_main.h"
    "engine/render/r_texture.cpp"
    "engine/render/r_texture.h"
    "engine/system/win/sys_local.h"
    "engine/system/win/sys_main.cpp"
    "engine/system/win/sys_opengl.cpp"
    "engine/system/win/sys_video.cpp"
    "engine/system/sys_console.h"
    "engine/system/sys_main.h"
    "engine/system/sys_opengl.h"
    "engine/system/sys_video.h"
    "win/entry.cpp"
    "ui.h"
    "ui_api.cpp"
    "ui_console.cpp"
    "ui_console.h"
    "ui_debug.cpp"
    "ui_debug.h"
    "ui_local.h"
    "ui_main.cpp"
    "ui_main.h"
    "ui_subscript.cpp"
    "ui_subscript.h"
)

set (SIMPLEGRAPHIC_PLATFORM_SOURCES)
if (APPLE)
    set (SIMPLEGRAPHIC_PLATFORM_SOURCES
        "engine/system/win/sys_macos.mm"
    )
endif()

if (WIN32)
    list(APPEND SIMPLEGRAPHIC_PLATFORM_SOURCES
        "engine/system/win/sys_console.cpp"
        "SimpleGraphic.rc"
    )
else()
    list(APPEND SIMPLEGRAPHIC_PLATFORM_SOURCES
        "engine/system/win/sys_console_unix.cpp"
    )
endif()

add_library(SimpleGraphic SHARED
    ${SIMPLEGRAPHIC_SOURCES}
    ${SIMPLEGRAPHIC_PLATFORM_SOURCES}
)

if (APPLE)
    add_executable(PathOfBuilding MACOSX_BUNDLE "macos/main.cpp")
    target_link_libraries(PathOfBuilding PRIVATE SimpleGraphic)
    set_target_properties(PathOfBuilding PROPERTIES
        MACOSX_BUNDLE_BUNDLE_NAME "Path of Building Community"
        MACOSX_BUNDLE_GUI_IDENTIFIER "community.pathofbuilding.PathOfBuilding"
        MACOSX_BUNDLE_SHORT_VERSION_STRING "0.1"
        MACOSX_BUNDLE_BUNDLE_VERSION "1"
        BUILD_RPATH "@executable_path/../Frameworks"
        INSTALL_RPATH "@executable_path/../Frameworks"
    )
endif()
target_compile_definitions(SimpleGraphic
    PRIVATE
    "UNICODE"
    "_CRT_SECURE_NO_DEPRECATE"
    "_CRT_SECURE_NO_WARNINGS"
    "_SCL_SECURE_NO_DEPRECATE"
    "_SCL_SECURE_NO_WARNINGS"
    "GLFW_INCLUDE_NONE"
    "GL_SILENCE_DEPRECATION"
    "SIMPLEGRAPHIC_EXPORTS"
)

target_include_directories(SimpleGraphic
    PUBLIC
    "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/engine"
)

if (NOT WIN32)
    target_compile_options(SimpleGraphic PRIVATE
        "$<$<COMPILE_LANGUAGE:C>:-include>"
        "$<$<COMPILE_LANGUAGE:C>:string.h>"
    )
endif()

find_package(unofficial-angle CONFIG REQUIRED)
find_package(CURL CONFIG REQUIRED)
find_package(fmt CONFIG REQUIRED)
find_package(glfw3 CONFIG REQUIRED)
find_package(gli CONFIG REQUIRED)
find_package(LuaJIT REQUIRED)
find_package(Microsoft.GSL CONFIG REQUIRED)
find_package(PkgConfig REQUIRED)
find_package(re2 CONFIG REQUIRED)
find_package(sol2 CONFIG REQUIRED)
find_package(Threads REQUIRED)
find_package(zstd REQUIRED)
find_package(ZLIB REQUIRED)
find_package(WebP)

add_library(cmp_core STATIC
    dep/compressonator/cmp_core/source/cmp_core.cpp
    dep/compressonator/cmp_core/source/cmp_core.h
    dep/compressonator/cmp_core/shaders/bc3_encode_kernel.cpp
    dep/compressonator/cmp_core/shaders/bc7_encode_kernel.cpp
)

target_include_directories(cmp_core PRIVATE
    dep/compressonator/applications/_libs/cmp_math
)

target_include_directories(cmp_core PUBLIC
    dep/compressonator/cmp_core/shaders
    dep/compressonator/cmp_core/source
)

add_library(imgui STATIC
    dep/imgui/imconfig.h
    dep/imgui/imgui.cpp
    dep/imgui/imgui.h
    dep/imgui/imgui_demo.cpp
    dep/imgui/imgui_draw.cpp
    dep/imgui/imgui_internal.h
    dep/imgui/imgui_tables.cpp
    dep/imgui/imgui_widgets.cpp
    dep/imgui/imstb_rectpack.h
    dep/imgui/imstb_textedit.h
    dep/imgui/imstb_truetype.h
    dep/imgui/backends/imgui_impl_glfw.cpp
    dep/imgui/backends/imgui_impl_glfw.h
    dep/imgui/backends/imgui_impl_opengl3.cpp
    dep/imgui/backends/imgui_impl_opengl3.h
    dep/imgui/backends/imgui_impl_opengl3_loader.h
    dep/imgui/misc/cpp/imgui_stdlib.cpp
    dep/imgui/misc/cpp/imgui_stdlib.h
)

target_compile_definitions(imgui PUBLIC
    "IMGUI_IMPL_OPENGL_ES2"
)

target_include_directories(imgui PUBLIC
    dep/imgui
    dep/imgui/backends
    dep/imgui/misc/cpp
)

target_link_libraries(imgui PUBLIC
    unofficial::angle::libGLESv2
    glfw
)

target_include_directories(SimpleGraphic
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/dep/glad/include
    ${CMAKE_CURRENT_SOURCE_DIR}/dep/stb
)

if (CMAKE_SYSTEM_NAME MATCHES "Linux")
    target_link_options(SimpleGraphic
        PRIVATE
        "-export-dynamic"
    )
endif ()

if (WIN32)
    target_compile_options(SimpleGraphic
        PRIVATE
        "/EHa"
    )
    target_compile_definitions(SimpleGraphic
        PRIVATE
        "_CRT_SECURE_NO_DEPRECATE=1"
        "_CRT_SECURE_NO_WARNINGS=1"
        "_SCL_SECURE_NO_DEPRECATE=1"
        "_SCL_SECURE_NO_WARNINGS=1"
    )
    target_link_libraries(SimpleGraphic
        PRIVATE
        "winmm.lib"
    )
endif ()

if (APPLE)
    find_library(CORE_FOUNDATION_LIBRARY CoreFoundation)
    find_library(APPLICATION_SERVICES_LIBRARY ApplicationServices)
    target_link_libraries(SimpleGraphic
        PRIVATE
        ${CORE_FOUNDATION_LIBRARY}
        ${APPLICATION_SERVICES_LIBRARY}
    )
endif ()

target_link_libraries(SimpleGraphic
    PRIVATE
    unofficial::angle::libEGL
    unofficial::angle::libGLESv2
    cmp_core
    fmt::fmt
    glfw
    gli
    glm::glm
    imgui
    LuaJIT::LuaJIT
    Microsoft.GSL::GSL
    re2::re2
    Threads::Threads
    WebP::webpdecoder
    ZLIB::ZLIB
    zstd::libzstd
)

if (APPLE)
    # GLFW loads EGL by its conventional filename at runtime. The vcpkg ANGLE
    # port deliberately gives the library a distinct output name, so provide
    # the filename GLFW expects alongside the build-tree libraries.
    add_custom_command(TARGET PathOfBuilding POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<TARGET_FILE:unofficial::angle::libEGL>"
            "$<TARGET_FILE_DIR:SimpleGraphic>/libEGL.dylib"
    )
endif()

install(FILES $<TARGET_RUNTIME_DLLS:SimpleGraphic> DESTINATION ".")
if (APPLE)
    install(TARGETS SimpleGraphic LIBRARY DESTINATION "PathOfBuilding.app/Contents/Frameworks")
    install(TARGETS PathOfBuilding BUNDLE DESTINATION ".")
else()
    install(TARGETS SimpleGraphic RUNTIME DESTINATION ".")
endif()

if (WIN32)
    set(DEPS_DIR "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")

    if (NOT VCPKG_TARGET_TRIPLET MATCHES "-release")
        find_file(LuaJIT_DLL_DEBUG NAMES "lua51.dll"
            PATHS "${DEPS_DIR}" PATH_SUFFIXES "debug/bin" REQUIRED NO_DEFAULT_PATH)
        find_file(ZLIB_DLL_DEBUG NAMES "zlibd1.dll"
            PATHS "${DEPS_DIR}" PATH_SUFFIXES "debug/bin" REQUIRED NO_DEFAULT_PATH)

        install(FILES
            ${LuaJIT_DLL_DEBUG}
            ${ZLIB_DLL_DEBUG}
            DESTINATION "."
            CONFIGURATIONS Debug
        )
    endif ()

    find_file(LuaJIT_DLL_RELEASE NAMES "lua51.dll"
        PATHS "${DEPS_DIR}" PATH_SUFFIXES "bin" REQUIRED NO_DEFAULT_PATH)
    find_file(ZLIB_DLL_RELEASE NAMES "zlib1.dll"
        PATHS "${DEPS_DIR}" PATH_SUFFIXES "bin" REQUIRED NO_DEFAULT_PATH)

    install(FILES
        ${LuaJIT_DLL_RELEASE}
        ${ZLIB_DLL_RELEASE}
        DESTINATION "."
        CONFIGURATIONS Release MinSizeRel RelWithDebInfo
    )
endif ()


# lcurl module

set(LCURL_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/libs/Lua-cURLv3)
file(GLOB LCURL_SOURCES ${LCURL_SOURCE_DIR}/src/**.c)
add_library(lcurl SHARED ${LCURL_SOURCES})

target_compile_definitions(lcurl
    PRIVATE
    "luaL_setfuncs=lcurl_compat_setfuncs"
)

target_include_directories(lcurl
    PRIVATE
    ${LCURL_SOURCE_DIR}/src
)

target_link_libraries(lcurl
    PRIVATE
    CURL::libcurl
    LuaJIT::LuaJIT
)

install(TARGETS lcurl RUNTIME DESTINATION ".")
install(FILES $<TARGET_RUNTIME_DLLS:lcurl> DESTINATION ".")

# luautf8 module

add_library(lua-utf8 SHARED libs/luautf8/lutf8lib.c)

if (WIN32)
    target_compile_definitions(lua-utf8
        PRIVATE
        LUA_BUILD_AS_DLL
    )
else()
    target_compile_options(lua-utf8 PRIVATE -fms-extensions -include limits.h)
endif ()

target_include_directories(lua-utf8
    PRIVATE
)

target_link_libraries(lua-utf8
    PRIVATE
    LuaJIT::LuaJIT
)

install(TARGETS lua-utf8 RUNTIME DESTINATION ".")
install(FILES $<TARGET_RUNTIME_DLLS:lua-utf8> DESTINATION ".")

# luasocket module

add_library(luasocket SHARED
   "libs/luasocket/src/auxiliar.c"
   "libs/luasocket/src/buffer.c"
   "libs/luasocket/src/compat.c"
   "libs/luasocket/src/except.c"
   "libs/luasocket/src/inet.c"
   "libs/luasocket/src/io.c"
   "libs/luasocket/src/luasocket.c"
   "libs/luasocket/src/options.c"
   "libs/luasocket/src/select.c"
   "libs/luasocket/src/tcp.c"
   "libs/luasocket/src/timeout.c"
   "libs/luasocket/src/udp.c"
)

if (WIN32)
    target_sources(luasocket PRIVATE "libs/luasocket/src/wsocket.c")
else()
    target_sources(luasocket PRIVATE "libs/luasocket/src/usocket.c")
endif()

target_include_directories(luasocket
    PRIVATE
    ${LSOCKET_SOURCE_DIR}/src
)

target_link_libraries(luasocket
    PRIVATE
    LuaJIT::LuaJIT
)

if (WIN32)
    target_link_libraries(luasocket PRIVATE wsock32 ws2_32)
endif()

set_target_properties( luasocket PROPERTIES OUTPUT_NAME "socket" ) 
install(TARGETS luasocket RUNTIME DESTINATION ".")
install(FILES $<TARGET_RUNTIME_DLLS:luasocket> DESTINATION ".")

# lzip module

add_library(lzip SHARED libs/LZip/lzip.cpp)

target_include_directories(lzip
    PRIVATE
)

target_link_libraries(lzip
    PRIVATE
    LuaJIT::LuaJIT
    ZLIB::ZLIB
)

install(TARGETS lzip RUNTIME DESTINATION ".")
install(FILES $<TARGET_RUNTIME_DLLS:lzip> DESTINATION ".")

if (APPLE)
    set(POB_SOURCE_DIR "" CACHE PATH
        "Path to a PathOfBuilding checkout containing src/Launch.lua and runtime")

    if (POB_SOURCE_DIR AND EXISTS "${POB_SOURCE_DIR}/src/Launch.lua")
        set(POB_STANDALONE_DIR "${CMAKE_BINARY_DIR}/standalone")
        set(POB_STANDALONE_APP "${POB_STANDALONE_DIR}/Path of Building.app")
        set(POB_STANDALONE_ARCHIVE "${POB_STANDALONE_DIR}/Path-of-Building-macOS.zip")
        set(POB_VCPKG_LIBRARY_DIR
            "$<IF:$<CONFIG:Debug>,${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib,${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib>")

        add_custom_target(PathOfBuildingStandalone
            COMMAND ${CMAKE_COMMAND}
                "-DSOURCE_APP=$<TARGET_BUNDLE_DIR:PathOfBuilding>"
                "-DOUTPUT_APP=${POB_STANDALONE_APP}"
                "-DPOB_SOURCE_DIR=${POB_SOURCE_DIR}"
                "-DVCPKG_LIBRARY_DIR=${POB_VCPKG_LIBRARY_DIR}"
                "-DSIMPLEGRAPHIC_LIBRARY=$<TARGET_FILE:SimpleGraphic>"
                "-DEGL_LIBRARY=$<TARGET_FILE:unofficial::angle::libEGL>"
                "-DLCURL_MODULE=$<TARGET_FILE:lcurl>"
                "-DLZIP_MODULE=$<TARGET_FILE:lzip>"
                "-DLUA_UTF8_MODULE=$<TARGET_FILE:lua-utf8>"
                "-DSOCKET_MODULE=$<TARGET_FILE:luasocket>"
                -P "${CMAKE_CURRENT_SOURCE_DIR}/macos/Bundle.cmake"
            DEPENDS PathOfBuilding lcurl lzip lua-utf8 luasocket
            COMMENT "Assembling standalone Path of Building.app"
            VERBATIM
        )

        add_custom_target(PathOfBuildingStandaloneArchive
            COMMAND ${CMAKE_COMMAND} -E tar cf "${POB_STANDALONE_ARCHIVE}"
                --format=zip "Path of Building.app"
            WORKING_DIRECTORY "${POB_STANDALONE_DIR}"
            DEPENDS PathOfBuildingStandalone
            COMMENT "Creating ${POB_STANDALONE_ARCHIVE}"
            VERBATIM
        )
    else()
        message(STATUS
            "Set POB_SOURCE_DIR to a PathOfBuilding checkout to enable the standalone macOS bundle targets")
    endif()
endif()
