# Implementation Guide: Fix GBK Codepage Conversion Failure

## Code Changes Required

### File 1: `fb2k_component/src/ui_context_menu.cpp`

#### Location: Lines 246-265 (inside context_command method)

**BEFORE (Broken on GBK systems):**
```cpp
// Create file_info_filter using lambda
service_ptr_t<file_info_filter> filter = file_info_filter::create(
    [converter, to_traditional](trackRef p_location, t_filestats p_stats, file_info& p_info) -> bool {
        bool changed = false;
        t_size meta_count = p_info.meta_get_count();
        
        for (t_size j = 0; j < meta_count; ++j) {
            t_size value_count = p_info.meta_enum_value_count(j);
            
            for (t_size k = 0; k < value_count; ++k) {
                const char* original = p_info.meta_enum_value(j, k);
                if (original) {
                    std::string converted = to_traditional 
                        ? converter->to_traditional(original)
                        : converter->to_simplified(original);
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

**AFTER (Works on all codepages):**
```cpp
// Create file_info_filter using lambda
service_ptr_t<file_info_filter> filter = file_info_filter::create(
    [converter, to_traditional](trackRef p_location, t_filestats p_stats, file_info& p_info) -> bool {
        bool changed = false;
        t_size meta_count = p_info.meta_get_count();
        
        // Create encoding handler for tag conversion
        fb2k_chinese::EncodingHandler encoding_handler;
        
        for (t_size j = 0; j < meta_count; ++j) {
            t_size value_count = p_info.meta_enum_value_count(j);
            
            for (t_size k = 0; k < value_count; ++k) {
                const char* original = p_info.meta_enum_value(j, k);
                if (original) {
                    // Step 1: Detect encoding of the tag value
                    fb2k_chinese::Encoding detected = encoding_handler.detect_encoding(original);
                    
                    // Step 2: Convert to UTF-8 if needed (converter expects UTF-8)
                    std::string utf8_text = original;
                    if (detected != fb2k_chinese::Encoding::UTF8) {
                        utf8_text = encoding_handler.to_utf8(original, detected);
                    }
                    
                    // Step 3: Now pass UTF-8 text to converter
                    std::string converted = to_traditional 
                        ? converter->to_traditional(utf8_text)
                        : converter->to_simplified(utf8_text);
                    
                    // Step 4: Update metadata if changed
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

#### Required Include

Add at the top of the file (after existing includes):
```cpp
#include "encoding.h"  // For EncodingHandler and Encoding enum
```

---

### File 2: `fb2k_component/src/ui_preview_dialog.cpp`

Search for similar code patterns where `p_info.meta_enum_value()` is called and metadata is being read for display/conversion.

**Typical Pattern to Find:**
```cpp
// Somewhere in ui_preview_dialog.cpp
const char* value = p_info.meta_enum_value(...);
// Then: uses value directly for display or comparison
```

**Apply Same Fix:**
```cpp
// Replace:
const char* value = p_info.meta_enum_value(...);

// With:
const char* value = p_info.meta_enum_value(...);
if (value) {
    fb2k_chinese::EncodingHandler handler;
    auto detected = handler.detect_encoding(value);
    if (detected != fb2k_chinese::Encoding::UTF8) {
        value = handler.to_utf8(value, detected).c_str();  // ⚠️ Be careful with scope!
    }
}
```

**Note**: In preview dialog, be careful about string lifetime. Consider:
```cpp
const char* value = p_info.meta_enum_value(...);
if (value) {
    fb2k_chinese::EncodingHandler handler;
    auto detected = handler.detect_encoding(value);
    std::string utf8_text = (detected != fb2k_chinese::Encoding::UTF8)
        ? handler.to_utf8(value, detected)
        : value;
    // Now use utf8_text which has guaranteed lifetime
}
```

---

## Testing the Fix

### Unit Test to Add

**File**: `fb2k_component/tests/test_converter.cpp` or create new test file

```cpp
void test_converter_with_gbk_input() {
    std::cout << "Test: Converter with GBK input... ";
    
    // Simulate system receiving GBK-encoded text
    // (what happens when Windows codepage is GBK)
    fb2k_chinese::EncodingHandler handler;
    
    // Original UTF-8 text
    std::string utf8_original = "杨小琳";
    
    // Convert to GBK (simulates what file_info returns on GBK system)
    std::string gbk_text = handler.from_utf8(utf8_original, fb2k_chinese::Encoding::GBK);
    
    // Simulate the OLD BROKEN code:
    fb2k_chinese::ChineseConverter converter;
    std::string broken_result = converter.to_traditional(gbk_text);
    // Result: probably empty or garbled, not a valid traditional conversion
    
    // Simulate the NEW FIXED code:
    auto detected = handler.detect_encoding(gbk_text);
    std::string utf8_from_gbk = (detected != fb2k_chinese::Encoding::UTF8)
        ? handler.to_utf8(gbk_text, detected)
        : gbk_text;
    std::string fixed_result = converter.to_traditional(utf8_from_gbk);
    
    // Assertions
    assert(!fixed_result.empty());                    // Conversion should succeed
    assert(fixed_result != gbk_text);                 // Should be different (converted)
    assert(fixed_result != utf8_original);            // Should be traditional, not simplified
    
    std::cout << "PASS\n";
}
```

### Integration Test

```cpp
void test_full_pipeline_with_gbk_system() {
    std::cout << "Test: Full pipeline with GBK system codepage... ";
    
    // Simulate metadata returned by foobar2000 on GBK system
    fb2k_chinese::EncodingHandler handler;
    std::string gbk_title = handler.from_utf8("精装杨小琳", fb2k_chinese::Encoding::GBK);
    
    // This is what the fixed code does:
    auto detected = handler.detect_encoding(gbk_title);
    std::string utf8_title = handler.to_utf8(gbk_title, detected);
    
    // Now convert
    fb2k_chinese::ChineseConverter converter;
    std::string converted = converter.to_traditional(utf8_title);
    
    // Verify
    assert(!converted.empty());
    assert(converted != gbk_title);
    
    std::cout << "PASS\n";
}
```

---

## Build and Verify

```powershell
# 1. Build with changes
cd e:\Ricky\Development\FB2K-Chinese
.\build.ps1 -Configuration Release -Platform x64

# 2. Test
cd build-win64
ctest --output-on-failure --verbose

# 3. Run manual test on GBK system
# (See verification section in main analysis document)
```

---

## Verification Checklist

- [ ] No compilation errors (rebuild clean)
- [ ] All existing tests still pass
- [ ] New GBK encoding tests pass
- [ ] x86 build succeeds
- [ ] x64 build succeeds
- [ ] Manual testing on GBK system works
  - [ ] Convert to Traditional Chinese: text changes
  - [ ] Convert to Simplified Chinese: text changes
  - [ ] CUE files updated correctly
  - [ ] Preview shows correct conversions

---

## Why This Fix Works

```
BEFORE:
GBK Bytes → (no detection) → converter.to_traditional(gbk_bytes)
           → OpenCC gets invalid UTF-8
           → Returns empty/unchanged ✗

AFTER:
GBK Bytes → detect_encoding() → UTF-8 bytes → converter.to_traditional(utf8)
           → OpenCC gets valid UTF-8
           → Returns converted text ✓
```

---

## Related Successful Pattern

This fix mirrors the **already-working CUE file handling** from Phase 20:

```cpp
// CUE file (WORKS):
auto detected_encoding = CueParser::detect_encoding(cue_path);
std::string utf8_content = CueParser::read_file_with_encoding(cue_path, detected_encoding);

// Metadata (NEEDS FIX):
auto detected = EncodingHandler::detect_encoding(original);
std::string utf8_text = EncodingHandler::to_utf8(original, detected);
```

Same pattern, same confidence it will work.

---

**Status**: Ready to implement  
**Risk Level**: Very Low (defensive code, proven pattern)  
**Estimated Effort**: 30 minutes (code change + testing)
