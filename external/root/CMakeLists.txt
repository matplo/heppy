# This file is just an orchestration
cmake_minimum_required(VERSION 3.13.5)
# SWIG: use SWIG_MODULE_NAME property.
if(POLICY CMP0086)
  cmake_policy(SET CMP0086 NEW)
endif()
# target_sources: use absolute path for INTERFACE_SOURCES.
if(POLICY CMP0076)
  cmake_policy(SET CMP0076 NEW)
endif()
# SWIG: use standard target name.
if(POLICY CMP0078)
  cmake_policy(SET CMP0078 NEW)
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../cmake")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../cmake/Modules")
include(colors)
set(PROJECT_NAME heppy_external_root)
project(${PROJECT_NAME} VERSION 1.0 LANGUAGES CXX)
message(STATUS "${Green}This is ${PROJECT_NAME} ver. ${PROJECT_VERSION}${ColourReset}")

find_program(MAKE_EXE NAMES gmake nmake make)
message(STATUS "${Green}Will use ${MAKE_EXE} when needed.${ColourReset}")
find_program(CMAKE_C_COMPILER NAMES $ENV{CC} gcc PATHS ENV PATH NO_DEFAULT_PATH)
find_program(CMAKE_CXX_COMPILER NAMES $ENV{CXX} g++ PATHS ENV PATH NO_DEFAULT_PATH)

find_package(SWIG REQUIRED)
if (SWIG_FOUND)
    message(STATUS "${Green}SWIG ver. ${SWIG_VERSION} found.${ColourReset}")
  else(SWIG_FOUND)
    message(FATAL_ERROR "${Red}SWIG not found while it is the key package here...${ColourReset}")
endif(SWIG_FOUND)

set (CMAKE_CXX_STANDARD 11)

message( STATUS "CMAKE_CURRENT_SOURCE_DIR: ${CMAKE_CURRENT_SOURCE_DIR}")

find_package(Python3 3.6 REQUIRED COMPONENTS Interpreter Development NumPy)
if (Python3_FOUND)
    message(STATUS "${Green}Python ver. ${Python3_VERSION} found.${ColourReset}")
	execute_process(COMMAND ${Python3_EXECUTABLE} -c "import distutils.sysconfig as sysconfig; print(sysconfig.get_config_var('LIBDIR'))"
					/tmp OUTPUT_VARIABLE HEPPY_PYTHON_LIBS OUTPUT_STRIP_TRAILING_WHITESPACE)
	message(STATUS "Some python libs info: ${Python3_EXECUTABLE} ${Python3_INCLUDE_DIRS} ${Python3_STDLIB} ${Python3_LIBRARIES} ${HEPPY_PYTHON_LIBS}")
	#add_definitions(-DPYTHON_EXECUTABLE=${Python3_EXECUTABLE} -DPYTHON_INCLUDE_DIR=${Python3_INCLUDE_DIRS} -DPYTHON_LIBRARY=${Python3_STDLIB})
  else(Python3_FOUND)
    message(FATAL_ERROR "${Red}Python not found while it is the key package here...${ColourReset}")
endif(Python3_FOUND)

include(ProcessorCount)
ProcessorCount(NCPU)

include(ExternalProject)

if (NOT ROOT_VERSION)
	set(ROOT_VERSION v6-18-04)
endif(NOT ROOT_VERSION)

message(STATUS "ROOT_VERSION ${ROOT_VERSION}")

if (NOT ROOT_HEPPY_PREFIX)
	set(ROOT_HEPPY_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/root-${ROOT_VERSION}")
endif(NOT ROOT_HEPPY_PREFIX)

message(STATUS "ROOT_HEPPY_PREFIX ${ROOT_HEPPY_PREFIX}")

# add_definitions(-Dbuiltin_xrootd=ON -Dmathmore=ON -Dxml=ON -Dvmc=ON)

ExternalProject_Add(ROOT
	PREFIX        		${ROOT_HEPPY_PREFIX}
	GIT_REPOSITORY    	http://github.com/root-project/root.git
	GIT_TAG 		  	${ROOT_VERSION}
	GIT_PROGRESS 		TRUE
	CMAKE_ARGS 			${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX=${ROOT_HEPPY_PREFIX} -DCMAKE_BUILD_TYPE=Release -DPYTHON_EXECUTABLE=${Python3_EXECUTABLE} -DPYTHON_INCLUDE_DIR=${Python3_INCLUDE_DIRS} -DPYTHON_LIBRARY=${Python3_LIBRARIES} -Dbuiltin_xrootd=ON -Dmathmore=ON -Dxml=ON -Dvmc=ON
	BUILD_COMMAND       ${CMAKE_COMMAND} --build . -- -j ${NCPU}
	INSTALL_COMMAND     ${CMAKE_COMMAND} --build . --target install
	LOG_DOWNLOAD 		TRUE
	LOG_UPDATE 			TRUE
	LOG_CONFIGURE 		TRUE
	LOG_BUILD 			TRUE
	LOG_TEST 			TRUE
	LOG_INSTALL 		TRUE)
