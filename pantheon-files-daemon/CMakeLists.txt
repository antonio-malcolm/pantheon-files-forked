# Vala stuff

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/..)
include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../libcore/)
include_directories(${CMAKE_CURRENT_BINARY_DIR}/../libwidgets/)
find_package(PkgConfig)
pkg_check_modules(DEPS REQUIRED
	glib-2.0>=2.29.0
	gthread-2.0
	gio-2.0
	pango>=1.1.2
	gtk+-3.0>=3.0.3
	gail-3.0
	gee-0.8
	sqlite3
    dbus-glib-1
	libnotify>=0.7.2)
set(CFLAGS
	${DEPS_CFLAGS} ${DEPS_CFLAGS_OTHER}
)
set(LIB_PATHS
	${DEPS_LIBRARY_DIRS}
)
link_directories(${LIB_PATHS})
add_definitions(${CFLAGS})

vala_precompile(VALA_C pantheon-files-daemon
    marlind-tagging.vala
PACKAGES
    gtk+-3.0
    gio-2.0
    gee-0.8
    sqlite3
OPTIONS
    --thread)
add_executable(pantheon-files-daemon
    ${VALA_C} )
target_link_libraries(pantheon-files-daemon ${DEPS_LIBRARIES})
install(TARGETS pantheon-files-daemon RUNTIME DESTINATION bin)
