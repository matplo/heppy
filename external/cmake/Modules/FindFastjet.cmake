# - Find CGAL
# Find the FASTJET includes and client library
# This module defines
#  FASTJET_INCLUDE_DIR, where to find PseudoJet.hh
#  FASTJET_LIBRARIES, the libraries needed to use CGAL.
#  FASTJET_FOUND, If false, do not try to use CGAL.

if(FASTJET_INCLUDE_DIR AND FASTJET_LIBRARIES)
   set(FASTJET_FOUND TRUE)
else(FASTJET_INCLUDE_DIR AND FASTJET_LIBRARIES)
  find_program ( FASTJETCONFIG fastjet-config )
  if (EXISTS ${FASTJETCONFIG})
    message(STATUS "Using fastjet-config at ${FASTJETCONFIG}")
    execute_process ( COMMAND ${FASTJETCONFIG} --prefix WORKING_DIRECTORY /tmp OUTPUT_VARIABLE FASTJET_DIR OUTPUT_STRIP_TRAILING_WHITESPACE )
    execute_process ( COMMAND ${FASTJETCONFIG} --cxxflags WORKING_DIRECTORY /tmp OUTPUT_VARIABLE FASTJET_CXXFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE )
    execute_process ( COMMAND ${FASTJETCONFIG} --libs --plugins WORKING_DIRECTORY /tmp OUTPUT_VARIABLE FASTJET_LIBS OUTPUT_STRIP_TRAILING_WHITESPACE )
    execute_process ( COMMAND ${FASTJETCONFIG} --version WORKING_DIRECTORY /tmp OUTPUT_VARIABLE FASTJET_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE )
    # message( STATUS "FASTJET_VERSION: ${FASTJET_VERSION}")
    # message( STATUS "FASTJET_DIR: ${FASTJET_DIR}")
    # message( STATUS "FASTJET_CXXFLAGS: ${FASTJET_CXXFLAGS}")
    # message( STATUS "FASTJET_LIBS: ${FASTJET_LIBS}")
    # set(SCOMMAND "${FASTJETCONFIG} --libs | cut -f 1 -d' ' | cut -f 3 -d','")
    execute_process ( COMMAND find ${FASTJET_DIR} -name "fastjet.py" WORKING_DIRECTORY /tmp OUTPUT_VARIABLE FASTJET_PYTHON OUTPUT_STRIP_TRAILING_WHITESPACE )
    if (FASTJET_PYTHON)
      message(STATUS "${Green}FastJet python module: ${FASTJET_PYTHON}${ColourReset}")
      string(REPLACE "${FASTJET_DIR}/" "" FJPYSUBDIR_TMP "${FASTJET_PYTHON}")
      #string(REPLACE "/fastjet.py" "" FASTJET_PYTHON_SUBDIR ${FJPYSUBDIR_TMP})
      string(REPLACE "/fastjet.py" "" FASTJET_PYTHON_SUBDIR ${FASTJET_PYTHON})
      message(STATUS "${Green}FastJet python module subdir: ${FASTJET_PYTHON_SUBDIR}${ColourReset}")
      execute_process( COMMAND python -c "import sys; sys.path.append('${FASTJET_PYTHON_SUBDIR}'); import fastjet; fastjet.ClusterSequence.print_banner();" WORKING_DIRECTORY /tmp 
                        RESULT_VARIABLE LOAD_FASTJET_PYTHON_RESULT 
                        OUTPUT_VARIABLE LOAD_FASTJET_PYTHON 
                        ERROR_VARIABLE LOAD_FASTJET_PYTHON_ERROR 
                        OUTPUT_STRIP_TRAILING_WHITESPACE )
      if (LOAD_FASTJET_PYTHON_ERROR)
        message(STATUS "${Red}Loading FastJet python module - result:[${LOAD_FASTJET_PYTHON_RESULT}] - failure!${ColourReset}")
        message(SEND_ERROR " ${Red}Loading FastJet python module FAILED:\n ${LOAD_FASTJET_PYTHON_ERROR}${ColourReset}")
      else(LOAD_FASTJET_PYTHON_ERROR)
        message(STATUS "${Green}Loading FastJet python module - result:[${LOAD_FASTJET_PYTHON_RESULT}] - success!${ColourReset}")
        message("${LOAD_FASTJET_PYTHON}")
        set(FASTJET_LIBRARIES ${FASTJET_LIBS})
        set(FASTJET_INCLUDE_DIR ${FASTJET_CXXFLAGS})
      endif(LOAD_FASTJET_PYTHON_ERROR)      
    else()
      message(SEND_ERROR " ${Red}FastJet python module missing.${ColourReset}")
    endif()  
  else()
    message(SEND_ERROR " ${Red}FastJet search requires fastjet-config in \$PATH${ColourReset}")
  endif()
  mark_as_advanced(FASTJET_INCLUDE_DIR FASTJET_LIBRARIES)
endif(FASTJET_INCLUDE_DIR AND FASTJET_LIBRARIES)

if(FASTJET_INCLUDE_DIR AND FASTJET_LIBRARIES)
  set(FASTJET_FOUND TRUE)
  message(STATUS "${Green}FASTJET v.${FASTJET_VERSION} found.${ColourReset}")
else(FASTJET_INCLUDE_DIR AND FASTJET_LIBRARIES)
  set(FASTJET_FOUND FALSE)
  message(FATAL_ERROR " ${Red}FASTJET not found.${ColourReset}")
endif(FASTJET_INCLUDE_DIR AND FASTJET_LIBRARIES)
