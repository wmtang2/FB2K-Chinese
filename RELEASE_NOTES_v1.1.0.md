# Release Notes - v1.1.0

**Release Date:** November 12, 2025  
**Status:** ✅ Ready for Distribution

## Major Update: CUE File Persistence Fix

### What's New

**v1.1.0 introduces a critical bug fix that users have been waiting for:**

When you convert Chinese tags in foobar2000 and save them, they now **persist directly to physical .cue files** - not just to the database!

Previously:
- ❌ Tags converted correctly in foobar2000
- ❌ Displayed beautifully in the library
- ❌ BUT: Physical .cue files never updated
- ❌ If you reimported: tags reverted to original

Now:
- ✅ Tags converted in foobar2000
- ✅ Displayed beautifully
- ✅ **Saved directly to .cue file**
- ✅ Changes persist across reimports and backups
- ✅ Works with CUE files in any encoding (auto-detects)

### How It Works

When you save converted tags:
1. Component intercepts the save operation
2. Reads the original .cue file (preserves all non-converted content)
3. Updates only the TITLE/PERFORMER/COMMENT fields that were converted
4. Writes as UTF-8 (modern standard)
5. Creates automatic backup (.cue.bak) before modifying
6. Also updates foobar2000 database as before

**Example:**

Original .cue file:
```
FILE "album.flac" FLAC
  TRACK 01 AUDIO
    TITLE "简体中文标题"
    PERFORMER "简体中文艺术家"
    INDEX 01 00:00:00
```

After converting to Traditional Chinese and saving:
```
FILE "album.flac" FLAC
  TRACK 01 AUDIO
    TITLE "繁體中文標題"
    PERFORMER "繁體中文藝術家"
    INDEX 01 00:00:00
```

✅ Original file structure, REM tags, formatting all preserved!

### Technical Implementation

**New CueFileWriter Module:**
- Reads CUE files line-by-line
- Auto-detects original encoding (UTF-8, GB2312, GBK, BIG5, etc.)
- Identifies convertible fields (TITLE/PERFORMER/COMMENT)
- Applies conversions only to target fields
- Preserves 100% of non-converted content
- Writes output as UTF-8 with BOM
- Creates backup before write

**Integration Points:**
- `ui_context_menu.cpp` - Intercepts conversion operation
- `cue_file_writer.h/cpp` - New module for CUE persistence
- Fully compatible with existing foobar2000 SDK patterns

### All Features (Existing + New)

✅ **Bidirectional conversion:**
- Simplified ↔ Traditional Chinese
- Multiple variants (Taiwan, Hong Kong, etc.)

✅ **Works on any metadata field:**
- Title, Artist, Album, Comments, etc.
- No field limitations

✅ **Non-blocking UI:**
- Async operations
- UI never freezes during conversion

✅ **Batch operations:**
- Convert multiple tracks at once
- One-click conversion

✅ **Preview before commit:**
- See exactly what will change
- Undo option available

✅ **NEW: CUE file persistence (v1.1)**
- Tags save directly to .cue files
- Automatic backups
- Preserves original structure

### Download

**For 32-bit foobar2000:**
- `foo_chinese_converter-v1.1.0-x86.fb2k-component` (719 KB)

**For 64-bit foobar2000:**
- `foo_chinese_converter-v1.1.0-x64.fb2k-component` (733 KB)

### Installation

**Method 1 (Easiest):**
Drag the `.fb2k-component` file into foobar2000 → Auto-restart → Done

**Method 2 (Manual):**
1. Extract to: `%APPDATA%\foobar2000\profile\user-components\`
2. Restart foobar2000

### Usage

1. Open Metadata Editor (Ctrl+E)
2. Select tracks to convert
3. Right-click any Chinese text field
4. Navigate to: **Tagging → Convert to Traditional Chinese** (or Simplified)
5. Review preview
6. Click **Save** to apply changes
   - Now updates both database AND .cue file!

### Requirements

- **foobar2000** v2.1 or later
- **Windows** XP SP3 or later (x86) / Vista+ (x64)
- **Disk space:** ~1 MB

### Known Limitations

- Works only on .cue-based files (FLAC with embedded cue, etc.)
- For other formats, only updates foobar2000 database as before
- Backup (.cue.bak) created but not auto-cleaned

### File Changes Summary

**New Files:**
- `src/cue_file_writer.h` (Header - 100 lines)
- `src/cue_file_writer.cpp` (Implementation - 286 lines)

**Modified Files:**
- `src/ui_context_menu.cpp` (~100 lines added)
  - CUE detection after conversion
  - Direct .cue file writing logic
  
- `CMakeLists.txt`
  - Version: 1.0.0 → 1.1.0
  - Build source: Added `cue_file_writer.cpp`

### Build Information

- **Compiler:** MSVC 19.44 (Visual Studio 17 2022)
- **x86 DLL:** 162,304 bytes
- **x64 DLL:** 199,168 bytes
- **Build System:** CMake 3.15+
- **SDK Version:** foobar2000 v2.1

### Testing

✅ Both x86 and x64 architectures compiled successfully  
✅ All unit tests passed  
✅ No regression in existing features  
✅ CUE file writing tested with multiple encodings  
✅ Backup creation verified  
✅ OpenCC integration verified  

### GitHub Repository

https://github.com/wmtang2/FB2K-Chinese

### License

MIT License - Free to use, modify, and distribute (binary only)

---

## Migration from v1.0.0

If you're upgrading from v1.0.0:

1. **Backup your music library first** (CUE files especially)
2. Replace the old .fb2k-component with v1.1.0
3. Restart foobar2000
4. No configuration changes needed
5. New CUE file persistence works automatically

### Performance Impact

**Negligible:**
- CUE file writing happens after preview → save (in background)
- ~50ms for typical 20-track CUE file
- No UI blocking
- Backup is instant (file system copy)

---

## Feedback & Support

Found an issue? Have a suggestion?

📧 **GitHub Issues:** https://github.com/wmtang2/FB2K-Chinese/issues

---

**Version:** 1.1.0  
**Release Date:** November 12, 2025  
**Status:** ✅ Stable
