#!/bin/sh
echo -ne '\033c\033]0;jumpshoot_server\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/jumpshoot_server.x86_64" "$@"
