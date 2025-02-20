#!/bin/bash

# Defines the main operational logic for each menu option.

setup_repository() {
    print_section_header "Setup Repository"

    echo "[1] Initialize New Repo"
    echo "[2] Clone Existing Repo"
    echo "[3] Back to main menu"

    while :; do
        read -p "Select an option: " choice
        case $choice in
            1) 
                initialize_repo
                break
                ;;
            2) 
                clone_repository
                break
                ;;
            3) 
                break
                ;;
            *) 
                echo "Invalid selection. Please try again."
                ;;
        esac
    done
}

initialize_repo() {
    print_section_header "Initialize New Repo"
    list_directory_contents

    check_existing_repository || return
    ensure_commit_files_exist || return

    read -p "> Enter branch name [main]: " branch_name
    branch_name=${branch_name:-main}

    local remote_url
    while ! remote_url=$(prompt_remote_url) || 
        ! test_remote_connection "$remote_url" || 
        ! ensure_remote_empty "$remote_url"; do
        continue
    done

    git init -b "$branch_name"
    print_success_message "Initialized new repository with branch '$branch_name'."

    git remote add origin "$remote_url"
    print_success_message "Added remote repository at '$remote_url'."

    git add .
    print_success_message "Staged changes for commit."

    read -p "> Enter commit message [Initial commit]: " commit_message
    commit_message=${commit_message:-Initial commit}
    
    git commit -m "$commit_message"
    print_success_message "Committed changes with message: '$commit_message'."

    git push -u origin "$branch_name"
    print_success_message "Pushed to remote branch 'origin/$branch_name'."
    
    read -p "> Enter tag message [Initial release version v0.1.0]: " tag_message
    tag_message=${tag_message:-Initial release version v0.1.0}


    git tag -a v0.1.0 -m "$tag_message"
    print_success_message "Created new tag 'v0.1.0' with message: '$tag_message'."

    git push origin v0.1.0
    print_success_message "Pushed tag 'v0.1.0' to remote repository."
}

clone_repository() {
    print_section_header "Clone Existing Repo"
    list_directory_contents

    handle_non_empty_directory || return

    local remote_url
    while ! remote_url=$(prompt_remote_url) || 
        ! test_remote_connection "$remote_url" || 
        ! check_remote_has_content "$remote_url"; do
        continue
    done    
    
    git clone "$remote_url" .
    print_fill_line "-"
    list_directory_contents
    print_success_message "Repository cloned successfully: $remote_url"
}

commit_changes() {
    while :; do
        print_section_header "Commit Changes"

        verify_inside_repository || return
        verify_remote_exists || return

        if git diff --cached --quiet; then
            print_warning_message "No staged changes to commit."
        else
            print_success_message "Staged changes are ready to commit." 
        fi
        
        local staged_changes=$(git diff --cached --name-status)
        local modified_files=$(git diff --name-status)
        local untracked_files=$(git ls-files --others --exclude-standard)
        
        print_fill_line "-"
        echo "Staged changes:"
        if [ -z "$staged_changes" ]; then
            echo "  Nothing staged for commit."
        else
            echo "$staged_changes" | sed 's/^/  [Staged]  /'
        fi
        print_fill_line "-"
        echo "Modified files:"
        if [ -z "$modified_files" ]; then
            echo "  Tracked files are unmodified."
        else
            echo "$modified_files" | sed 's/^/  [Modified] /'
        fi
        print_fill_line "-"
        echo "Untracked files:"
        if [ -z "$untracked_files" ]; then
            echo "  No untracked files detected."
        else
            echo "$untracked_files" | sed 's/^/  [New]     /'
        fi
        print_fill_line "-"

        echo "[1] Commit changes"
        echo "[2] Stage all changes (modified + untracked)"
        echo "[3] Stage modified files only (Paid)"
        echo "[4] Stage untracked files only (Paid)"
        echo "[5] Interactive staging"
        echo "[6] Unstage all changes (Paid)"
        echo "[7] Undo last commit (Paid)"
        echo "[8] Back to main menu"

        while :; do
            read -p "> Choose action [1-8, default 1]: " choice
            choice=${choice:-1}
            
            case $choice in
                1)
                    if git diff --cached --quiet; then
                        print_notice_message "No staged changes to commit."
                    else
                        print_fill_line "-"
                        echo "About to commit these changes:"
                        echo "$staged_changes" | sed 's/^/  [Staged]  /'
                        print_fill_line "-"
                        
                        echo "Select commit type:"
                        echo "[1] feat     - New feature implementation"
                        echo "[2] fix      - Bug fix"
                        echo "[3] docs     - Documentation updates"
                        echo "[4] style    - Code formatting changes"
                        echo "[5] refactor - Code restructuring"
                        echo "[6] perf     - Performance improvements"
                        echo "[7] test     - Test-related changes"
                        echo "[8] chore    - Maintenance tasks"
    
                        declare -A commit_types
                        commit_types=(
                            [1]="feat"
                            [2]="fix"
                            [3]="docs"
                            [4]="style"
                            [5]="refactor"
                            [6]="perf"
                            [7]="test"
                            [8]="chore"
                        )
                        
                        while true; do
                            read -p "> Select commit type (1-7): " commit_choice
                            if [[ ${commit_types[$commit_choice]} ]]; then
                                commit_type=${commit_types[$commit_choice]}
                                break
                            fi
                            print_warning_message "Invalid selection."
                        done
                        
                        while :; do
                            read -p "> Enter commit message: " commit_msg
                            [ -n "$commit_msg" ] && break
                            print_warning_message "Commit message cannot be empty."
                        done
                        
                        formatted_commit_msg="$commit_type: $commit_msg"
                        local current_branch=$(get_current_branch)
                        git commit -m "$formatted_commit_msg"
                        print_success_message "Commit successful."

                        if ! git ls-remote --exit-code origin "$current_branch" >/dev/null; then
                            while :; do
                                read -p "> Remote branch '$current_branch' does not exist. Push and set upstream? [Y/n]: " choice
                                case "${choice,,}" in
                                    y|"")
                                        git push -u origin "$current_branch"
                                        print_success_message "Pushed new branch '$current_branch' to remote and set upstream."
                                        break
                                        ;;
                                    n)
                                        print_warning_message "Changes remain local - PRs unavailable until pushed."
                                        break
                                        ;;
                                    *)
                                        print_warning_message "Invalid selection. Please try again."
                                        ;;
                                esac
                            done
                        else
                            while :; do
                                read -p "> Push changes to remote branch '$current_branch'? [Y/n]: " choice
                                case "${choice,,}" in
                                    y|"")
                                        git push origin "$current_branch"
                                        print_success_message "Pushed changes to remote branch '$current_branch'."
                                        break
                                        ;;
                                    n)
                                        print_warning_message "Changes remain local - PRs unavailable until pushed."
                                        break
                                        ;;
                                    *)
                                        print_warning_message "Invalid selection. Please try again."
                                        ;;
                                esac
                            done
                        fi
                    fi
                    break
                    ;;
                2) 
                    git add -A
                    print_success_message "Staged all changes."
                    break
                    ;;
                3) 
                    print_notice_message "This is a paid functionality and is not available in the current version."
                    break
                    ;;
                4) 
                    print_notice_message "This is a paid functionality and is not available in the current version."
                    break
                    ;;
                5) 
                    git add -i
                    break
                    ;;
                6) 
                    print_notice_message "This is a paid functionality and is not available in the current version."
                    break 
                    ;;
                
                7)
                    print_notice_message "This is a paid functionality and is not available in the current version."
                    break
                    ;;
                8)
                    print_success_message "Exiting without committing."
                    return
                    ;;
                *)
                    print_warning_message "Invalid selection. Please try again."
                    ;;
            esac
        done

        read -n 1 -s -r -p "Press any key to return to the menu..."
    done
}

create_work_branch() {
    local branch_type="$1"

    print_section_header "${branch_type^} Creation Process"
    list_directory_contents

    verify_inside_repository || return
    ensure_clean_workspace || return
    verify_remote_exists || return

    local default_branch=$(get_default_branch)

    while :; do
        read -p "> Enter ${branch_type} name: " branch_name
        
        if [ -z "$branch_name" ]; then
            print_warning_message "${branch_type^} name cannot be empty."
            continue
        fi

        if [[ ! "$branch_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            print_warning_message "Invalid branch name. Use only letters, numbers, hyphens, and underscores."
            continue
        fi

        if git show-ref --quiet --verify "refs/heads/$branch_name"; then
            print_warning_message "Branch '$branch_name' already exists locally."
            continue
        fi

        if git show-ref --quiet --verify "refs/remotes/origin/$branch_name"; then
            print_warning_message "Branch '$branch_name' already exists on remote."
            continue
        fi

        break
    done

    git checkout "$default_branch"
    print_success_message "Checked out branch '$default_branch'."

    git pull origin "$default_branch"
    print_success_message "Pulled the latest changes from 'origin/$default_branch'."

    git checkout -b "${branch_type}/${branch_name}"
    print_success_message "Created new ${branch_type} branch: ${branch_type}/${branch_name}"

    while :; do
        read -p "> Push ${branch_type} branch to remote? [Y/n]: " choice
        case "${choice,,}" in
            y|"")
                git push -u origin "${branch_type}/${branch_name}"
                print_success_message "Pushed branch to remote: origin/${branch_type}/${branch_name}"
                break
                ;;
            n)
                print_success_message "${branch_type^} branch remains local: ${branch_type}/${branch_name}"
                break
                ;;
            *)
                print_warning_message "Invalid selection. Please try again." 
                ;;
        esac
    done
}

finish_work_branch() {
    print_section_header "Finish current Branch"
    list_directory_contents

    print_notice_message "This is a paid functionality and is not available in the current version."
}

switch_branch() {
    print_section_header "Switch to Branch"

    verify_inside_repository || return
    ensure_clean_workspace || return
    verify_remote_exists || return

    local remote_branches_before=$(git branch -r)
    git fetch --prune
    local remote_branches_after=$(git branch -r)
    
    if [[ "$remote_branches_before" != "$remote_branches_after" ]]; then
        print_success_message "Successfully pruned remote branches. Local references are now up to date."
    else
        print_success_message "No branches to prune. Local references are already up to date."
    fi

    print_fill_line "-"
    echo "Local branches:"
    git branch --format='%(refname:short)' | sed 's/^/  /'
    print_fill_line "-"
    
    echo "Remote branches:"
    print_notice_message "This is a paid functionality and is not available in the current version."
    print_fill_line "-"

    while :; do
        read -p "> Enter the branch name you want to switch to: " branch_name
        if [ -z "$branch_name" ]; then
            print_warning_message "Branch name cannot be empty. Please try again."
            continue
        fi

        local normalized_branch_name="${branch_name#origin/}"
        
        if git show-ref --quiet "refs/heads/$normalized_branch_name"; then
            git checkout "$normalized_branch_name"
            print_success_message "Switched to existing local branch '$normalized_branch_name'."
            break
        else
            print_warning_message "Branch '$normalized_branch_name' does not exist locally."
            while true; do
                read -p "> Would you like to try again? [Y/n]: " choise
                case "${choise,,}" in
                    y|"")
                        continue
                        ;;
                    n)
                        print_success_message "Operation switch cancelled by user."
                        return
                        ;;
                    *)
                        print_warning_message "Invalid selection."
                        continue
                        ;;
                esac
            done
        fi
    done
}