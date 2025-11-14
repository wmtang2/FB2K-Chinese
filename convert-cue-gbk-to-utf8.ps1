#!/usr/bin/env powershell
<#
.SYNOPSIS
Convert a GBK-encoded CUE file to UTF-8

.DESCRIPTION
Reads a GBK CUE file and saves it as UTF-8 for import into foobar2000

.PARAMETER InputFile
Path to the GBK-encoded CUE file

.PARAMETER OutputFile
Path to save the UTF-8 converted CUE file
#>

param(
    [string]$InputFile = "",
    [string]$OutputFile = ""
)

if (-not $InputFile) {
    Write-Host "Usage: .\convert-cue-gbk-to-utf8.ps1 -InputFile <path> -OutputFile <path>"
    Write-Host ""
    Write-Host "Example:"
    Write-Host "  .\convert-cue-gbk-to-utf8.ps1 -InputFile 'D:\Music\album.cue' -OutputFile 'D:\Music\album-utf8.cue'"
    exit 1
}

if (-not $OutputFile) {
    $OutputFile = [System.IO.Path]::GetDirectoryName($InputFile) + "\" + [System.IO.Path]::GetFileNameWithoutExtension($InputFile) + "-utf8.cue"
}

if (-not (Test-Path $InputFile)) {
    Write-Host "✗ Input file not found: $InputFile"
    exit 1
}

# Read the file as GBK
$gbk = [System.Text.Encoding]::GetEncoding('GBK')
$utf8_with_bom = New-Object System.Text.UTF8Encoding $true  # With BOM for better compatibility

try {
    $content = [System.IO.File]::ReadAllText($InputFile, $gbk)
    Write-Host "✓ Read GBK file: $InputFile"
    
    # Write as UTF-8
    [System.IO.File]::WriteAllText($OutputFile, $content, $utf8_with_bom)
    Write-Host "✓ Wrote UTF-8 file: $OutputFile"
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "1. In foobar2000, delete the old metadata from the tracks"
    Write-Host "2. Use File → Options → Tools → Reload metadata from file tags"
    Write-Host "3. Or delete and re-add the audio files"
    Write-Host "4. The text should now display correctly"
} catch {
    Write-Host "✗ Error: $_"
    exit 1
}
