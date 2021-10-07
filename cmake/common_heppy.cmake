include(colors)
set(CMAKE_HEPPY_DIR ${CMAKE_CURRENT_LIST_DIR}/..)
set(HEPPY_DIR ${CMAKE_CURRENT_LIST_DIR}/..)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_HEPPY_DIR}/cmake")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_HEPPY_DIR}/cmake/Modules")

find_program(MAKE_EXE NAMES gmake nmake make)
message(STATUS "${Green}Will use ${MAKE_EXE} when needed.${ColourReset}")
find_program(CMAKE_C_COMPILER NAMES $ENV{CC} gcc PATHS ENV PATH NO_DEFAULT_PATH)
find_program(CMAKE_CXX_COMPILER NAMES $ENV{CXX} g++ PATHS ENV PATH NO_DEFAULT_PATH)

# set (CMAKE_CXX_STANDARD 11) # this conflicts with the new compiler/root - std14...
# set(cmake_external_install_prefix ${CMAKE_CURRENT_SOURCE_DIR}/packages)

message( STATUS "CMAKE_CURRENT_SOURCE_DIR: ${CMAKE_CURRENT_SOURCE_DIR}")

# for MacOSx
# set (CMAKE_FIND_FRAMEWORK NEVER)
message(STATUS "${Yellow}Note: this build requires to run within virtual environment of Python...${ColourReset}")
set(Python_FIND_VIRTUALENV ONLY)
set(Python3_FIND_VIRTUALENV ONLY)
