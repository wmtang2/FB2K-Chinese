# Test encoding conversion manually

# The garbled text displayed in foobar2000
$displayed = "皺━魰䕊"

Write-Host "=== ENCODING TEST ===" -ForegroundColor Green
Write-Host ""
Write-Host "Display shows: $displayed"
Write-Host ""

# Step 1: Get bytes
$utf8_bytes = [System.Text.Encoding]::UTF8.GetBytes($displayed)
$hex_str = ($utf8_bytes | ForEach-Object { "{0:X2}" -f $_ }) -join " "
Write-Host "UTF-8 bytes: $hex_str" -ForegroundColor Cyan
Write-Host ""

# Step 2: Reinterpret as GB2312
$gb2312_enc = [System.Text.Encoding]::GetEncoding(936)
Write-Host "Step 1: Decode UTF-8 bytes as GB2312..." -ForegroundColor Yellow

try {
    $reinterpreted = $gb2312_enc.GetString($utf8_bytes)
    Write-Host "  Result: '$reinterpreted'"
    Write-Host ""
    
    # Step 3: Get those characters' UTF-8
    Write-Host "Step 2: Encode result back as UTF-8..." -ForegroundColor Yellow
    $final = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetBytes($reinterpreted))
    Write-Host "  Final result: '$final'"
    Write-Host ""
    
    if ($final -ne $displayed) {
        Write-Host "✓ SUCCESS! Got different output" -ForegroundColor Green
        Write-Host "  Original: $displayed"
        Write-Host "  Converted: $final"
    } else {
        Write-Host "✗ FAILED - Same output" -ForegroundColor Red
    }
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== HYPOTHESIS TEST ===" -ForegroundColor Green

# Now test the hypothesis: what if original was "词条词行"?
$hypothesis = "词条词行"
Write-Host "If original GB2312 text was: $hypothesis"

# Encode as GB2312
$gb2312_bytes = $gb2312_enc.GetBytes($hypothesis)
$gb2312_hex = ($gb2312_bytes | ForEach-Object { "{0:X2}" -f $_ }) -join " "
Write-Host "GB2312 bytes: $gb2312_hex"

# When read as UTF-8
$wrong_utf8 = [System.Text.Encoding]::UTF8.GetString($gb2312_bytes)
Write-Host "When foobar reads as UTF-8: '$wrong_utf8'"

if ($wrong_utf8 -eq $displayed) {
    Write-Host "✓ MATCH! This was the original!" -ForegroundColor Green
} else {
    Write-Host "✗ No match"
}
