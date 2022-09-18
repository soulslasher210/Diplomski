#!/bin/bash
find /home/alex/Videos -maxdepth 1 -type f -size +1M -exec du -h {} + | sort
