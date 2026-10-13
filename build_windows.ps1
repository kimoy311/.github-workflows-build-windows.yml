# Builds Drum Trigger (VST3 + Standalone) on Windows 10/11 x64.
# Prereqs: Visual Studio 2022 (or Build Tools) with "Desktop development with C++", CMake 3.22+, Git.
# Run from a normal PowerShell:  .\build_windows.ps1
$ErrorActionPreference = "Stop"
cmake -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release --parallel

$vst3 = Get-ChildItem -Recurse -Directory -Filter "*.vst3" build | Select-Object -First 1
$exe  = Get-ChildItem -Recurse -Filter "Drum Trigger.exe" build | Select-Object -First 1
Write-Host ""
if ($vst3) { Write-Host "VST3:       $($vst3.FullName)" }
if ($exe)  { Write-Host "Standalone: $($exe.FullName)" }
Write-Host "Install: copy the .vst3 folder to C:\Program Files\Common Files\VST3 (JUCE also does this automatically if you run VS as administrator)."
