# Quick Reference: GBK Codepage Conversion Failure

## The Problem in One Sentence
**When Windows codepage is GBK, the converter receives GBK bytes instead of UTF-8, but OpenCC expects UTF-8 input, so conversion silently fails and returns unchanged text.**

## Why It Happens

```
Windows System Codepage = GBK (936)
    ↓
foobar2000's file_info object respects system locale
    ↓
p_info.meta_enum_value() returns GBK-encoded bytes
    ↓
Converter calls opencc_convert_utf8(gbk_bytes)  ← Wrong encoding!
    ↓
OpenCC gets garbage UTF-8 (actually GBK)
    ↓
Conversion fails, returns empty/unchanged
```

## The Fix (TL;DR)

Before passing text to converter, **detect encoding and convert to UTF-8**:

```cpp
// Old code (BROKEN on GBK systems):
std::string converted = converter->to_traditional(original);

// New code (WORKS everywhere):
auto detected = EncodingHandler::detect_encoding(original);
std::string utf8_text = (detected != Encoding::UTF8) 
    ? EncodingHandler::to_utf8(original, detected)
    : original;
std::string converted = converter->to_traditional(utf8_text);
```

## Files to Modify

1. **`fb2k_component/src/ui_context_menu.cpp`** (lines 247-265)
   - Lambda inside `file_info_filter::create()` call
   - Add encoding detection before converter call

2. **`fb2k_component/src/ui_preview_dialog.cpp`**
   - Find similar `p_info.meta_enum_value()` usage
   - Apply same encoding detection fix

## Key Insight

This is the **exact same pattern already working for CUE files** (Phase 20):

```cpp
// CUE file handling (WORKS because it does encoding detection):
auto detected_encoding = CueParser::detect_encoding(cue_path);
std::string utf8_content = CueParser::read_file_with_encoding(
    cue_path, 
    detected_encoding
);
// ^^^ Then parse and convert from UTF-8

// Metadata handling (BROKEN because it skips encoding detection):
const char* original = p_info.meta_enum_value(j, k);
std::string converted = converter->to_traditional(original);
// ^^^ Passes raw bytes without encoding detection
```

**Solution**: Apply the same encoding-detection pattern to metadata.

## System Codepage Impact

| System Codepage | `p_info.meta_enum_value()` returns | Current Result | After Fix |
|-----------------|-----------------------------------|----------------|-----------|
| UTF-8 (65001) | UTF-8 bytes | ✓ Works | ✓ Works |
| GBK (936) | GBK bytes | ✗ Broken | ✓ Works |
| GB2312 (20936) | GB2312 bytes | ✗ Broken | ✓ Works |
| Big5 (950) | Big5 bytes | ✗ Broken | ✓ Works |

## Testing

After fix:

```powershell
# Build with fix
.\build.ps1 -Configuration Release -Platform x64

# Set system codepage to GBK
Set-Culture zh-CN
# Restart system

# Load Chinese music with GBK-tagged metadata
# Right-click: Convert to Simplified Chinese
# ✓ Should convert successfully (not empty/unchanged)
```

## Why This MUST Be Fixed

- Affects **all users with GBK/GB2312 Windows** (very common in China/Taiwan)
- Makes component appear "broken" on these systems
- Simple fix with **minimal code changes**
- Already proven pattern (works for CUE files)

---

**See**: `ANALYSIS_CONVERSION_FAILURE_GBK_CODEPAGE.md` for complete technical analysis.
