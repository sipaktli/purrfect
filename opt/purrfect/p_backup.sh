#!/bin/env bash
set -euo pipefail

CONF="purrfect.conf"

# read config
compression_type=""
compression_params=""
checksum="none"
sources=""
destination=""

while IFS='=' read -r key val; do
    case "$key" in
        compression_type) compression_type="$val" ;;
        compression_params) compression_params="$val" ;;
        checksum) checksum="$val" ;;
        sources) sources="$val" ;;
        destination) destination="$val" ;;
    esac
done < <(grep -v '^[[:space:]]*#' "$CONF" | sed '/^[[:space:]]*$/d')

[ -z "$sources" ] && { echo "No sources defined"; exit 1; }
[ -z "$destination" ] && { echo "No destination defined"; exit 1; }

ts=$(date +%Y:%b:%d:%a-%H%M%S)
tmpfile="/tmp/backup-$ts.tar"

# make tar archive of sources
IFS=',' read -ra SRC <<< "$sources"
tar -cf "$tmpfile" "${SRC[@]}"

# compress
case "$compression_type" in
    xz) comp_ext="xz"; xz $compression_params "$tmpfile" ;;
    gz) comp_ext="gz"; gzip $compression_params "$tmpfile" ;;
    bz2) comp_ext="bz2"; bzip2 $compression_params "$tmpfile" ;;
    tar|"") comp_ext="tar" ;;
    *) echo "Unknown compression type: $compression_type"; exit 1 ;;
esac

[ "$compression_type" = "tar" ] && backupfile="$tmpfile" \
    || backupfile="$tmpfile.$comp_ext"

# checksum
if [ "$checksum" != "none" ]; then
    case "$checksum" in
        md5sum|sha1sum|sha256sum|sha512sum) ;;
        *) echo "Unknown checksum type: $checksum"; exit 1 ;;
    esac
    $checksum "$backupfile" > "$backupfile.$checksum"
fi

# copy to destination
if [[ "$destination" =~ ^ssh:([^:]+):(.*)$ ]]; then
    host="${BASH_REMATCH[1]}"
    path="${BASH_REMATCH[2]}"
    rsync -av "$backupfile"* "ssh://$host/$path"
elif [[ "$destination" =~ ^ftp:([^:]+):(.*)$ ]]; then
    host="${BASH_REMATCH[1]}"
    path="${BASH_REMATCH[2]}"
    rsync -av "$backupfile"* "ftp://$host/$path"
else
    rsync -av "$backupfile"* "$destination/"
fi

echo "Backup complete: $backupfile"
