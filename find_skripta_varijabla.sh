#!/bin/bash
MESTO_PRETRAGE="/home/alex/Videos"
find "${MESTO_PRETRAGE}" -maxdepth 1 -type f -size +1M -exec du -h {} + | sort
