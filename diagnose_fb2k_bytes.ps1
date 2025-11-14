# Diagnostic: Understand what bytes foobar2000 actually has

$utf8 = [System.Text.Encoding]::UTF8
$gbk = [System.Text.Encoding]::GetEncoding('GBK')

# Test case: What we THINK should happen
$target = "如果有一天"
$target_gbk_bytes = $gbk.GetBytes($target)

Write-Host "=== EXPECTED GBK ENCODING ===" 
Write-Host "Text: $target"
Write-Host "GBK bytes: $($target_gbk_bytes | ForEach-Object { '{0:X2}' -f $_ })"
Write-Host ""

# When these bytes are read as UTF-8, what do we get?
$when_read_as_utf8 = $utf8.GetString($target_gbk_bytes)
Write-Host "When GBK bytes read as UTF-8 (garbled): '$when_read_as_utf8'"
Write-Host ""

# Now test: what if we take the garbled UTF-8 and interpret its bytes as GBK?
$garbled_bytes = $utf8.GetBytes($when_read_as_utf8)
Write-Host "Garbled text as UTF-8 bytes: $($garbled_bytes | ForEach-Object { '{0:X2}' -f $_ })"

# Try decoding these bytes as GBK
try {
    $decoded = $gbk.GetString($garbled_bytes)
    Write-Host "Decoded back as GBK: '$decoded'"
    if ($decoded -eq $target) {
        Write-Host "✓ SUCCESS: Round-trip conversion works!"
    } else {
        Write-Host "✗ MISMATCH: Got '$decoded' instead of '$target'"
    }
} catch {
    Write-Host "✗ ERROR decoding: $_"
}

Write-Host ""
Write-Host "=== DIAGNOSIS ===" 
Write-Host "The issue might be:"
Write-Host "1. foobar2000 isn't storing raw GBK bytes - it might have already tried to interpret them"
Write-Host "2. The garbled text displayed is the RESULT of foobar2000 trying UTF-8, not the raw file"
Write-Host "3. We need to check what foobar2000 actually has in its database"
