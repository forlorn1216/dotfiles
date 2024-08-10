#!/bin/zsh

# Prompt for a directory to extract the zip file
export GTK_THEME=Colloid-Dark-Dracula
dest_dir=$(zenity --file-selection --directory --title="Select a directory to extract to")

if [ -n "$dest_dir" ]; then
    unar -d -o "$dest_dir" "$@"
fi
