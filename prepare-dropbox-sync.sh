#!/bin/bash

DROPBOX_BASE="$HOME/Dropbox/Linux Files"
TARGET_BASE="$HOME"
BACKUP_DIR="$HOME/Dropbox_Setup_Local_Backup_$(date +%Y%m%d_%H%M%S)"
MKDIR_BACKUP=false

FOLDERS=(
    "Documents"
    "Downloads"
    "Desktop"
    "Music"
    "Pictures"
    "Projects"
    "Public"
    "Templates"
    "Videos"
)

echo "--- Starting Dropbox Symlink Setup ---"

if [ ! -d "$DROPBOX_BASE" ]; then
    echo "CRITICAL ERROR: Dropbox source folder not found: $DROPBOX_BASE"
    echo "Please ensure Dropbox is running and fully synced."

    exit 1
fi

for FOLDER in "${FOLDERS[@]}"; do
    SRC="$DROPBOX_BASE/$FOLDER"
    DEST="$TARGET_BASE/$FOLDER"

    if [ ! -d "$SRC" ]; then
        echo "[SKIP] Source folder not found in Dropbox: $FOLDER"
        continue
    fi

    if [ -e "$DEST" ]; then
        # It's already a symlink
        if [ -L "$DEST" ]; then
            CURRENT_LINK=$(readlink -f "$DEST")
            if [ "$CURRENT_LINK" == "$SRC" ]; then
                echo "[OK] $FOLDER is already linked correctly."
                continue
            else
                echo "[FIX] $FOLDER is an incorrect link. Removing..."
                rm "$DEST"
            fi
        # It's a real directory
        elif [ -d "$DEST" ]; then
            if [ -z "$(ls -A "$DEST")" ]; then
                # Directory is empty
                echo "[INFO] Local $FOLDER is empty. Removing..."
                rmdir "$DEST"
            else
                # Backup existing local directory
                echo "[WARNING] Local $FOLDER has content. Moving to backup..."
                if [ "$MKDIR_BACKUP" = false ]; then
                    mkdir -p "$BACKUP_DIR"
                    MKDIR_BACKUP=true
                fi
                mv "$DEST" "$BACKUP_DIR/"
                echo "        Moved to: $BACKUP_DIR/$FOLDER"
            fi
        fi
    fi

    ln -s "$SRC" "$DEST"

    if [ $? -eq 0 ]; then
        echo "[SUCCESS] Linked $FOLDER -> Dropbox"
    else
        echo "[ERROR] Failed to link $FOLDER"
    fi
done

echo "--- Updating System Folder Definitions (XDG) ---"

if command -v xdg-user-dirs-update &> /dev/null; then
    xdg-user-dirs-update --set DOCUMENTS "$TARGET_BASE/Documents"
    xdg-user-dirs-update --set DOWNLOADS "$TARGET_BASE/Downloads"
    xdg-user-dirs-update --set DESKTOP "$TARGET_BASE/Desktop"
    xdg-user-dirs-update --set MUSIC "$TARGET_BASE/Music"
    xdg-user-dirs-update --set PICTURES "$TARGET_BASE/Pictures"
    xdg-user-dirs-update --set PUBLICSHARE "$TARGET_BASE/Public"
    xdg-user-dirs-update --set TEMPLATES "$TARGET_BASE/Templates"
    xdg-user-dirs-update --set VIDEOS "$TARGET_BASE/Videos"

    xdg-user-dirs-update

    echo "[OK] System XDG directories updated to English paths."
else
    echo "[WARN] xdg-user-dirs-update command not found. Skipping system registration."
fi

if [ "$MKDIR_BACKUP" = true ]; then
    echo ""
    echo "IMPORTANT: Some local files were moved to $BACKUP_DIR to prevent data loss."
fi

echo "--- Setup Complete ---"