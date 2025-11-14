# CUE File Tag Saving - Analysis & Implementation Plan

## Current Architecture Analysis

### 1. How Tags Are Currently Saved

**Flow:**
1. User right-clicks track in foobar2000 → "Tagging" → "Convert to Traditional Chinese"
2. **ui_context_menu.cpp** (ChineseConverterMenu::context_command) is triggered
3. A **preview dialog** is shown (ShowPreviewDialog in ui_preview_dialog.cpp)
4. User clicks "Save" button
5. **g_preview_apply_clicked** flag is set to true
6. The dialog closes
7. BUT: **No actual file/tag writing happens after the dialog closes!**

### 2. Where Tag Writing Should Happen

The code in **ui_context_menu.cpp** shows the INTENDED tag writing mechanism:
```cpp
// Create file_info_filter using lambda
service_ptr_t<file_info_filter> filter = file_info_filter::create(
    [converter, to_traditional](trackRef p_location, t_filestats p_stats, file_info& p_info) -> bool {
        // Converts all metadata fields
        // Returns changed = true if any changes made
    }
);

// Queue async update with foobar2000
static_api_ptr_t<metadb_io_v2> io;
io->update_info_async(p_data, filter, ...);
```

**Problem:** This code applies changes only to foobar2000's internal database, NOT to the actual CUE files.

### 3. CUE File Structure (from cue_parser.cpp)

**Parsed into CueTrack struct:**
```cpp
struct CueTrack {
    int track_number;
    std::string title;
    std::string performer;
    std::string comment;
    std::string index;
};
```

**Raw CUE format example:**
```
REM COMMENT "metadata"
PERFORMER "Artist Name"
TITLE "Album Name"
FILE "audio.flac" FLAC
  TRACK 01 AUDIO
    TITLE "Track Title"
    PERFORMER "Track Artist"
    COMMENT "Track Comment"
    INDEX 01 00:00:00
```

### 4. Current State of CUE File Writer

**Status:** Both `cue_file_writer.h` and `cue_file_writer.cpp` are EMPTY stubs

This is where the fix needs to be implemented.

---

## Implementation Plan

**Phase 1: Create CUE File Writer Module**

**File: cue_file_writer.h** (Header)
```
Define CueFileWriter class with:
- public: void write_cue_file(const std::string& cue_path, 
                            const std::vector<CueTrack>& tracks)
- private: std::string get_converted_value(const std::string& line,
                                           const std::vector<CueTrack>& tracks)
- private: bool is_convertible_field(const std::string& line)
- private: void backup_cue_file(const std::string& cue_path)
- private: bool write_file_as_utf8(const std::vector<std::string>& lines, ...)
```

**File: cue_file_writer.cpp** (Implementation)
- Read original CUE file line-by-line (handles any encoding)
- For each line: determine if it needs conversion, or copy as-is
- Update ONLY the TITLE/PERFORMER/COMMENT fields that match converted tracks
- Copy ALL other content unchanged (REM, FILE, INDEX, blank lines, etc.)
- Preserve exact formatting, order, indentation, and all metadata
- Write back as UTF-8
- Result: All original content preserved except for converted tags

### Phase 2: Integration Point

**Modify: ui_preview_dialog.cpp**

In the "Save" button handler (WM_COMMAND, IDC_APPLY_BTN):
```
When g_preview_apply_clicked = true:
1. For each track in g_preview_tracks:
   - Detect if track comes from a CUE file
   - Extract CUE file path
   - If yes:
     - Parse CUE file with original encoding
     - Update the track metadata from preview
     - Write updated CUE back with CueFileWriter
   - If no (regular audio file):
     - Use existing foobar2000 tag writing
```

### Phase 3: Detect CUE File Source

Use existing logic from `TryReadFromCueFile()` in ui_preview_dialog.cpp:
- Track path → find corresponding .cue file
- Check if .cue file exists
- If yes, it's a CUE-based track

### Phase 4: Update Metadata from Preview

**Data flow:**
1. `g_preview_changes` contains all converted tags (TagChangePreview struct)
2. Parse CUE file into `std::vector<CueTrack>`
3. Find matching track by track_number
4. Update fields:
   - TITLE: from preview "After" column
   - PERFORMER: from preview "After" column
   - COMMENT: from preview "After" column
5. Write back to file

### Phase 5: Error Handling & Backup

- Create backup before writing (~filename.cue.bak)
- If write fails, restore backup
- Notify user of success/failure
- Log errors to foobar2000 console

---

## Technical Details

### Key Data Structures

**TagChangePreview** (already exists):
```cpp
struct TagChangePreview {
    std::string field_name;      // "TITLE", "PERFORMER", etc.
    std::string original_value;  // Before conversion
    std::string converted_value; // After conversion
    std::string album;
    int track_number;
};
```

**CueTrack** (already exists):
```cpp
struct CueTrack {
    int track_number;
    std::string title;
    std::string performer;
    std::string comment;
    std::string index;
};
```

### File Writing Strategy

**Preserve Original Structure:**
- Read original CUE file line-by-line
- For each line:
  - If it's a convertible field (TITLE/PERFORMER/COMMENT):
    - Replace with converted version
  - If it's any other line (REM, FILE, INDEX, etc.):
    - Copy as-is to output
- Write complete output as UTF-8

**Example:**
```
Original:
  REM COMMENT "Album comment in Chinese"
  PERFORMER "Artist Name"
  TITLE "Album Name"
  FILE "audio.flac" FLAC
    TRACK 01 AUDIO
      TITLE "Track Title"
      PERFORMER "Track Artist"
      INDEX 01 00:00:00

Output (after conversion):
  REM COMMENT "Album comment in Chinese"  ← Copied (unchanged)
  PERFORMER "Artist Name Converted"       ← Updated
  TITLE "Album Name Converted"            ← Updated
  FILE "audio.flac" FLAC                  ← Copied (unchanged)
    TRACK 01 AUDIO                        ← Copied (unchanged)
      TITLE "Track Title Converted"       ← Updated
      PERFORMER "Track Artist Converted"  ← Updated
      INDEX 01 00:00:00                   ← Copied (unchanged)
```

### File Locking Considerations

- foobar2000 may have CUE file locked
- Solution: Write to temp file, then replace original
- Or: Request exclusive access from foobar2000 before writing

---

## Implementation Sequence

**Step 1:** Create CueFileWriter class (cue_file_writer.h + .cpp)
- Read original CUE file line-by-line
- For each line: check if it's a convertible field (TITLE/PERFORMER/COMMENT)
- If convertible: replace with value from CueTrack vector
- If not convertible: copy as-is (REM, FILE, INDEX, etc.)
- Write all lines as UTF-8

**Step 2:** Add helper in ui_preview_dialog.cpp
- `bool IsCueBasedTrack(const metadb_handle_ptr& track)`
- `std::string FindCueFileForTrack(const metadb_handle_ptr& track)`

**Step 3:** Modify preview dialog "Save" button handler
- Call CueFileWriter for CUE-based tracks
- Fall back to foobar2000 SDK for regular tracks

**Step 4:** Test with mixed playlist
- Some tracks from CUE files
- Some regular tracks (FLAC with ID3 tags)
- Verify both get updated correctly
- Verify all REM lines and formatting preserved

---

## Edge Cases to Handle

1. **Multiple CUE files** - Different .cue files in same directory
   - Use track path to find exact .cue file
   - Existing logic already handles this

2. **No track number in CUE** - Rare, but possible
   - Use track order as fallback
   - Match by sequence, not number

3. **UTF-8 write** - Converting from any encoding to UTF-8
   - CueParser already handles reading any encoding
   - When writing to UTF-8, use standard wstring_convert or similar
   - All converted text is already in UTF-8 from converter

4. **File permissions** - CUE file is read-only
   - Try to write, catch error
   - Notify user of permission issue
   - Provide option to save as new file

5. **File in use** - CUE file locked by foobar2000
   - Try write, handle file-locked error
   - May need to ask foobar2000 to release lock first
   - Or queue for deferred write after foobar2000 releases file

---

## Code Changes Summary

### New Files
- **cue_file_writer.h** - ~150 lines
- **cue_file_writer.cpp** - ~300 lines

### Modified Files
- **ui_preview_dialog.cpp** - Add 2 helper functions, modify button handler (30-50 lines)
- **component.cpp** - May need to link new module

### No Changes Needed
- cue_parser.cpp (reading works fine)
- tag_processor.cpp (internal database already works)
- converter.cpp (conversion logic unchanged)

---

## Testing Strategy

1. **Unit test** CueFileWriter with test .cue file
2. **Integration test** with real foobar2000
   - CUE-based FLAC album with Chinese tags
   - Convert Traditional → Simplified
   - Verify .cue file updated (hexdump to check encoding preserved)
   - Reload in foobar2000, verify new tags display

3. **Mixed test**
   - Playlist with both CUE tracks and regular FLAC tracks
   - Convert all at once
   - Verify both types update correctly

4. **Error test**
   - Read-only CUE file
   - Locked CUE file
   - Corrupted CUE file
   - Non-existent CUE file

---

## Risk Assessment

**Low Risk:**
- New module doesn't touch existing code paths
- Fallback to foobar2000 SDK for non-CUE tracks
- CUE file parsing already works (proven in cue_parser)

**Medium Risk:**
- File I/O on CUE files (permissions, locking)
- Encoding handling when writing back
- Edge cases with malformed CUE files

**Mitigation:**
- Create backup before writing
- Comprehensive error logging
- User notification of success/failure

---

## Success Criteria

✅ **Requirement Met:** When user converts tags in CUE-based tracks and clicks "Save":
- CUE file itself is updated (not just foobar2000 database)
- CUE file is written as UTF-8 (modern, universal format)
- Regular tracks still work normally
- User sees confirmation message
- Can reload CUE in foobar2000 and see new tags

