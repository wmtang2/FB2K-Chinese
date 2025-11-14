# FB2K-Chinese Component Package Structure

## Critical Requirements

The `.fb2k-component` file is a ZIP archive. **Files must be at the ZIP root level** (no folder wrapper). foobar2000 will automatically extract them to the correct component folder.

## ✅ CORRECT Structure (v2.2 - Final Fix)

```
Archive Root (no wrapping folder):
  ├── component.txt                 ← Metadata at root
  ├── README.txt                    ← Help at root
  ├── foo_chinese_converter.dll     ← Binary at root
  ├── opencc.dll                    ← OpenCC library at root
  └── opencc/                       ← OpenCC data directory
      ├── s2t.json
      ├── t2s.json
      ├── STCharacters.ocd2
      ├── STPhrases.ocd2
      ├── TSCharacters.ocd2
      ├── TSPhrases.ocd2
      └── ... (other conversion rules)
```

When foobar2000 extracts this to `user-components\`, it automatically creates:
```
user-components\foo_chinese_converter\
  ├── component.txt
  ├── README.txt
  ├── foo_chinese_converter.dll
  ├── opencc.dll
  └── opencc\
```

## ❌ WRONG Structures

**WRONG #1**: Wrapped in folder (causes nested extraction)
```
❌ foo_chinese_converter\              ← Extra wrapper!
     ├── component.txt
     ├── foo_chinese_converter.dll
     └── opencc.dll

Result after extraction: user-components\foo_chinese_converter\foo_chinese_converter\
```

**WRONG #2**: Files at root with nested component folders
```
❌ component.txt
component.txt (at root - wrong location)
foo_chinese_converter/  ← Extra nesting
  ├── foo_chinese_converter.dll
  └── opencc.dll
```

## Why This Matters

foobar2000's component system:
1. Reads `.fb2k-component` ZIP file
2. Creates a folder with the archive filename (without extension): `foo_chinese_converter`
3. Extracts the ZIP contents **directly** into that folder
4. Looks for `component.txt` in that folder

If files are wrapped in a folder, extraction creates nested structure.

## How to Verify (v2.2)

```powershell
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead("dist\foo_chinese_converter-x86.fb2k-component")
$archive.Entries | Select-Object FullName | Sort-Object FullName
$archive.Dispose()
```

Should show files at root level (no `foo_chinese_converter\` prefix):
```
FullName
--------
component.txt
README.txt
foo_chinese_converter.dll
opencc.dll
opencc\hk2s.json
opencc\s2t.json
... etc
```

## Implementation in create-distribution.ps1 (v2.2 - Final)

### Previous Version (v2.1) - INCORRECT
```powershell
# This wrapped files in a folder
$entryPath = "foo_chinese_converter\" + $relativePath
$entry = $zip.CreateEntry($entryPath)
```

### Current Version (v2.2) - CORRECT
```powershell
# Add files directly at ZIP root
$relativePath = $_.FullName.Substring($tempDir.Length + 1)
# NO folder prefix - files go straight to root
$entry = $zip.CreateEntry($relativePath)
$stream = $entry.Open()
$fileStream = [System.IO.File]::OpenRead($_.FullName)
$fileStream.CopyTo($stream)
```

### Key Differences
- v2.0: Used nested `CreateFromDirectory()` - WRONG
- v2.1: Added "foo_chinese_converter\" prefix - WRONG (creates nested on extraction)
- v2.2: Files at ZIP root, no prefix - CORRECT (foobar2000 creates folder automatically)

## Release Packages

- **x86**: `foo_chinese_converter-v1.0.0-x86.fb2k-component` (~0.66 MB)
- **x64**: `foo_chinese_converter-v1.0.0-x64.fb2k-component` (~0.68 MB)

## Installation Methods

### Method 1: Drag-Drop (Easiest)
1. Drag `.fb2k-component` file into foobar2000 window
2. foobar2000 automatically extracts and installs
3. Files go to: `user-components\foo_chinese_converter\`

### Method 2: Manual Extract
1. Extract `.fb2k-component` to `%APPDATA%\foobar2000\profile\user-components\`
2. Restart foobar2000

## Troubleshooting

**Issue**: Component installs to nested `foo_chinese_converter\foo_chinese_converter\`
- **Cause**: Archive had `foo_chinese_converter\` folder wrapper
- **Fix**: Rebuild with v2.2 (files at ZIP root, no wrapper)

**Issue**: Component not recognized
- **Check**: Is `component.txt` in the ZIP at root level?
- **Fix**: Run verification command above

**Issue**: DLL fails to load
- **Check**: Is it the correct architecture (x86 vs x64)?
- **Fix**: For 32-bit foobar2000, use x86 package; for 64-bit, use x64 package

---

**Last Updated**: November 11, 2025 (v2.2 - Files at ZIP root)
**Status**: ✅ Verified - Correct extraction to user-components\foo_chinese_converter\
