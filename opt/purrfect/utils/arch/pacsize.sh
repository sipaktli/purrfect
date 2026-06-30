#/bin/env bash

# List top 50 installed packages by size.
alias pacsize="pacman -Qi | grep -E '^(Name|Installed)' | cut -f2 -d':' | paste - - | column -t | sort -nrk 2 | grep MiB | head -n 50"


