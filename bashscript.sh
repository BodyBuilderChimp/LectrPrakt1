#!/bin/bash

# Output reference
print_ref() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo "Options:"
    echo "  -u, --users          Display list of users and their home directories sorted alphabetically."
    echo "  -p, --processes      Display list of running processes sorted by their ID."
    echo "  -h, --help           Display this help message and exit."
    echo "  -l PATH, --log PATH  Redirect output to a file at the specified PATH."
    echo "  -e PATH, --errors PATH Redirect errors to a file at the specified PATH."
    exit 0
}

# Users and dirs
print_usr() {
    awk -F: '$3 >= 1000 {print $1 "\t" $6}' /etc/passwd | sort
}

# Processes
print_pid() {
    ps -e --sort=pid
}

# Path validation
validate_path() {
  local path="$1"
  if [[ ! -d "$(dirname "$path")" ]]; then
    echo "Invalid path '$path'" >&2
    return 1
  fi
  return 0
}

# Parse options using getopt
OPTIONS=$(getopt -o uphl:e: --long users,processes,help,log:,errors: -- "$@")
if [ $? -ne 0 ]; then
    print_ref
fi
eval set -- "$OPTIONS"

# Initialize variables
log_path=""
error_path=""

# Process options
while true; do
    case "$1" in
        -u|--users)
            display_users=true
            shift
            ;;
        -p|--processes)
            display_processes=true
            shift
            ;;
        -h|--help)
            print_ref
            ;;
        -l|--log)
            log_path="$2"
            shift 2
            ;;
        -e|--errors)
            error_path="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Invalid option: $1" >&2
            exit 1
            ;;
    esac
done

# Redirect output if specified
if [ -n "$log_path" ]; then
    validate_path "$log_path" || exit 1
    exec > "$log_path"
fi

if [ -n "$error_path" ]; then
    validate_path "$error_path" || exit 1
    exec 2> "$error_path"
fi

# Check which option was selected to display output
if [[ "$display_users" == true ]]; then
    print_usr
fi

if [[ "$display_processes" == true ]]; then
    print_pid
fi

# Empty args
if [ -z "$display_users" ] && [ -z "$display_processes" ]; then
    print_ref
fi
