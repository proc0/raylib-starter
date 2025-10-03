# Check if CMake is installed
$cmakeCheck = where.exe cmake 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "CMake is not installed or not in the PATH. Please install CMake and add it to your PATH."
    exit 1
}

# Initialize variables
$platform = "Desktop"
$buildType = "Debug"
$buildPath = "build"
$generator = "MinGW Makefiles"
$otherArgs = @()

# Process arguments
foreach ($arg in $args) {
    if ($arg -eq "--web") {
        $platform = "Web"
        $buildPath = "$buildPath-web"
    } elseif ($arg -eq "--release") {
        $buildType = "Release"
    } else {
        $otherArgs += $arg
    }
}

# Configure
if (-not (Test-Path $buildPath)) {
    New-Item -ItemType Directory -Path $buildPath | Out-Null

    if ($platform -eq "Web") {
        emcmake cmake -S . -B $buildPath -DBUILD_TYPE="$buildType"
    } else {
        cmake -S . -B $buildPath -G $generator -DBUILD_TYPE="$buildType"
    }
}

# Generate
cmake $buildPath -DPLATFORM="$platform"

# Build
if ($otherArgs.Count -gt 0) {
    cmake --build $buildPath -- $otherArgs
} else {
    cmake --build $buildPath
}