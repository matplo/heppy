# - Locate RooUnfold library
# Defines:
#
#  ROOUNFOLD_FOUND
#  ROOUNFOLD_INCLUDE_DIR
#  ROOUNFOLD_INCLUDE_DIRS (not cached)
#  ROOUNFOLD_<component>_LIBRARY
#  ROOUNFOLD_LIBRARIES (not cached)
#  ROOUNFOLD_LIBRARY_DIRS (not cached)

message(STATUS "Looking for RooUnfold...")

if (NOT ROOUNFOLD_DIR)
  set(ROOUNFOLDHINT_DIR ${CMAKE_HEPPY_DIR}/external/roounfold/roounfold-current)
  message(STATUS "Setting ROOUNFOLDHINT_DIR to ${ROOUNFOLDHINT_DIR}")
endif(NOT ROOUNFOLD_DIR)

find_path(ROOUNFOLD_INCLUDE_DIR RooUnfold.h HINTS $ENV{ROOUNFOLD_DIR}/include $ENV{ROOUNFOLDHINT_DIR}/include ${ROOUNFOLDHINT_DIR}/include )
set(ROOUNFOLD_INCLUDE_DIRS ${ROOUNFOLD_INCLUDE_DIR})
get_filename_component(ROOUNFOLD_DIR ${ROOUNFOLD_INCLUDE_DIR} DIRECTORY)

if(NOT ROOUNFOLD_FIND_COMPONENTS)
  set(ROOUNFOLD_FIND_COMPONENTS RooUnfold)
endif()
foreach(component ${ROOUNFOLD_FIND_COMPONENTS})
  find_library(ROOUNFOLD_${component}_LIBRARY NAMES RooUnfold${component} ${component} HINTS $ENV{ROOUNFOLD_DIR}/lib $ENV{ROOUNFOLDHINT_DIR}/lib ${ROOUNFOLDHINT_DIR}/lib)
  list(APPEND ROOUNFOLD_LIBRARIES ${ROOUNFOLD_${component}_LIBRARY})
  get_filename_component(_comp_dir ${ROOUNFOLD_${component}_LIBRARY} PATH)
  list(APPEND ROOUNFOLD_LIBRARY_DIRS ${_comp_dir})

  set(ROOUNFOLD_LIB_DIR ${ROOUNFOLD_LIBRARY_DIRS})

  find_library(COMP NAMES ${component} HINTS $ENV{ROOUNFOLD_DIR}/lib $ENV{ROOUNFOLDHINT_DIR}/lib ${ROOUNFOLDHINT_DIR}/lib)
  if (COMP)
    list(APPEND ROOUNFOLD_LINKS ${component})
  endif(COMP)
endforeach(component ${ROOUNFOLD_FIND_COMPONENTS})

if(ROOUNFOLD_LIBRARY_DIRS)
  list(REMOVE_DUPLICATES ROOUNFOLD_LIBRARY_DIRS)
  set(ROOUNFOLD_LINK_LIBRARIES "-Wl,-rpath,${ROOUNFOLD_LIBRARY_DIRS} -L${ROOUNFOLD_LIBRARY_DIRS}")
  foreach(comp ${ROOUNFOLD_LINKS})
    set(ROOUNFOLD_LINK_LIBRARIES "${ROOUNFOLD_LINK_LIBRARIES} -l${comp}")
  endforeach()
endif()

# handle the QUIETLY and REQUIRED arguments and set ROOUNFOLD_FOUND to TRUE if
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(RooUnfold DEFAULT_MSG ROOUNFOLD_DIR ROOUNFOLD_INCLUDE_DIR ROOUNFOLD_LIBRARIES ROOUNFOLD_LIB_DIR)

if (ROOUNFOLD_FOUND)
  message(STATUS "${Green}RooUnfold found ${ROOUNFOLD_DIR} ${ColourReset}")
else(ROOUNFOLD_FOUND)
  message(STATUS "${Yellow}RooUnfold not found - some of the functionality will be misssing.${ColourReset}")
endif(ROOUNFOLD_FOUND)
