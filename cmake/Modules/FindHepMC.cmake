# - Locate HepMC library
# Defines:
#
#  HEPMC_FOUND
#  HEPMC_INCLUDE_DIR
#  HEPMC_INCLUDE_DIRS (not cached)
#  HEPMC_<component>_LIBRARY
#  HEPMC_LIBRARIES (not cached)
#  HEPMC_LIBRARY_DIRS (not cached)

if (NOT HEPMC_DIR)
  set(HEPMC2_DIR ${CMAKE_HEPPY_DIR}/external/hepmc2/hepmc2-current)
  message(STATUS "Setting HEPMC2_DIR to ${HEPMC2_DIR}")
endif(NOT HEPMC_DIR)

find_path(HEPMC_INCLUDE_DIR HepMC/GenEvent.h HINTS $ENV{HEPMC_DIR}/include $ENV{HEPMC2_DIR}/include ${HEPMC2_DIR}/include )
set(HEPMC_INCLUDE_DIRS ${HEPMC_INCLUDE_DIR})
get_filename_component(HEPMC_DIR ${HEPMC_INCLUDE_DIR} DIRECTORY)

if(NOT HEPMC_FIND_COMPONENTS)
  set(HEPMC_FIND_COMPONENTS HepMC)
endif()
foreach(component ${HEPMC_FIND_COMPONENTS})
  find_library(HEPMC_${component}_LIBRARY NAMES HepMC${component} ${component} HINTS $ENV{HEPMC_DIR}/lib $ENV{HEPMC2_DIR}/lib ${HEPMC2_DIR}/lib)
  list(APPEND HEPMC_LIBRARIES ${HEPMC_${component}_LIBRARY})
  get_filename_component(_comp_dir ${HEPMC_${component}_LIBRARY} PATH)
  list(APPEND HEPMC_LIBRARY_DIRS ${_comp_dir})

  set(HEPMC_LIB_DIR ${HEPMC_LIBRARY_DIRS})

  find_library(COMP NAMES ${component} HINTS $ENV{HEPMC_DIR}/lib $ENV{HEPMC2_DIR}/lib ${HEPMC2_DIR}/lib)
  if (COMP)
  	list(APPEND HEPMC_LINKS ${component})
  endif(COMP)
endforeach(component ${HEPMC_FIND_COMPONENTS})

if(HEPMC_LIBRARY_DIRS)
  list(REMOVE_DUPLICATES HEPMC_LIBRARY_DIRS)
  set(HEPMC_LINK_LIBRARIES "-Wl,-rpath,${HEPMC_LIBRARY_DIRS} -L${HEPMC_LIBRARY_DIRS}")
  foreach(comp ${HEPMC_LINKS})
	  set(HEPMC_LINK_LIBRARIES "${HEPMC_LINK_LIBRARIES} -l${comp}")
  endforeach()
endif()

# handle the QUIETLY and REQUIRED arguments and set HEPMC_FOUND to TRUE if
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(HepMC DEFAULT_MSG HEPMC_DIR HEPMC_INCLUDE_DIR HEPMC_LIBRARIES HEPMC_LIB_DIR)

if (HEPMC_FOUND)
  message(STATUS "${Green}HEPMC2 found ${HEPMC_DIR} ${ColourReset}")
  add_definitions(-DUSE_HEPMC)
else(HEPMC_FOUND)
  message(STATUS "${Yellow}HEPMC2 not found - some of the functionality will be misssing.${ColourReset}")
endif(HEPMC_FOUND)
