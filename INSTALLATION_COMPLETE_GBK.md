# Installation Complete - GBK Encoding Support

## ✅ Installation Status

### Component Installed Successfully
- **Location**: `C:\util\foobar2000-2.1\components\foo_chinese_converter\`
- **Version**: 1.0.0 (x86)
- **Features**: GBK encoding support added

### Files in Installation
```
C:\util\foobar2000-2.1\components\foo_chinese_converter\
├── component.txt          ← Component metadata
├── README.txt             ← Documentation
├── foo_chinese_converter.dll  ← Updated DLL with GBK support
├── opencc.dll             ← OpenCC library
└── opencc/                ← OpenCC data files
    ├── s2t.json
    ├── t2s.json
    ├── STCharacters.ocd2
    └── ... (other character databases)
```

## 🔄 What's New: GBK Encoding Support

### Encoding Dropdown Now Includes:
1. **UTF-8** - Standard Unicode
2. **GB2312** - Simplified Chinese (original)
3. **GBK** ← **NEW**: Simplified Chinese Extended (superset of GB2312)
4. **BIG5** - Traditional Chinese
5. **HZ** - Chinese encoding format
6. **GB2312(UTF-8)** - Reinterpretation mode
7. **GBK(UTF-8)** ← **NEW**: Reinterpretation for GBK mojibake
8. **BIG5(UTF-8)** - Reinterpretation mode
9. **HZ(UTF-8)** - Reinterpretation mode

### Why GBK Was Needed
- Original CUE file is **GBK-encoded** (not GB2312!)
- Example: `D:\Staging\...\copy.cue` contains track title "如果有一天" in GBK
- When foobar2000 reads GBK bytes as UTF-8, text appears garbled: `"?????һ??"`
- Component can now detect and convert GBK-encoded metadata correctly

## 📋 Next Steps

### 1. Restart foobar2000
- Close foobar2000 completely
- Reopen foobar2000 to load the updated component
- Component should auto-load the GBK-enabled DLL

### 2. Verify Component is Loaded
- Open foobar2000 Preferences
- Look for **"Chinese Character Converter"** in the components list
- Should show version 1.0.0

### 3. Test GBK Encoding Support
- Open a metadata field with GBK-encoded text
- Right-click → Preview or conversion dialog
- **Encoding dropdown** should now show "GBK" and "GBK(UTF-8)" options
- Select "GBK(UTF-8)" to fix mojibake text
- Click preview to see corrected text

### 4. Use with CUE Files
- Import your GBK-encoded CUE file with tracks
- Select "GBK" or "GBK(UTF-8)" from dropdown
- Text should display correctly as UTF-8

## 🔧 Technical Details

### Encoding Conversion Path
```
Input: GBK-encoded bytes in metadata
  ↓
Component detects: GBK encoding selected
  ↓
Converts using Windows API (codepage 936)
  ↓
Output: Proper UTF-8 text
```

### Reinterpretation Logic (for mojibake)
```
Input: Garbled UTF-8 "?????һ??" (actually GBK bytes)
  ↓
Extract raw bytes: C8 E7 B9 FB D3 D0 D2 BB CC EC
  ↓
Decode as GBK: "如果有一天" (Chinese characters)
  ↓
Encode as UTF-8: Proper UTF-8 representation
  ↓
Output: "如果有一天" (correct!)
```

## 📦 Build Information

### What Was Changed
1. **encoding.h**: Added `Encoding::GBK` enum value
2. **encoding.cpp**: Added GBK↔UTF-8 conversion functions
3. **ui_preview_dialog.cpp**: Added GBK options to encoding dropdown
4. **create-distribution.ps1**: Packaged as proper .fb2k-component archive

### Build Process
- ✅ x86 Release: Compiled successfully (102912 bytes)
- ✅ x64 Release: Compiled successfully (also available if needed)
- ✅ Package: Created proper .fb2k-component structure
- ✅ Installation: Extracted to correct foobar2000 location

## 📝 Files Modified

```
fb2k_component/
├── include/
│   └── encoding.h              (+1 enum value: GBK)
├── src/
│   ├── encoding.cpp            (+60 lines: GBK conversions)
│   └── ui_preview_dialog.cpp   (+10 lines: GBK dropdown)
└── CMakeLists.txt              (unchanged)
```

## 🎯 Summary

**Problem Solved**: Component now supports GBK-encoded metadata
**Result**: Users can correctly convert GBK-encoded CUE files and tags
**Impact**: "如果有一天" and similar text now displays correctly instead of garbled

---

**Installation Date**: November 11, 2025
**Component Version**: 1.0.0
**Status**: ✅ Ready for use
