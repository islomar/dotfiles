#!/bin/bash
set -euo pipefail

url=$(git remote get-url origin | sed 's,git@github.com:,https://github.com/,')
open $url