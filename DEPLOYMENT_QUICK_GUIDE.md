# Quick Deployment Guide: Win32 Component

## What You're Deploying

✅ **Facebook Foobar2000 Chinese Character Converter Component**
- Architecture: x86 (32-bit) - matches foobar2000 installation
- Real SDK Integration: Yes
- OpenCC Support: Yes (both Simplified↔Traditional)

## Installation Steps

### 1. Locate foobar2000 Installation
```
C:\Program Files (x86)\foobar2000\
```

### 2. Copy Component Files
```
From: e:\Ricky\Development\FB2K-Chinese\deployment-win32\user-components\foo_chinese_converter\
To:   C:\Program Files (x86)\foobar2000\user-components\foo_chinese_converter\
```

**Files to Copy:**
- `foo_chinese_converter.dll` (1.9 MB)
- `opencc.dll` (307 KB)

### 3. (Optional) Copy OpenCC Data
If present in deployment folder:
```
Copy: res\opencc-data\*
To:   C:\Program Files (x86)\foobar2000\user-components\foo_chinese_converter\res\
```

### 4. Restart foobar2000
- Close foobar2000 completely
- Reopen foobar2000
- Component should load automatically

## Verification

### Check Component Loaded
1. Open foobar2000
2. Go to: Preferences → Components
3. Look for: "Chinese Character Converter" in component list

### Test Component
**Current Status**: Backend only (no UI yet)
- Component will load and initialize
- Core conversion engine active
- Ready for Phase 4.5 UI implementation

### Check Console Output
- Preferences → Tools → Converter Console
- Look for initialization messages from component

## Current Capabilities

✅ **Working**
- ChineseConverter class loaded
- OpenCC library initialized
- SC↔TC conversion methods available
- SDK integration active

⏸️ **Deferred to Phase 4.5**
- Right-click context menu (UI framework prepared)
- Preferences dialog (stub implemented)
- Tag batch conversion interface

## Troubleshooting

### Component Not Loading
**Check:**
1. DLL is in correct folder: `user-components\foo_chinese_converter\`
2. Architecture matches foobar2000 (x86) - ✅ Confirmed
3. DLL is readable/not quarantined by antivirus

### DLL Load Errors
**Common Causes:**
- Missing `opencc.dll` in same folder
- Folder permissions (user-components must be writable)
- Corrupted download - verify file sizes:
  - foo_chinese_converter.dll: 1,939,456 bytes
  - opencc.dll: 306,688 bytes

### Windows Errors
If you see "Not a valid Win32 application":
- ❌ WRONG: You're using x64 DLL with x86 foobar2000
- ✅ CORRECT: Using Win32 build from deployment folder (verified x86)

## Build Details

| Property | Value |
|---|---|
| Machine Type | 14C (x86) |
| Exported Function | foobar2000_get_interface |
| SDK Type | Real (production) |
| Compilation Status | 0 errors, 0 warnings |

## Next Steps

### After Deployment
- Verify component appears in Preferences → Components
- Prepare for Phase 4.5 UI implementation
- Context menu and preferences dialog development

### Phase 4.5: UI Implementation
- Context menu with SC→TC, TC→SC options
- Configuration preferences page
- Tag batch conversion interface

## Support Information

### Files Location
- **Deployment Folder**: `e:\Ricky\Development\FB2K-Chinese\deployment-win32\`
- **Source Code**: `e:\Ricky\Development\FB2K-Chinese\fb2k_component\src\`
- **Build Output**: `e:\Ricky\Development\FB2K-Chinese\fb2k_component\build-win32\`

### Building Again
```powershell
cd e:\Ricky\Development\FB2K-Chinese\fb2k_component\build-win32
msbuild fb2k_chinese_component.vcxproj /p:Configuration=Debug /p:Platform=Win32
```

Output DLL: `build-win32\Debug\foo_chinese_converter.dll`

---

**Status**: Ready for deployment ✅

**Next Action**: Copy component files to foobar2000 user-components folder
