# Release v1.0.0 - Initial Release

## What's New

First stable release of the Chinese Character Converter component for foobar2000!

## Features

- ✅ Bidirectional Simplified ↔ Traditional Chinese conversion
- ✅ Works on any metadata field
- ✅ Non-blocking async operations (UI never freezes)
- ✅ Batch convert multiple tracks at once
- ✅ Support for multiple Traditional Chinese variants
- ✅ Both x86 (32-bit) and x64 (64-bit) builds

## Installation

1. **Download** the appropriate `.fb2k-component` file for your foobar2000 version:
   - **32-bit**: `foo_chinese_converter-v1.0.0-x86.fb2k-component`
   - **64-bit**: `foo_chinese_converter-v1.0.0-x64.fb2k-component`

2. **Install** by dragging the `.fb2k-component` file into foobar2000
   - Or manually extract to: `%APPDATA%\foobar2000\profile\user-components\`

3. **Restart** foobar2000 (it will auto-restart after drag-drop)

## Usage

1. Open Metadata Editor (Ctrl+E)
2. Select tracks to convert
3. Right-click any metadata field
4. Choose: **Tagging → Convert to Traditional Chinese** (or Simplified)
5. Save your changes

## Package Contents

- `foo_chinese_converter.dll` - Main component (architecture-specific)
- `opencc.dll` - OpenCC conversion library
- `opencc/` - Conversion data files and rules
- `component.txt` - Component metadata
- `README.txt` - Quick start guide

## Requirements

- foobar2000 v2.1 or later
- Windows XP SP3 or later (x86) or Windows Vista+ (x64)
- ~1 MB disk space

## Known Limitations

- Primarily handles mainland Simplified → Taiwan Traditional conversion
- Other variants available via conversion chain
- Manual operation (right-click in metadata editor)

## Technical Details

- Built with official foobar2000 SDK
- Uses OpenCC library for accurate conversions
- Written in C++ for performance
- Non-blocking async operations
- Proper error handling for edge cases

## File Sizes

- **x86 Package**: 0.68 MB
- **x64 Package**: 0.7 MB

## Feedback

Have a bug report or feature request? Please open an [issue](https://github.com/wmtang2/FB2K-Chinese/issues)!

---

**Released:** November 11, 2025  
**Version:** 1.0.0  
**Status:** Stable