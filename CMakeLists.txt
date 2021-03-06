# Check http://elementaryos.org/docs/developer-guide/cmake for documentation

cmake_minimum_required (VERSION 2.6)
cmake_policy (VERSION 2.6)
project (pantheon-files C)
enable_testing ()

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
set (GETTEXT_PACKAGE "pantheon-files")
set (PIXMAP_DIR "${CMAKE_INSTALL_PREFIX}/share/pixmaps/pantheon-files/")
set (GNOMELOCALEDIR "${CMAKE_INSTALL_PREFIX}/share/locale/")
set (PLUGIN_DIR "${CMAKE_INSTALL_PREFIX}/lib/pantheon-files/plugins/")
set (UI_DIR "${CMAKE_INSTALL_PREFIX}/share/pantheon-files/ui/")
set (PACKAGE_VERSION 0.2.0)
set (VERSION 0.2.0)
configure_file (${CMAKE_SOURCE_DIR}/config.h.cmake ${CMAKE_BINARY_DIR}/config.h)

add_definitions ("-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")
add_definitions ("-w")

option (LIB_ONLY "Build libcore and libwidgets only" FALSE)

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.26" MINIMUM)
include (ValaPrecompile)

IF (LIB_ONLY)
    add_subdirectory (libcore)
    add_subdirectory (libwidgets)
ELSE ()
    add_subdirectory (src)
    add_subdirectory (data)
    add_subdirectory (pantheon-files-daemon)
    add_subdirectory (libcore)
    add_subdirectory (libwidgets)
    add_subdirectory (plugins)
    add_subdirectory (po)
ENDIF (LIB_ONLY)
