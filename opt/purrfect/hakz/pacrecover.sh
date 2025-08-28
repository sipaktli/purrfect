#!/bin/env bash
# Deleted your pacman DB by mistake?
# This will fix it.

# Find binaries and libraries found in system
_a=("/usr/bin" "/usr/lib32" "/usr/lib64")
mapfile -t _1 < <(find ${_a[@]} -type f | awk -F "/" '{print $4}' | sort -u)

# Get a list of packages those files belong to
mapfile -t _2 < <(pkgfile ${_1[@]} | sort -u)

# Get a list of installed packages
mapfile -t _3 < <(pacman -Qqn | sort -u)

# Compare the the lists to guess what packages are installed in the system
for i in "${_3[@]}"; do
    if ! printf '%s\n' "${_2[@]}" | grep -q -- "^${i}$"; then
        echo "$i"
    fi
done
