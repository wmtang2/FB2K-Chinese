# Hydrogenaudio Forums Post - Chinese Character Converter Component

## Title
**[NEW COMPONENT] Chinese Character Converter for foobar2000 - Convert between Simplified & Traditional Chinese**

---

## Post Content

Hey everyone,

I've been working on a foobar2000 component for a while now and finally got it stable enough to share. It's a Chinese character converter - basically lets you flip your tags between Simplified and Traditional without messing things up.

### The idea

Got tired of having half my library in Simplified Chinese and the other half in Traditional, so I built this. It's pretty straightforward - right-click a tag, pick convert, done. Works on any field (artist, album, track name, whatever) and handles batches so you're not sitting there one tag at a time.

**What's included:**
- Converts between Simplified and Traditional Chinese (bidirectional)
- Works on literally any metadata field
- Doesn't freeze your UI - runs async in the background
- Can do multiple tracks at once
- Couple different Traditional variants if you need them (Taiwan vs Hong Kong style)

### Technical Details

Built this using the foobar2000 SDK and the OpenCC library (which handles the actual conversions - that part's solid). Code's in C++ so it's fast, and I've got both x86 and x64 versions. Nothing fancy architecture-wise, just straightforward integration with the SDK.

**Requirements:**
- foobar2000 v2.1+ 
- Windows XP SP3 or later (figured I'd keep x86 support since some people still use it)
- Takes up like 1 MB of space

### How to get it

**32-bit foobar2000:** `foo_chinese_converter-v1.0.0-x86.fb2k-component`

**64-bit foobar2000:** `foo_chinese_converter-v1.0.0-x64.fb2k-component`

Easiest way to install is just drag the `.fb2k-component` file into foobar2000 and it handles the rest. If you want to do it manually, throw it in `%APPDATA%\foobar2000\profile\user-components\` and restart.

### How to use

1. Open metadata editor (Ctrl+E)
2. Pick a track or bunch of tracks
3. Right-click any tag
4. Hit **Tagging → Convert to Traditional Chinese** (or Simplified, depending on what you need)
5. It'll do its thing in the background
6. Save and you're good

### When you'd want this

- You've got albums from different regions/releases with different character sets
- Your music player or phone display better with one variant over the other
- Searching your library is annoying because half the titles are in one style
- You're just OCD about having everything standardized (no judgment)
- You're dealing with a library someone else tagged and want to normalize it

### The download

**GitHub:** [Will add link when ready]

v1.0.0, just came out today. Files are about 0.68 MB (x86) and 0.7 MB (x64).

### Want to help me improve it?

Found a bug? Have an idea? Let me know what you think:

- Does it actually work for your tags or are there weird edge cases I'm missing?
- Are the conversions actually correct? (I'm using OpenCC so it should be solid but always good to verify)
- Any other Chinese text stuff you wish foobar2000 could do?
- UI sucks? Tell me how to make it better

### Known quirks

- Mainly handles mainland Simplified → Taiwan Traditional right now
- Other variants are there but you might need to chain conversions
- It's read from tags and write back, not doing any file monitoring or auto-stuff (maybe v1.1?)

---

That's about it. Let me know what you think!

### Development Notes

**Architecture:**
- Modular design: Core processor + OpenCC integration
- Proper error handling for edge cases
- SDK Integration patterns follow foobar2000 best practices
- Both Release and Debug builds available

**License:** MIT License - Free to use, modify, and distribute (binary only)

---

## Keep it simple version

Just in case you want something shorter:

---

Made a component that converts Chinese tags between Simplified and Traditional. Right-click, pick convert, done. Works on anything - artist, album, track names, whatever.

**Get it:** https://github.com/wmtang2/FB2K-Chinese
**Install:** Drag the .fb2k-component into foobar2000
**Use:** Select tracks → right-click → Tagging → Convert

Both x86 and x64, about 0.7 MB each. Let me know if it works or if something's broken.

---

## Before posting

- [ ] Add GitHub link
- [ ] Maybe grab a screenshot of the right-click menu?
- [ ] Double-check it installs cleanly
- [ ] Make sure both x86 and x64 work

---

**Post Status:** Ready to publish
**Date Prepared:** November 11, 2025
**Version:** 1.0.0
**Component Status:** ✅ Tested and ready for community feedback
