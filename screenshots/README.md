# Screenshots - Chinese Character Converter Component

## Screenshot 1: Context Menu Integration

**File:** `screenshot-01-context-menu.png`

Shows the right-click context menu in foobar2000 with the component's features integrated:

- **"Convert to Traditional Chinese"** - Option to convert tags from Simplified to Traditional
- **"Convert to Simplified Chinese"** - Option to convert tags from Traditional to Simplified
- **"Sanitize tags..."** - Additional tag management option

The menu is cleanly integrated under the **Tagging** submenu, exactly where users expect to find metadata operations.

### Key Features Visible
✅ Clean menu integration
✅ Both conversion directions available
✅ Non-intrusive UI (doesn't clutter the menu)
✅ Located in logical "Tagging" submenu

---

## Screenshot 2: Tag Conversion Preview

**File:** `screenshot-02-tag-conversion-preview.png`

Shows the conversion preview dialog displaying before/after tag transformations:

### Left Column (Source - UTF-8 Simplified)
- Album: 精装杨小琳 SACD
- Artist: 杨小琳
- PERFORMER: 杨小琳
- TITLE: 夜来香
- Album: 精装杨小琳 SACD
- Artist: 杨小琳
- PERFORMER: 杨小琳
- TITLE: 千百万语
- ...and more tracks

### Right Column (Result - Traditional Chinese)
- Album: 精裝楊小琳 SACD
- Artist: 楊小琳
- PERFORMER: 楊小琳
- TITLE: 夜來香
- Album: 精裝楊小琳 SACD
- Artist: 楊小琳
- PERFORMER: 楊小琳
- TITLE: 千百萬語
- ...converted tracks

### Key Features Visible
✅ Side-by-side before/after comparison
✅ Shows actual character transformations (杨→楊, 夜来→夜來, etc.)
✅ Handles multiple tracks and multiple fields
✅ Clear visual preview before committing changes
✅ Users can review and cancel if needed

### Example Transformations Shown
- 杨 (simplified) → 楊 (traditional)
- 来 (simplified) → 來 (traditional)
- 语 (simplified) → 語 (traditional)
- 装 (simplified) → 裝 (traditional)

---

## How These Screenshots Demonstrate the Component

1. **User-Friendly**: The context menu is intuitive and doesn't break foobar2000's design
2. **Accurate Conversions**: The preview shows correct Simplified ↔ Traditional transformations
3. **Batch Operations**: Both screenshots show multiple tracks being processed at once
4. **Preview Before Commit**: Users can see exactly what will change before saving
5. **Non-Destructive**: The preview dialog allows users to review changes before finalizing

---

## Using These Screenshots

These screenshots are perfect for:
- GitHub repository README
- Forum post to Hydrogenaudio
- Documentation on how to use the component
- Feature demonstration for potential users
- Proof that the component works correctly

---

**Captured:** November 11, 2025
**Component Version:** v1.0.0
**foobar2000 Version:** v2.1
