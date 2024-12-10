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

# Parse options
while getopts ":uphl:e:-:" opt; do
    case $opt in
        -u|--users)
            print_usr
            ;;
        -p|--processes)
            print_pid
            ;;
        -h|--help)
            print_ref
            ;;
        -l|--log)
            log_path=$OPTARG
            ;;
        -e|--errors)
            error_path=$OPTARG
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
        ?)
            echo "Invalid option: -$OPTARG" >&2
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

# Empty args
if [ $((OPTIND - 1)) -eq 0 ]; then
    print_ref
fi
