# - Find CGAL
# Find the FASTJET includes and client library
# This module defines
#  FASTJET_INCLUDE_DIR, where to find PseudoJet.hh
#  FASTJET_LIBRARIES, the libraries needed to use CGAL.
#  FASTJET_FOUND, If false, do not try to use CGAL.

if(FASTJET_INCLUDE_DIR AND FASTJET_LIBRARIES)
   set(FASTJET_FOUND TRUE)
else(FASTJET_INCLUDE_DIR AND FASTJET_LIBRARIES)
  message(STATUS "Looking for FastJet with fastjet-config...")
  find_program ( FASTJETCONFIG fastjet-config PATHS $ENV{FASTJET_DIR}/bin ${FASTJET_HEPPY_BUILD}/bin)
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
      message(STATUS "${Green}FastJet python module subdir: ${FASTJET_PYTHON_SUBDIR}${ColourReset}")

      message(STATUS "${Green}FastJet python module shared lib: ${FASTJET_PYTHON_SO}${ColourReset}")
      get_filename_component(FASTJET_PYTHON_SO_SUBDIR ${FASTJET_PYTHON_SO} DIRECTORY)
      message(STATUS "${Green}FastJet python so subdir: ${FASTJET_PYTHON_SO_SUBDIR}${ColourReset}")

      execute_process( COMMAND ${Python3_EXECUTABLE} -c "import sys; sys.path.append('${FASTJET_PYTHON_SUBDIR}'); sys.path.append('${FASTJET_PYTHON_SO_SUBDIR}'); import fastjet; fastjet.ClusterSequence.print_banner();" WORKING_DIRECTORY /tmp 
                        RESULT_VARIABLE LOAD_FASTJET_PYTHON_RESULT 
                        OUTPUT_VARIABLE LOAD_FASTJET_PYTHON 
                        ERROR_VARIABLE LOAD_FASTJET_PYTHON_ERROR 
                        OUTPUT_STRIP_TRAILING_WHITESPACE )
      if (LOAD_FASTJET_PYTHON_ERROR)
        message(STATUS "${Red}Loading FastJet python module - result:[${LOAD_FASTJET_PYTHON_RESULT}] - failure!${ColourReset}")
        message(STATUS "${Red}Loading FastJet python module FAILED:\n ${LOAD_FASTJET_PYTHON_ERROR}${ColourReset}")
      else(LOAD_FASTJET_PYTHON_ERROR)
        message(STATUS "${Green}Loading FastJet python module - result:[${LOAD_FASTJET_PYTHON_RESULT}] - success!${ColourReset}")
        message("${LOAD_FASTJET_PYTHON}")
        set(FASTJET_LIBRARIES ${FASTJET_LIBS})
        set(FASTJET_INCLUDE_DIR ${FASTJET_CXXFLAGS})
      endif(LOAD_FASTJET_PYTHON_ERROR)      
    else (FASTJET_PYTHON AND FASTJET_PYTHON_SO)
      message(STATUS "${Red}Missing fastjet python [${FASTJET_PYTHON}] or python so [${FASTJET_PYTHON_SO}]${ColourReset}")
    endif (FASTJET_PYTHON AND FASTJET_PYTHON_SO)  
  else(EXISTS ${FASTJETCONFIG})
    message(STATUS "${Yellow}Hint: fastjet-config not in \$PATH nor in \${FASTJET_DIR}/bin${ColourReset}")
  endif()
  mark_as_advanced(FASTJET_INCLUDE_DIR FASTJET_LIBRARIES)
endif(FASTJET_INCLUDE_DIR AND FASTJET_LIBRARIES)

if(FASTJET_INCLUDE_DIR AND FASTJET_LIBRARIES)
  set(FASTJET_FOUND TRUE)
  message(STATUS "${Green}FASTJET ver. ${FASTJET_VERSION}${ColourReset}")
else(FASTJET_INCLUDE_DIR AND FASTJET_LIBRARIES)
  set(FASTJET_FOUND FALSE)
endif(FASTJET_INCLUDE_DIR AND FASTJET_LIBRARIES)
