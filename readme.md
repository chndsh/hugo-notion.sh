

# 🚀 Notion to Hugo: Page Bundle Importer

This script is a specialized automation tool designed to take **Notion ZIP exports**, unbox them, clean up the "UUID gibberish," and convert them into **Hugo Page Bundles** with a single command.

## 🛠 Features

- **Recursive Unzipping:** Automatically handles the "zip-within-a-zip" structure common in Notion exports.
- **Deep Image Discovery:** Locates image folders even when they are nested inside `Private & Shared` directories.
- **UUID Cleaning:** Strips the 32-character Notion ID from filenames to create clean URLs and titles.
- **Interactive Metadata:** Prompts you for a custom **Title** and **Backdate** for every post.
- **Auto-Commit:** Automatically creates a Git commit for each post with the message: `Added [Your Title]`.
- **Automatic Cleanup:** Deletes the source ZIP files and temporary folders once the import is successful.

---

## 📂 Project Requirements

For the script to function correctly, ensure your Hugo directory is structured as follows:

```text
your-hugo-site/
├── ZipNotions/         # 📥 Drop your Notion export ZIPs here
├── content/
│   └── posts/          # 📄 Page Bundles will be created here
├── static/
├── hugo-notion.sh      # The script
└── hugo.toml           # Hugo configuration

```

---

## 🚀 How to Use

### 1. Prepare the Script

Ensure the script has execution permissions:

```bash
chmod +x hugo-notion.sh

```

### 2. Export from Notion

1. In Notion, go to the page you want to export.
2. Click **Export** -> **Markdown & CSV**.
3. Include images (Default).
4. Move the resulting `.zip` file into your `ZipNotions/` folder.

### 3. Run the Import

Execute the script from your Hugo root:

```bash
./hugo-notion.sh

```

### 4. Interactive Prompts

For each ZIP found, the script will ask:

1. **Title:** Press `Enter` to use the Notion filename or type a new one.
2. **Date:** Enter the post date in `YYYY-MM-DD` format.
3. **Push:** After all ZIPs are processed, it will ask if you want to push all commits to GitHub.

---

## 🖼 How it Handles Images

Notion exports images into a subfolder. This script:

1. Finds that folder (even if it's missing the UUID).
2. Moves the images directly into the Page Bundle folder.
3. Rewrites the Markdown links from `![Alt](Folder%20UUID/image.png)` to `![Alt](image.png)`.

This ensures your images load perfectly in Hugo's "Page Bundle" mode without broken paths.

---

---

### ⚠️ Warnings

- **Deletion:** This script **deletes** the source ZIP files from `ZipNotions/` after a successful import.
- **Case Sensitivity:** Ensure your Hugo environment matches the case sensitivity of your filenames.
