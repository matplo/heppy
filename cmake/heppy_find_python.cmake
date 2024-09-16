message(STATUS "${Yellow}Note: this build requires to run within virtual environment of Python...${ColourReset}")

set(Python_FIND_VIRTUALENV ONLY)
set(Python3_FIND_VIRTUALENV ONLY)

execute_process(
    COMMAND which python3
    OUTPUT_VARIABLE Python3_EXECUTABLE
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

message(STATUS "Python3 executable found at: ${Python3_EXECUTABLE}")

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

find_package(Python3 3.6 REQUIRED COMPONENTS Interpreter Development NumPy)

if (Python3_FOUND)
    message(STATUS "${Green}Python ver. ${Python3_VERSION} found.${ColourReset}")
    set(HEPPY_PYTHON_FOUND True)
  else(Python3_FOUND)
    message(FATAL_ERROR "${Red}Python3 not found while it is the key package here...${ColourReset}")
endif(Python3_FOUND)
