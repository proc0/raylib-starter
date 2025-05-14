if not exist build (
    cmake -S . -B build -G "MinGW Makefiles"
)

cmake build
cmake --build build
cmake --install build
