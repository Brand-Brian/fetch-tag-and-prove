#!/bin/bash
# mkpage.sh <slug> <title> <desc> <bodyfile>
set -e
slug="$1"; title="$2"; desc="$3"; bodyfile="$4"
{
  sed -e "s|@@TITLE@@|$title|g" -e "s|@@DESC@@|$desc|g" -e "s|@@SLUG@@|$slug|g" _head.tpl
  cat "$bodyfile"
  cat _tail.tpl
} > "$slug"
:
echo "built $slug ($(wc -c < "$slug") bytes)"
