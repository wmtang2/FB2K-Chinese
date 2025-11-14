#!/usr/bin/env powershell

# The GBK bytes for "如果有一天" are: C8 E7 B9 FB D3 D0 D2 BB CC EC
# But they're being decoded to: U+25C6 (E2 97 86 in UTF-8)

# Let's see what happens if we decode C8 E7 with different codepages

$target_utf8_bytes = [byte[]]@(0xE2, 0x97, 0x86)  # U+25C6
$utf8 = [System.Text.Encoding]::UTF8
$target_unicode = $utf8.GetString($target_utf8_bytes)

Write-Host "Target Unicode char: $target_unicode = U+25C6"
Write-Host ""

# Now let's see: what bytes would produce U+25C6?
# U+25C6 comes from somewhere...

# Let's test the actual GBK bytes with different approaches
$gbk_bytes = [byte[]]@(0xC8, 0xE7)  # First 2 bytes of GBK "如"

Write-Host "Testing GBK bytes C8 E7 with different codepages:"
Write-Host ""

# CP936 (GB2312/GBK)
try {
    $cp936 = [System.Text.Encoding]::GetEncoding(936)
    $result = $cp936.GetString($gbk_bytes)
    Write-Host "CP936 (GB2312/GBK): '$result' = U+$(([int][char]$result[0]).ToString('X4'))"
} catch { Write-Host "CP936 error" }

# CP20936 (GBK)  
try {
    $cp20936 = [System.Text.Encoding]::GetEncoding(20936)
    $result = $cp20936.GetString($gbk_bytes)
    Write-Host "CP20936 (GBK): '$result' = U+$(([int][char]$result[0]).ToString('X4'))"
} catch { Write-Host "CP20936 not available" }

# CP950 (Big5)
try {
    $cp950 = [System.Text.Encoding]::GetEncoding(950)
    $result = $cp950.GetString($gbk_bytes)
    Write-Host "CP950 (Big5): '$result' = U+$(([int][char]$result[0]).ToString('X4'))"
} catch { Write-Host "CP950 error" }

# CP1252 (Windows Latin1)
try {
    $cp1252 = [System.Text.Encoding]::GetEncoding(1252)
    $result = $cp1252.GetString($gbk_bytes)
    Write-Host "CP1252 (Latin1): '$result' = U+$(([int][char]$result[0]).ToString('X4'))"
} catch { Write-Host "CP1252 error" }

# ISO-8859-1 (Latin1)
try {
    $latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
    $result = $latin1.GetString($gbk_bytes)
    Write-Host "ISO-8859-1: '$result' = U+$(([int][char]$result[0]).ToString('X4'))"
} catch { Write-Host "ISO-8859-1 error" }

Write-Host ""
Write-Host "=== KEY INSIGHT ==="
Write-Host "We need to find which codepage/encoding produces U+25C6 from C8 E7"
Write-Host "Then we know what foobar2000 is using"
