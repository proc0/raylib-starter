if not exist cmake (
    cmake -S . -B cmake -G "MinGW Makefiles"
)

cmake cmake
cmake --build cmake
cmake --install cmake
