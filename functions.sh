#!/bin/bash

# Includes functions for various Git operations used by the script.

get_current_branch() {
    git branch --show-current 2>/dev/null
}

get_default_branch() {
    git remote show origin | awk '/HEAD branch/ {print $NF}' 2>/dev/null
}

check_git_installed() {
    command -v git &>/dev/null ||
        exit_with_error "Git is not installed. Please install Git and try again."
}

verify_git_config() {
    local git_user_name=$(git config --global user.name 2>/dev/null)
    local git_user_email=$(git config --global user.email 2>/dev/null)

    [ -n "$git_user_name" ] && [ -n "$git_user_email" ] || 
        exit_with_error "Git user name or email is not configured."
}

check_existing_repository() {
    if [ -d .git ]; then
        print_warning_message "Existing Git repository detected."
        while :; do
            read -p "> Remove existing Git history? [Y/n]: " choice
            case "${choice,,}" in
                y|"") 
                    rm -rf .git
                    print_success_message "Git history removed."
                    return 0 
                    ;;
                n) 
                    print_success_message "Operation cancelled."
                    return 1
                    ;;
                *) 
                    print_warning_message "Invalid selection. Please try again." 
                    ;;
            esac
        done
    fi
}

ensure_commit_files_exist() {
    local files_to_commit
    files_to_commit=$(find . -maxdepth 1 -mindepth 1 -not -name '.git' -print -quit)
    if [ -z "$files_to_commit" ]; then
        print_warning_message "No files detected for initial commit."
        return 1
    fi
    return 0
}

prompt_remote_url() {
    while :; do
        read -p "> Enter repository URL, owner/repo, or repo name: " input
        if [[ $input =~ ^[^/]+$ ]]; then
            local git_user_name=$(git config --global user.name)
            input="$git_user_name/$input"
        fi

        if [[ $input =~ ^(https://|git@)github.com[:/][^/]+/[^/]+\.git$ ]]; then
            echo "$input"
            return 0
        elif [[ $input =~ ^[^/]+/[^/]+$ ]]; then
            local protocol_choice=""
            while [[ ! $protocol_choice =~ ^[yn]$ ]]; do
                read -p "> Use SSH? [Y/n]: " protocol_choice
                case "${protocol_choice,,}" in
                    y|"") 
                        echo "git@github.com:${input}.git"
                        break
                        ;;
                    n) 
                        echo "https://github.com/${input}.git"
                        break
                        ;;
                    *) 
                        print_warning_message "Invalid selection. Please try again." 
                        ;;
                esac
            done
            return 0
        else
            print_warning_message "Invalid repository format."
            return 1
        fi
    done
}

test_remote_connection() {
    local remote_url="$1"
    if ! git ls-remote --heads "$remote_url" &>/dev/null; then
        print_warning_message "Unable to connect to remote: $remote_url"
        return 1
    fi
    return 0
}

ensure_remote_empty() {
    local remote_url="$1"
    if git ls-remote --heads "$remote_url" | grep -q .; then
        print_warning_message "Remote repository is not empty."
        return 1
    fi
    return 0
}

handle_non_empty_directory() {
    if [ "$(ls -A)" ]; then
        print_warning_message "Directory is not empty."
        while :; do
            read -p "> Clear directory contents? [Y/n]: " cleanup_choice
            case "${cleanup_choice,,}" in
                y|"")
                    find . -mindepth 1 -delete
                    print_success_message "Directory cleared."
                    return 0
                    ;;
                n) 
                    print_success_message "Operation cancelled."
                    return 1
                    ;;
                *) 
                    print_warning_message "Invalid choice." 
                    ;;
            esac
        done
    fi
}

check_remote_has_content() {
    local remote_url="$1"
    if ! git ls-remote --heads "$remote_url" | grep -q refs/heads/; then
        print_warning_message "Remote has no branches."
        return 1
    fi
    return 0
}

verify_inside_repository() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        print_warning_message "Not inside a Git repository."
        return 1
    fi
    return 0
}

ensure_clean_workspace() {
    if ! git diff-index --quiet HEAD -- || [ -n "$(git ls-files --others --exclude-standard)" ]; then
        if ! git diff-index --quiet HEAD --; then
            print_warning_message "Uncommitted changes detected."
        else
            print_warning_message "Untracked files detected."
        fi
        return 1
    fi
    return 0
}

verify_remote_exists() {
    if ! git remote get-url origin &>/dev/null; then
        print_warning_message "No remote 'origin' configured."
        return 1
    fi
    return 0
}