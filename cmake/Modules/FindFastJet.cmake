# - Find CGAL
# Find the FASTJET includes and client library
# This module defines
#  FASTJET_INCLUDE_DIR, where to find PseudoJet.hh
#  FASTJET_LIBRARIES, the libraries needed to use CGAL.
#  FASTJET_FOUND, If false, do not try to use CGAL.

if (NOT FASTJET_DIR)
  find_program ( FASTJETCONFIG fastjet-config PATHS $ENV{FASTJET_DIR}/bin ${FASTJET_DIR}/bin)
  if (NOT EXISTS ${FASTJETCONFIG})
    set(FASTJET_DIR "${CMAKE_HEPPY_DIR}/external/fastjet/fastjet-current")
    message(STATUS "Setting FASTJET_DIR to ${FASTJET_DIR}")
  endif(NOT EXISTS ${FASTJETCONFIG})
endif(NOT FASTJET_DIR)

if(FASTJET_INCLUDE_DIR AND FASTJET_LIBRARIES)
   set(FASTJET_FOUND TRUE)
else(FASTJET_INCLUDE_DIR AND FASTJET_LIBRARIES)
  message(STATUS "Looking for FastJet with fastjet-config...")
  find_program ( FASTJETCONFIG fastjet-config PATHS $ENV{FASTJET_DIR}/bin ${FASTJET_DIR}/bin)
  if (EXISTS ${FASTJETCONFIG})
    message(STATUS "Using fastjet-config at ${FASTJETCONFIG}")
    execute_process ( COMMAND ${FASTJETCONFIG} --prefix WORKING_DIRECTORY /tmp OUTPUT_VARIABLE FASTJET_DIR OUTPUT_STRIP_TRAILING_WHITESPACE )
    execute_process ( COMMAND ${FASTJETCONFIG} --cxxflags WORKING_DIRECTORY /tmp OUTPUT_VARIABLE FASTJET_CXXFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE )
    execute_process ( COMMAND ${FASTJETCONFIG} --libs --plugins WORKING_DIRECTORY /tmp OUTPUT_VARIABLE FASTJET_LIBS OUTPUT_STRIP_TRAILING_WHITESPACE )
    execute_process ( COMMAND ${FASTJETCONFIG} --version WORKING_DIRECTORY /tmp OUTPUT_VARIABLE FASTJET_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE )
    execute_process ( COMMAND find -L ${FASTJET_DIR} -name "fastjet.py" WORKING_DIRECTORY /tmp OUTPUT_VARIABLE FASTJET_PYTHON OUTPUT_STRIP_TRAILING_WHITESPACE )
    execute_process ( COMMAND find -L ${FASTJET_DIR} -name "_fastjet.so" WORKING_DIRECTORY /tmp OUTPUT_VARIABLE FASTJET_PYTHON_SO OUTPUT_STRIP_TRAILING_WHITESPACE )
    if (FASTJET_PYTHON AND FASTJET_PYTHON_SO)
      message(STATUS "${Green}FastJet python module: ${FASTJET_PYTHON}${ColourReset}")
      get_filename_component(FASTJET_PYTHON_SUBDIR ${FASTJET_PYTHON} DIRECTORY)
      #message(STATUS "${Green}FastJet python module subdir: ${FASTJET_PYTHON_SUBDIR}${ColourReset}")

      #message(STATUS "${Green}FastJet python module shared lib: ${FASTJET_PYTHON_SO}${ColourReset}")
      get_filename_component(FASTJET_PYTHON_SO_SUBDIR ${FASTJET_PYTHON_SO} DIRECTORY)
      #message(STATUS "${Green}FastJet python so subdir: ${FASTJET_PYTHON_SO_SUBDIR}${ColourReset}")

      message(STATUS "python exec ${Python_EXECUTABLE}")
      execute_process( COMMAND ${Python_EXECUTABLE} -c "import sys; sys.path.append('${FASTJET_PYTHON_SUBDIR}'); sys.path.append('${FASTJET_PYTHON_SO_SUBDIR}'); import fastjet; fastjet.ClusterSequence.print_banner();" WORKING_DIRECTORY /tmp 
                        RESULT_VARIABLE LOAD_FASTJET_PYTHON_RESULT 
                        OUTPUT_VARIABLE LOAD_FASTJET_PYTHON 
                        ERROR_VARIABLE LOAD_FASTJET_PYTHON_ERROR 
                        OUTPUT_STRIP_TRAILING_WHITESPACE )
      if (LOAD_FASTJET_PYTHON_ERROR)
        message(STATUS "${Red}Loading FastJet python module - result:[${LOAD_FASTJET_PYTHON_RESULT}] - failure!${ColourReset}")
        message(STATUS "${Red}Loading FastJet python module FAILED:\n ${LOAD_FASTJET_PYTHON_ERROR}${ColourReset}")
        message(STATUS "${Yellow}Potential issue (needing a fix): previous compilation left over - changing python version? look for multiple ${FASTJET_DIR}/lib/python3.X${ColourReset}")
      else(LOAD_FASTJET_PYTHON_ERROR)
        message(STATUS "${Green}Loading FastJet python module - result:[${LOAD_FASTJET_PYTHON_RESULT}] - success!${ColourReset}")
        message("${LOAD_FASTJET_PYTHON}")
        set(FASTJET_LIBRARIES ${FASTJET_LIBS})
        set(FASTJET_INCLUDE_DIR ${FASTJET_CXXFLAGS})
        set(FASTJET_FOUND TRUE)
      endif(LOAD_FASTJET_PYTHON_ERROR)      
    else (FASTJET_PYTHON AND FASTJET_PYTHON_SO)
      message(STATUS "${Red}Missing fastjet python [${FASTJET_PYTHON}] or python so [${FASTJET_PYTHON_SO}]${ColourReset}")
    endif (FASTJET_PYTHON AND FASTJET_PYTHON_SO)  
  else(EXISTS ${FASTJETCONFIG})
    message(STATUS "${Yellow}Hint: fastjet-config not in \$PATH nor in \${FASTJET_DIR}/bin${ColourReset}")
  endif()
  mark_as_advanced(FASTJET_INCLUDE_DIR FASTJET_LIBRARIES FASTJET_DIR)
endif(FASTJET_INCLUDE_DIR AND FASTJET_LIBRARIES)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(FastJet DEFAULT_MSG FASTJET_DIR FASTJET_INCLUDE_DIR FASTJET_LIBRARIES)

if(FASTJET_FOUND)
  message(STATUS "${Green}FASTJET ver. ${FASTJET_VERSION}${ColourReset}")
endif(FASTJET_FOUND)
