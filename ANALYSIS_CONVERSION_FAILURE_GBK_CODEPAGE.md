# Analysis: Convert to Simplified Chinese Function Failure with GBK System Codepage

## Executive Summary

When the Windows system codepage is set to GBK (936), the **convert to simplified Chinese function has no effect** (nothing gets converted). This is because the converter receives **raw GBK bytes instead of UTF-8 text**, but the conversion engine (OpenCC) expects **UTF-8 input** and cannot process GBK bytes.

## Root Cause Analysis

### The Problem Flow

```
Windows System Codepage = GBK (936)
         ↓
foobar2000 reads metadata tags
         ↓
Tags stored as UTF-8 internally (foobar2000 standard)
         ↓
BUT foobar2000 SDK returns strings based on SYSTEM LOCALE
         ↓
Chinese characters encoded as GBK bytes in `file_info` object
         ↓
ui_context_menu.cpp passes these to converter->to_simplified()
         ↓
converter expects UTF-8, receives GBK bytes
         ↓
OpenCC receives GBK bytes, treats as UTF-8, gets garbage/empty
         ↓
Conversion produces no output / returns empty string
         ↓
Original unchanged (fallback returns same text)
```

### Code Evidence

**Location**: `fb2k_component/src/ui_context_menu.cpp` (lines 247-265)

```cpp
// This lambda gets file_info object with metadata
[converter, to_traditional](trackRef p_location, t_filestats p_stats, file_info& p_info) -> bool {
    bool changed = false;
    t_size meta_count = p_info.meta_get_count();
    
    for (t_size j = 0; j < meta_count; ++j) {
        t_size value_count = p_info.meta_enum_value_count(j);
        
        for (t_size k = 0; k < value_count; ++k) {
            const char* original = p_info.meta_enum_value(j, k);
            // ^^^ PROBLEM: This returns bytes from file_info
            // When system codepage is GBK, this is GBK-encoded
            
            if (original) {
                std::string converted = to_traditional 
                    ? converter->to_traditional(original)  // ← Passes GBK bytes
                    : converter->to_simplified(original);   // ← Passes GBK bytes
                
                if (converted != original) {
                    p_info.meta_modify_value(j, k, converted.c_str());
                    changed = true;
                }
            }
        }
    }
    return changed;
}
```

**Why This Fails**:

1. `p_info.meta_enum_value(j, k)` returns a pointer to the tag value **as stored in file_info**
2. foobar2000's file_info object respects the **system codepage for string representation**
3. When system codepage is **GBK**, the strings are in **GBK encoding**
4. The converter (OpenCC) expects **UTF-8 input**
5. Passing GBK bytes to an OpenCC function expecting UTF-8:
   - Invalid UTF-8 sequence detected
   - OpenCC conversion fails silently
   - Empty result or unchanged text returned

### Converter Evidence

**Location**: `fb2k_component/src/converter.cpp` (lines 170-192)

```cpp
std::string OpenCCConverter::convert_sc_to_tc(const std::string& text) const {
    if (!initialized_ || text.empty()) {
        return text;
    }
    
    if (!s2t_converter_) {
        return text;
    }
    
    try {
        // OpenCC expects UTF-8 input
        char* result = opencc_convert_utf8(s2t_converter_, text.c_str(), -1);
        //                         ^^^^^^ 
        //                         UTF-8 expected!
        
        if (!result) {
            return text;  // Conversion failed, return unchanged
        }
        
        std::string converted(result);
        opencc_convert_utf8_free(result);
        return converted;
    } catch (...) {
        return text;
    }
}
```

**The Issue**: `opencc_convert_utf8()` is called with GBK bytes. OpenCC treats the input as UTF-8, fails to parse valid UTF-8 sequences, and returns empty/unchanged.

## Why This ONLY Fails on GBK Codepage Systems

### UTF-8 Codepage Systems (Windows or Unix)
- System codepage = UTF-8 (65001 or UTF-8)
- `p_info.meta_enum_value()` returns **UTF-8 bytes**
- Converter receives UTF-8 ✓
- `opencc_convert_utf8()` works correctly ✓
- **Conversion succeeds** ✓

### GBK/GB2312 Codepage Systems (Many Chinese Windows Installations)
- System codepage = GBK (936) or GB2312 (20936)
- `p_info.meta_enum_value()` returns **GBK/GB2312 bytes**
- Converter receives GBK bytes ✗
- `opencc_convert_utf8()` receives invalid UTF-8 ✗
- **Conversion fails silently** ✗

## Solution Architecture

### Option 1: Encoding Detection & Conversion (RECOMMENDED)

Add encoding detection and conversion layer **before** passing to converter:

```cpp
[converter, to_traditional](trackRef p_location, t_filestats p_stats, file_info& p_info) -> bool {
    bool changed = false;
    t_size meta_count = p_info.meta_get_count();
    
    for (t_size j = 0; j < meta_count; ++j) {
        t_size value_count = p_info.meta_enum_value_count(j);
        
        for (t_size k = 0; k < value_count; ++k) {
            const char* original = p_info.meta_enum_value(j, k);
            
            if (original) {
                // NEW: Detect encoding and convert to UTF-8 if needed
                std::string utf8_text = original;
                auto detected = EncodingHandler::detect_encoding(original);
                
                if (detected != Encoding::UTF8) {
                    utf8_text = EncodingHandler::to_utf8(original, detected);
                    // ^^^ Now utf8_text is guaranteed UTF-8
                }
                
                // NOW safe to pass to converter
                std::string converted = to_traditional 
                    ? converter->to_traditional(utf8_text)  // UTF-8 input
                    : converter->to_simplified(utf8_text);   // UTF-8 input
                
                if (converted != original) {
                    p_info.meta_modify_value(j, k, converted.c_str());
                    changed = true;
                }
            }
        }
    }
    return changed;
}
```

**Advantages**:
- Works on all system codepages
- Explicit encoding handling
- Follows project architecture patterns
- Matches existing CUE file handling logic

### Option 2: Force UTF-8 at foobar2000 Interface Level

Modify TagProcessor to always return UTF-8-encoded strings from file_info:

```cpp
std::string TagProcessor::get_tag_utf8(const metadb_handle_ptr& track, const char* tag_name) {
    file_info_impl info;
    track->get_info(info);
    
    const char* value = info.meta_find_ex(tag_name, 0);
    if (!value) return "";
    
    // Detect encoding from file_info
    auto detected = EncodingHandler::detect_encoding(value);
    
    if (detected == Encoding::UTF8) {
        return value;  // Already UTF-8
    }
    
    // Convert to UTF-8
    return EncodingHandler::to_utf8(value, detected);
}
```

**Disadvantages**:
- Requires API change in TagProcessor
- Detection happens multiple times
- Less transparent about encoding handling

### Option 3: Use foobar2000 SDK's Built-in UTF-8 Functions

foobar2000 SDK provides UTF-8 conversion utilities. Use those instead:

```cpp
// In pfc namespace (foobar2000 utility library)
pfc::string8 tag_utf8;
// Some SDK method to get UTF-8...
```

**Disadvantages**:
- Tight coupling to SDK
- Need to research foobar2000's exact API
- Less portable/testable

## Recommended Implementation: Option 1

### Step 1: Ensure EncodingHandler Exists and is Public

Check that `EncodingHandler::detect_encoding()` and `EncodingHandler::to_utf8()` are:
- Properly implemented
- Public API methods
- Handle GBK, GB2312, UTF-8

**Location**: `fb2k_component/include/encoding.h` and `fb2k_component/src/encoding.cpp`

### Step 2: Import EncodingHandler in ui_context_menu.cpp

```cpp
#include "encoding.h"  // Add this at top
```

### Step 3: Modify the file_info_filter Lambda

Replace the current lambda with encoding-aware version:

```cpp
service_ptr_t<file_info_filter> filter = file_info_filter::create(
    [converter, to_traditional](trackRef p_location, t_filestats p_stats, file_info& p_info) -> bool {
        bool changed = false;
        t_size meta_count = p_info.meta_get_count();
        
        for (t_size j = 0; j < meta_count; ++j) {
            t_size value_count = p_info.meta_enum_value_count(j);
            
            for (t_size k = 0; k < value_count; ++k) {
                const char* original = p_info.meta_enum_value(j, k);
                if (original) {
                    // Step 1: Detect encoding of the tag value
                    std::string utf8_text = original;
                    fb2k_chinese::EncodingHandler handler;
                    auto detected = handler.detect_encoding(original);
                    
                    // Step 2: Convert to UTF-8 if needed
                    if (detected != fb2k_chinese::Encoding::UTF8) {
                        utf8_text = handler.to_utf8(original, detected);
                    }
                    
                    // Step 3: Now pass UTF-8 to converter
                    std::string converted = to_traditional 
                        ? converter->to_traditional(utf8_text)
                        : converter->to_simplified(utf8_text);
                    
                    // Step 4: Update if changed
                    if (converted != original) {
                        p_info.meta_modify_value(j, k, converted.c_str());
                        changed = true;
                    }
                }
            }
        }
        return changed;
    }
);
```

### Step 4: Update Preview Dialog Similarly

The preview dialog (`ui_preview_dialog.cpp`) likely has the same issue. Apply the same fix there.

**Location**: Search for similar `p_info.meta_enum_value()` patterns in `ui_preview_dialog.cpp`

### Step 5: Add Tests

Create a test case that verifies conversion works on GBK-encoded strings:

```cpp
void test_conversion_with_gbk_input() {
    std::cout << "Test: Convert with GBK input... ";
    
    // Simulate GBK-encoded Chinese text
    EncodingHandler handler;
    std::string gbk_text = handler.to_gbk("杨小琳", Encoding::UTF8);  // UTF-8 to GBK
    
    // Now the converter should handle it
    ChineseConverter converter;
    std::string utf8_input = handler.to_utf8(gbk_text, Encoding::GBK);
    std::string traditional = converter.to_traditional(utf8_input);
    
    assert(!traditional.empty());
    assert(traditional != gbk_text);
    std::cout << "PASS\n";
}
```

## Why This is the Right Solution

1. **Addresses Root Cause**: Explicitly converts GBK→UTF-8 before conversion
2. **Follows Architecture**: Matches existing pattern in CUE file handling (Phase 20 solution)
3. **Works Everywhere**: Handles all system codepages (GBK, GB2312, UTF-8, Big5)
4. **Maintainable**: Clear separation between encoding and conversion layers
5. **Testable**: Can test with mock GBK-encoded strings
6. **Portable**: Core logic doesn't depend on foobar2000 SDK details

## Impact Assessment

| Component | Impact | Effort |
|-----------|--------|--------|
| `ui_context_menu.cpp` | Add encoding detection | Low (~15 lines) |
| `ui_preview_dialog.cpp` | Add encoding detection | Low (~15 lines) |
| `converter.cpp` | No change needed | None |
| `converter.h` | No change needed | None |
| Tests | Add GBK input test | Low (~10 lines) |
| Documentation | Update README | Low (~5 lines) |

**Total Effort**: Low (minimal code changes, follows existing patterns)

**Risk Level**: Very Low (defensive code, doesn't break existing functionality)

## Verification Steps

After implementation:

1. Set Windows system codepage to GBK (936)
   ```powershell
   # PowerShell admin console
   Set-Culture zh-CN
   # Restart system
   ```

2. Load Chinese music with GBK-encoded tags

3. Run "Convert to Simplified Chinese" context menu

4. Verify tags are converted (not empty/unchanged)

5. Verify backup CUE files show converted content

## Related Code References

- **CUE File Handling**: `ui_context_menu.cpp` lines 77-127 (already uses detect_encoding → read_file_with_encoding pattern)
- **EncodingHandler API**: `fb2k_component/include/encoding.h`
- **Converter API**: `fb2k_component/include/converter.h`
- **File Info Access**: `ui_context_menu.cpp` line 248 (file_info_filter lambda)

## Conclusion

The "no conversion" issue with GBK system codepage is due to **encoding mismatch**: the converter receives GBK-encoded bytes but expects UTF-8 input. The solution is to **detect encoding and convert to UTF-8 before conversion**, following the same pattern already successfully implemented for CUE file handling. This is a straightforward fix with minimal risk and broad compatibility improvement.
