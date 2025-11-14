#!/usr/bin/env powershell
# Build and Test Script for FB2K-Chinese Component

param(
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Debug",
    
    [ValidateSet("x86", "x64")]
    [string]$Platform = "x64",
    
    [switch]$Clean,
    [switch]$Test,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

function Show-Help {
    @"
FB2K-Chinese Build Script

Usage:
    .\build.ps1 [Options]

Options:
    -Configuration <Debug|Release>  Build configuration (default: Debug)
    -Platform <x86|x64>             Target platform (default: x64)
    -Clean                          Clean build artifacts
    -Test                           Run tests after build
    -Help                           Show this help message

Examples:
    # Build for x64 Release
    .\build.ps1 -Configuration Release -Platform x64

    # Build and run tests
    .\build.ps1 -Configuration Debug -Platform x64 -Test

    # Clean build
    .\build.ps1 -Clean
"@
}

if ($Help) {
    Show-Help
    exit 0
}

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommandPath
$BuildDir = Join-Path $ProjectRoot "build"

Write-Host "FB2K-Chinese Component Build Script" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# Clean if requested
if ($Clean) {
    Write-Host "Cleaning build directory..." -ForegroundColor Yellow
    if (Test-Path $BuildDir) {
        Remove-Item -Recurse -Force $BuildDir
    }
    Write-Host "Clean complete." -ForegroundColor Green
    exit 0
}

# Create build directory
if (-not (Test-Path $BuildDir)) {
    New-Item -ItemType Directory -Path $BuildDir | Out-Null
}

# Determine Visual Studio version and architecture
$VSVersion = "16 2019"  # Visual Studio 2019
$CMakeArch = if ($Platform -eq "x64") { "x64" } else { "Win32" }
$CMakeGenerator = "Visual Studio $VSVersion"

Write-Host "Configuration: $Configuration" -ForegroundColor Cyan
Write-Host "Platform: $Platform" -ForegroundColor Cyan
Write-Host "Generator: $CMakeGenerator" -ForegroundColor Cyan
Write-Host ""

# Configure with CMake
Write-Host "Running CMake configuration..." -ForegroundColor Yellow
Push-Location $BuildDir
try {
    cmake .. -G $CMakeGenerator -A $CMakeArch
    if ($LASTEXITCODE -ne 0) {
        Write-Host "CMake configuration failed!" -ForegroundColor Red
        exit 1
    }
}
finally {
    Pop-Location
}

Write-Host "CMake configuration complete." -ForegroundColor Green
Write-Host ""

# Build
Write-Host "Building project..." -ForegroundColor Yellow
$BuildDir = Join-Path $ProjectRoot "build"
Push-Location $BuildDir
try {
    cmake --build . --config $Configuration
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Build failed!" -ForegroundColor Red
        exit 1
    }
}
finally {
    Pop-Location
}

Write-Host "Build complete." -ForegroundColor Green
Write-Host ""

# Run tests if requested
if ($Test) {
    Write-Host "Running tests..." -ForegroundColor Yellow
    Push-Location $BuildDir
    try {
        ctest --build-config $Configuration --output-on-failure --verbose
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Some tests failed!" -ForegroundColor Red
            exit 1
        }
    }
    finally {
        Pop-Location
    }
    
    Write-Host "All tests passed!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Build successful!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Configure foobar2000 SDK path in CMakeLists.txt"
Write-Host "  2. Install dependencies: OpenCC, iconv"
Write-Host "  3. Run again with -Test to verify functionality"
Write-Host ""
