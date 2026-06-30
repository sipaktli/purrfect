#!/bin/env bash
set -euo pipefail

CONF="purrfect.conf"
LOG="mydaemon"

log() { logger -t "$LOG" "$*"; }

declare -A CMDS TIMES NEXT

load_conf() {
    CMDS=() TIMES=()
    while IFS='=' read -r key val; do
        [[ "$key" =~ ^#|^$ ]] && continue
        key="${key//[[:space:]]/}"
        val="${val##*( )}"
        case "$key" in
            command:*) CMDS["${key#command:}"]="$val" ;;
            time:*)    TIMES["${key#time:}"]="$val" ;;
        esac
    done < "$CONF"
}

delay_from_spec() {
    local spec="$1"
    case "$spec" in
        +*h) echo $(( ${spec#+} * 3600 )) ;;
        +*m) echo $(( ${spec#+} * 60 )) ;;
        +*s) echo $(( ${spec#+} )) ;;
        *:*)
            local now=$(date +%s)
            local next=$(date -d "$(date +%F) $spec" +%s 2>/dev/null || echo "$now")
            (( next <= now )) && next=$(( next + 86400 ))
            echo $(( next - now ))
            ;;
        *) echo 0 ;;
    esac
}

main() {
    log "Daemon started"
    while :; do
        load_conf
        for name in "${!CMDS[@]}"; do
            cmd="${CMDS[$name]}"
            t="${TIMES[$name]:-+1h}"
            now=$(date +%s)
            next="${NEXT[$name]:-0}"
            if (( now >= next )); then
                log "Running [$name]: $cmd"
                bash -c "$cmd" &
                NEXT[$name]=$(( now + $(delay_from_spec "$t") ))
            fi
        done
        sleep 60
    done
}

main
