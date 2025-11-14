# How to Add Screenshots to the Repository

Since the screenshot files were provided as image attachments, you need to save them to the repository manually.

## Steps to Save and Push Screenshots

### 1. Save the Screenshot Files

You have two screenshots to save to: `e:\Ricky\Development\FB2K-Chinese\screenshots\`

**Screenshot 1 - Context Menu**
- **Filename:** `screenshot-01-context-menu.png`
- **Shows:** Right-click context menu with Convert options
- **Save location:** `e:\Ricky\Development\FB2K-Chinese\screenshots\screenshot-01-context-menu.png`

**Screenshot 2 - Tag Conversion Preview**
- **Filename:** `screenshot-02-tag-conversion-preview.png`
- **Shows:** Before/after tag conversion table
- **Save location:** `e:\Ricky\Development\FB2K-Chinese\screenshots\screenshot-02-tag-conversion-preview.png`

### 2. From Your VS Code or File Explorer

1. In VS Code, go to the attachments tab
2. Right-click each image
3. Select "Save as..."
4. Save to: `e:\Ricky\Development\FB2K-Chinese\screenshots\`
5. Use the filenames above

OR

1. Open `e:\Ricky\Development\FB2K-Chinese\screenshots\` in File Explorer
2. Drag the screenshot files from the attachment viewer into this folder

### 3. Commit and Push to GitHub

Once the files are saved, run:

```powershell
cd 'e:\Ricky\Development\FB2K-Chinese'
git add screenshots/screenshot-01-context-menu.png
git add screenshots/screenshot-02-tag-conversion-preview.png
git commit -m "Add component screenshots - context menu and tag conversion preview"
git push origin main
```

### Expected Result

After pushing, your GitHub repo will have:
- Screenshots visible in the README.md (images will display inline)
- Files accessible at: https://github.com/wmtang2/FB2K-Chinese/tree/main/screenshots

---

**Action Required:** Save the image files to the screenshots directory, then run the git commands above.
