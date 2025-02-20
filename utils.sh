#!/bin/bash

# Contains utility functions for operations like printing messages, managing Git commands, etc.

declare -r COLOR_RED='\033[0;31m'
declare -r COLOR_GREEN='\033[1;32m'
declare -r COLOR_YELLOW='\033[1;33m'
declare -r COLOR_BLUE='\033[0;34m'
declare -r COLOR_RESET='\033[0m'

print_success_message() {
    echo -e "${COLOR_GREEN}SUCCESS:${COLOR_RESET} $1" >&2
}

print_warning_message() {
    echo -e "${COLOR_YELLOW}WARNING:${COLOR_RESET} $1" >&2
}

print_notice_message() {
    echo -e "${COLOR_BLUE}NOTICE:${COLOR_RESET} $1" >&2
}

exit_with_error() {
    echo -e "${COLOR_RED}ERROR:${COLOR_RESET} $1" >&2
    exit 1
}

print_fill_line() {
    local fill_char="${1:-=}"
    local terminal_width=$(tput cols)
    local fill_line=$(printf '%*s' "$terminal_width" | tr ' ' "$fill_char")
    
    echo "$fill_line"
}

list_directory_contents() {
    if [ -z "$(ls -A)" ]; then
        print_notice_message "Directory is empty."
    else
        ls -A
    fi
    print_fill_line "-"
}

print_section_header() {
    clear
    sleep 0.1

    print_fill_line
    echo "$1"
    print_fill_line

    check_git_installed
    verify_git_config
}