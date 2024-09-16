message(STATUS "${Yellow}Note: this build requires to run within virtual environment of Python...${ColourReset}")

set(Python_FIND_VIRTUALENV ONLY)
set(Python3_FIND_VIRTUALENV ONLY)

execute_process(
    COMMAND which python3
    OUTPUT_VARIABLE Python3_EXECUTABLE
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

message(STATUS "Python3 executable found at: ${Python3_EXECUTABLE}")
set(Python_EXECUTABLE ${Python3_EXECUTABLE})

execute_process(
    COMMAND ${Python3_EXECUTABLE} -c "import sys; print(sys.path)"
    OUTPUT_VARIABLE PYTHONPATH_OUTPUT
)

message(STATUS "Python sys.path: ${PYTHONPATH_OUTPUT}")

# Call the Python command to get the NumPy include directory
execute_process(
    COMMAND ${Python3_EXECUTABLE} -c "import numpy; print(numpy.get_include())"
    OUTPUT_VARIABLE NUMPY_INCLUDE_DIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Print the NumPy include directory for verification
message(STATUS "NumPy include directory: ${NUMPY_INCLUDE_DIR}")

# Call Python to find the include directory for Python headers
execute_process(
    COMMAND ${Python3_EXECUTABLE} -c "from sysconfig import get_paths; print(get_paths()['include'])"
    OUTPUT_VARIABLE PYTHON_INCLUDE_DIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Include the Python headers
include_directories(${PYTHON_INCLUDE_DIR})

message(STATUS "Python include directory: ${PYTHON_INCLUDE_DIR}")

find_package(Python3 3.6 REQUIRED COMPONENTS Interpreter Development NumPy)

if (Python3_Development_FOUND)
    message(STATUS "Python3 libraries found: ${Python3_LIBRARIES}")
    include_directories(${Python3_INCLUDE_DIRS})
    link_libraries(${Python3_LIBRARIES})
endif()

if (Python3_NumPy_FOUND)
    message(STATUS "NumPy found: ${Python3_NumPy_INCLUDE_DIRS}")
    include_directories(${Python3_NumPy_INCLUDE_DIRS})
else()
    message(FATAL_ERROR "NumPy not found.")
endif()

if (Python3_FOUND)
    message(STATUS "${Green}Python ver. ${Python3_VERSION} found.${ColourReset}")
    set(HEPPY_PYTHON_FOUND True)
  else(Python3_FOUND)
    message(FATAL_ERROR "${Red}Python3 not found while it is the key package here...${ColourReset}")
endif(Python3_FOUND)
