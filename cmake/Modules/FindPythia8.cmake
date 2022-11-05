# - Find CGAL
# Find the PYTHIA8 includes and client library
# This module defines
#  PYTHIA8_INCLUDE_DIR, where to find PseudoJet.hh
#  PYTHIA8_LIBRARIES, the libraries needed to use CGAL.
#  PYTHIA8_FOUND, If false, do not try to use CGAL.

if (NOT PYTHIA8_DIR)
  find_program ( PYTHIA8CONFIG pythia8-config PATHS $ENV{PYTHIA8_DIR}/bin ${PYTHIA8_DIR}/bin)
  if (NOT EXISTS ${PYTHIA8CONFIG})
    set(PYTHIA8_DIR "${CMAKE_HEPPY_DIR}/external/pythia8/pythia8-current")
    message(STATUS "Setting PYTHIA8_DIR to ${PYTHIA8_DIR}")
  endif(NOT EXISTS ${PYTHIA8CONFIG})
endif(NOT PYTHIA8_DIR)

if(PYTHIA8_INCLUDE_DIR AND PYTHIA8_LIBRARIES)
   set(PYTHIA8_FOUND TRUE)
else(PYTHIA8_INCLUDE_DIR AND PYTHIA8_LIBRARIES)
  message(STATUS "Looking for Pythia8 with pythia8-config...")
  find_program ( PYTHIA8CONFIG pythia8-config PATHS $ENV{PYTHIA8_DIR}/bin ${PYTHIA8_DIR}/bin)
  if (EXISTS ${PYTHIA8CONFIG})
    message(STATUS "Using pythia8-config at ${PYTHIA8CONFIG}")
    execute_process ( COMMAND ${PYTHIA8CONFIG} --prefix WORKING_DIRECTORY /tmp OUTPUT_VARIABLE PYTHIA8_DIR OUTPUT_STRIP_TRAILING_WHITESPACE )
    execute_process ( COMMAND ${PYTHIA8CONFIG} --cxxflags WORKING_DIRECTORY /tmp OUTPUT_VARIABLE PYTHIA8_CXXFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE )
    execute_process ( COMMAND ${PYTHIA8CONFIG} --ldflags WORKING_DIRECTORY /tmp OUTPUT_VARIABLE PYTHIA8_LDFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE )
    set(PYTHIA8_LIBRARIES ${PYTHIA8_LDFLAGS})
    set(PYTHIA8_INCLUDE_DIR ${PYTHIA8_CXXFLAGS})
    message( STATUS "Pythia8 dir set to ${PYTHIA8_DIR}")
    execute_process ( COMMAND find -L ${PYTHIA8_DIR} -name "pythia8.py" WORKING_DIRECTORY /tmp OUTPUT_VARIABLE PYTHIA8_PYTHON OUTPUT_STRIP_TRAILING_WHITESPACE )
    if (PYTHIA8_PYTHON)
      message(STATUS "${Green}Pythia8 python module: ${PYTHIA8_PYTHON}${ColourReset}")
      string(REPLACE "${PYTHIA8_DIR}/" "" FJPYSUBDIR_TMP "${PYTHIA8_PYTHON}")
      string(REPLACE "/pythia8.py" "" PYTHIA8_PYTHON_SUBDIR ${PYTHIA8_PYTHON})
      #message(STATUS "${Green}Pythia8 python module subdir: ${PYTHIA8_PYTHON_SUBDIR}${ColourReset}")
      execute_process( COMMAND ${Python_EXECUTABLE} -c "import sys; sys.path.append('${PYTHIA8_PYTHON_SUBDIR}'); import pythia8; pythia = pythia8.Pythia();" WORKING_DIRECTORY /tmp 
                        RESULT_VARIABLE LOAD_PYTHIA8_PYTHON_RESULT 
                        OUTPUT_VARIABLE LOAD_PYTHIA8_PYTHON 
                        ERROR_VARIABLE LOAD_PYTHIA8_PYTHON_ERROR 
                        OUTPUT_STRIP_TRAILING_WHITESPACE )
      if (LOAD_PYTHIA8_PYTHON_ERROR)
        message(STATUS "${Red}Loading Pythia8 python module - result:[${LOAD_PYTHIA8_PYTHON_RESULT}] - failure!${ColourReset}")
        message(SEND_ERROR " ${Red}Loading Pythia8 python module FAILED:\n ${LOAD_PYTHIA8_PYTHON_ERROR}${ColourReset}")
      else(LOAD_PYTHIA8_PYTHON_ERROR)
        message(STATUS "${Green}Loading Pythia8 python module - result:[${LOAD_PYTHIA8_PYTHON_RESULT}] - success!${ColourReset}")
        message("${LOAD_PYTHIA8_PYTHON}")
        set(PYTHIA8_FOUND TRUE)
      endif(LOAD_PYTHIA8_PYTHON_ERROR)
    else(PYTHIA8_PYTHON)
      message(STATUS " ${Yellow}Pythia8 python module missing - trying direct load${ColourReset}")
      execute_process( COMMAND ${Python_EXECUTABLE} -c "import pythia8; pythia = pythia8.Pythia();" WORKING_DIRECTORY /tmp 
                        RESULT_VARIABLE LOAD_PYTHIA8_PYTHON_RESULT 
                        OUTPUT_VARIABLE LOAD_PYTHIA8_PYTHON 
                        ERROR_VARIABLE LOAD_PYTHIA8_PYTHON_ERROR 
                        OUTPUT_STRIP_TRAILING_WHITESPACE )
      if (LOAD_PYTHIA8_PYTHON_ERROR)
        message(STATUS "${Red}Loading Pythia8 python module - result:[${LOAD_PYTHIA8_PYTHON_RESULT}] - failure!${ColourReset}")
        message(SEND_ERROR " ${Red}Loading Pythia8 python module FAILED:\n ${LOAD_PYTHIA8_PYTHON_ERROR}${ColourReset}")
      else(LOAD_PYTHIA8_PYTHON_ERROR)
        message(STATUS "${Green}Loading Pythia8 python module - result:[${LOAD_PYTHIA8_PYTHON_RESULT}] - success!${ColourReset}")
        message("${LOAD_PYTHIA8_PYTHON}")
        set(PYTHIA8_FOUND TRUE)
      endif(LOAD_PYTHIA8_PYTHON_ERROR)
    endif(PYTHIA8_PYTHON)  
  else()
    message(STATUS "${Yellow}Pythia8 search requires pythia8-config in \$PATH${ColourReset}")
  endif()
  get_filename_component(PYTHIA8_DIR ${PYTHIA8_INCLUDE_DIR} DIRECTORY)
  string(REPLACE "-I" "" PYTHIA8_DIR ${PYTHIA8_DIR})
  mark_as_advanced(PYTHIA8_INCLUDE_DIR PYTHIA8_LIBRARIES PYTHIA8_DIR)
endif(PYTHIA8_INCLUDE_DIR AND PYTHIA8_LIBRARIES)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Pythia8 DEFAULT_MSG PYTHIA8_DIR PYTHIA8_INCLUDE_DIR PYTHIA8_LIBRARIES)

if(NOT PYTHIA8_FOUND)
  message(STATUS "${Yellow}Pythia8 not found - some of the functionality will be missing.${ColourReset}")
endif(NOT PYTHIA8_FOUND)