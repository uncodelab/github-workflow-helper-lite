#!/bin/bash

# The main script file.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/functions.sh"
source "$SCRIPT_DIR/operations.sh"

# Main execution flow
while :; do
    print_section_header "Repository Management Console - Lite"
    
    echo "[1] Setup Repository"
    echo "[2] Commit Changes"
    echo "[3] Feature start"
    echo "[4] Hotfix start"
    echo "[5] Finish current branch (Paid)"
    echo "[6] Switch Branch"
    echo "[7] Exit"
    
    while :; do
        read -p "> Enter selection (1-7): " choice
        case $choice in
            1) 
                setup_repository 
                break
                ;;
            2) 
                commit_changes 
                break
                ;;
            3) 
                create_work_branch "feature" 
                break
                ;;
            4) 
                create_work_branch "hotfix" 
                break
                ;;
            5) 
                finish_work_branch 
                break
                ;;
            6) 
                switch_branch 
                break
                ;;
            7) 
                print_success_message "Exiting management system"
                exit 0
                ;;
            *) 
                print_warning_message "Invalid selection. Please try again."
                ;;
        esac
    done
    read -n 1 -s -r -p "Press any key to return to the main menu..."
done