# Key realization: foobar2000 ALWAYS stores UTF-8
# But if someone imported from a GB2312 ID3 tag and foobar didn't convert it properly,
# the UTF-8 bytes CONTAIN the original GB2312 bytes (never reconverted)

# So we need to extract "如果有一天" from whatever "皺━魰䕊" represents

$gb2312 = [System.Text.Encoding]::GetEncoding(936)
$utf8 = [System.Text.Encoding]::UTF8

$target = "如果有一天"

# The question is: what if the bytes were stored directly without proper encoding?
# Like: the file had raw GB2312 bytes, and someone just put them into foobar as-is

# Let's get the target's GB2312 bytes
$target_gb2312 = $gb2312.GetBytes($target)

Write-Host "Target: $target"
Write-Host "GB2312 bytes: $($target_gb2312 | ForEach-Object { '{0:X2}' -f $_ }) -join ' ')"
Write-Host ""

# Now: what if these GB2312 bytes were stored as a "binary string" in foobar?
# I.e., each byte becomes a character?

# Try: create a string from the bytes directly
$as_chars = ""
foreach ($b in $target_gb2312) {
    $as_chars += [char]$b
}

Write-Host "If GB2312 bytes stored as chars: '$as_chars'"
Write-Host ""

# Another approach: what if the bytes were misinterpreted through Latin1?
$latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
$as_latin1 = $latin1.GetString($target_gb2312)
Write-Host "If GB2312 bytes read as Latin1: '$as_latin1'"
Write-Host ""

# Get those as UTF-8 bytes
$latin1_bytes = $utf8.GetBytes($as_latin1)
Write-Host "Latin1 string as UTF-8 bytes: $($latin1_bytes | ForEach-Object { '{0:X2}' -f $_ }) -join ' ')"
Write-Host ""

# Now what if we decode those bytes as GB2312?
$corrected = $gb2312.GetString($latin1_bytes)
Write-Host "Decoding back: '$corrected'"
