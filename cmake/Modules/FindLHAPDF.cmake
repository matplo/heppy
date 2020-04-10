# - Try to find LHAPDF6
# Defines:
#
#  LHAPDF6_FOUND
#  LHAPDF6_INCLUDE_DIR
#  LHAPDF6_INCLUDE_DIRS (not cached)
#  LHAPDF6_LIBRARY
#  LHAPDF6_LIBRARIES (not cached)
#  LHAPDF6_LIBRARY_DIRS (not cached)

if (NOT LHAPDF6_DIR)
  set(LHAPDF6_DIR ${CMAKE_HEPPY_DIR}/external/lhapdf6/lhapdf6-current)
  message(STATUS "Setting LHAPDF6_DIR to ${LHAPDF6_DIR}")
endif(NOT LHAPDF6_DIR)

find_library(LHAPDF6_LIBRARY NAMES LHAPDF
             HINTS $ENV{LHAPDF6_ROOT_DIR}/lib ${LHAPDF6_ROOT_DIR}/lib $ENV{LHAPDF6_DIR}/lib ${LHAPDF6_DIR}/lib)

find_path(LHAPDF6_INCLUDE_DIR LHAPDF/LHAPDF.h
          HINTS $ENV{LHAPDF6_ROOT_DIR}/include ${LHAPDF6_ROOT_DIR}/include HINTS $ENV{LHAPDF6_DIR}/include ${LHAPDF6_DIR}/include)

get_filename_component(LHAPDF6_DIR ${LHAPDF6_INCLUDE_DIR} DIRECTORY)
mark_as_advanced(LHAPDF6_DIR LHAPDF6_INCLUDE_DIR LHAPDF6_LIBRARY)

# handle the QUIETLY and REQUIRED arguments and set LHAPDF6_FOUND to TRUE if
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(LHAPDF6 DEFAULT_MSG LHAPDF6_DIR LHAPDF6_INCLUDE_DIR LHAPDF6_LIBRARY)

set(LHAPDF6_LIBRARIES ${LHAPDF6_LIBRARY})
get_filename_component(LHAPDF6_LIBRARY_DIRS ${LHAPDF6_LIBRARY} PATH)

set(LHAPDF6_INCLUDE_DIRS ${LHAPDF6_INCLUDE_DIR})
get_filename_component(LHAPDF6_DIR ${LHAPDF6_INCLUDE_DIR} DIRECTORY)

mark_as_advanced(LHAPDF6_FOUND)

if (LHAPDF6_FOUND)
    execute_process (COMMAND ${LHAPDF6_DIR}/bin/lhapdf-config --version WORKING_DIRECTORY /tmp OUTPUT_VARIABLE LHAPDF6_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE )
	message(STATUS "${Green}LHAPDF ver. ${LHAPDF6_VERSION} ${ColourReset}")
else(LHAPDF6_FOUND)
  message(STATUS "${Yellow}LHAPDF6 not found - some of the functionality will be missing.${ColourReset}")	
endif (LHAPDF6_FOUND)
