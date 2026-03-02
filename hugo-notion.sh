#!/bin/bash


ZIP_DIR="ZipNotions"
POSTS_DIR="content/posts"
TEMP_DIR="temp_extraction"


if [ ! -d "$ZIP_DIR" ]; then
    echo "❌ Error: Folder $ZIP_DIR not found!"
    exit 1
fi

for SOURCE_ZIP in "$ZIP_DIR"/*.zip; do
    [ -e "$SOURCE_ZIP" ] || continue

    echo "-------------------------------------------------------"
    echo "📦 Processing: $(basename "$SOURCE_ZIP")"
    
    mkdir -p "$TEMP_DIR"
    unzip -q "$SOURCE_ZIP" -d "$TEMP_DIR"

    
    NESTED_ZIP=$(find "$TEMP_DIR" -name "*.zip" | head -n 1)
    if [ -n "$NESTED_ZIP" ]; then
        unzip -q -o "$NESTED_ZIP" -d "$TEMP_DIR"
    fi

    
    MD_PATH=$(find "$TEMP_DIR" -path "*Private & Shared*" -name "*.md" | head -n 1)

    if [ -z "$MD_PATH" ]; then
        echo "⚠️  Markdown file not found in 'Private & Shared'. Skipping..."
        rm -rf "$TEMP_DIR"
        continue
    fi

   
    FULL_MD_NAME=$(basename "$MD_PATH" .md)
    CLEAN_FOLDER_NAME=$(echo "$FULL_MD_NAME" | sed -E 's/ [a-z0-9]{32}$//')
    
    echo "📄 Found post: $CLEAN_FOLDER_NAME"

   
    read -p "📝 Enter Title (Enter for '$CLEAN_FOLDER_NAME'): " USER_TITLE
    USER_TITLE=${USER_TITLE:-$CLEAN_FOLDER_NAME}

    read -p "📅 Enter Date (YYYY-MM-DD): " USER_DATE
    until [[ "$USER_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; do
        echo "❌ Invalid format. Use YYYY-MM-DD."
        read -p "📅 Enter Date (YYYY-MM-DD): " USER_DATE
    done

    
    SLUG=$(echo "$USER_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/[^a-z0-9-]//g')
    DEST_DIR="$POSTS_DIR/$SLUG"
    mkdir -p "$DEST_DIR"

    
    IMAGE_SRC_DIR=$(find "$TEMP_DIR" -type d -name "$CLEAN_FOLDER_NAME" | head -n 1)

    if [ -n "$IMAGE_SRC_DIR" ] && [ -d "$IMAGE_SRC_DIR" ]; then
        echo "📸 Found image folder: $(basename "$IMAGE_SRC_DIR")"
        cp -rv "$IMAGE_SRC_DIR"/* "$DEST_DIR/"
    else
        echo "🔍 Searching for any folder in 'Private & Shared' as fallback..."
        FALLBACK_DIR=$(find "$TEMP_DIR/Private & Shared" -maxdepth 1 -type d ! -path "$TEMP_DIR/Private & Shared" | head -n 1)
        if [ -n "$FALLBACK_DIR" ]; then
            cp -rv "$FALLBACK_DIR"/* "$DEST_DIR/"
        fi
    fi

    
    FIXED_CONTENT=$(perl -pe "s/!\[(.*?)\]\((.*?\/)?([^\/)]+)\)/![\$1](\$3)/g" "$MD_PATH")

    
    cat <<EOF > "$DEST_DIR/index.md"
---
title: "$USER_TITLE"
date: ${USER_DATE}T12:00:00Z
draft: false
---

$FIXED_CONTENT
EOF

   
    COMMIT_MSG="Added $USER_TITLE"
    git add "$DEST_DIR"
    git commit -m "$COMMIT_MSG"
    echo "💾 Committed: '$COMMIT_MSG'"

    
    echo "🗑️  Deleting processed zip: $(basename "$SOURCE_ZIP")"
    rm "$SOURCE_ZIP"
    rm -rf "$TEMP_DIR"
done

echo "-------------------------------------------------------"
read -p "🚀 All posts committed. Push to GitHub? [y/n]: " PUSH_CONFIRM
if [[ "$PUSH_CONFIRM" == "y" ]]; then
    git push origin main
    echo "✨ Site updated and ZipNotions folder cleared!"
fi