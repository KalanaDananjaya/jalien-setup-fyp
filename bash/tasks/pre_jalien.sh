#!/bin/bash

set -e


executeMake=$2

clone_if_not_exists() {
    local dir_name="$1"
    local git_repo="$2"
    if [ ! -d "$dir_name" ]; then
        git clone "$git_repo" "$dir_name"
        echo "$git_repo cloned to $dir_name."
    else
        echo "Directory $dir_name already exists, skipping cloning."
        pull_new_changes "$dir_name"
    fi

}

pull_new_changes() {
    local dir_name="$1"
    cd "$dir_name" || return

    # Fetch changes from all remote branches
    git fetch --all

    # Check if there are any changes to be pulled
    if [ $(git rev-list HEAD...@{u} --count) -gt 0 ]; then
    
        # Attempt to pull changes from all remote branches
        if git pull --all; then
            echo "Changes pulled successfully."
        else
            echo "Failed to pull changes. Resolving conflicts..."
        fi
      
    else
        echo "No new changes to pull."
    fi
}
mkdir -p "$BASE_DIR" && cd "$BASE_DIR" || exit 1
clone_if_not_exists "$JALIEN_SETUP" "$JALIEN_SETUP_SOURCE"
cd "$JALIEN_SETUP" || exit 1
if [ "$executeMake" = "true" ]; then
    echo "Start building Docker images...."
    sudo make all
    echo "All Docker images built succcessfully."
fi
cd "$SCRIPT_DIR"

clone_if_not_exists "$JALIEN" "$JALIEN_SOURCE"
# "$SCRIPT_DIR/tasks/sync_jar.sh" "$SCRIPT_DIR/config/config.sh"
