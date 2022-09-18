#!/bin/bash
read -p "Uneti putanju koja treba da se proveri: " MESTO_PRETRAGE
read -p "Uneti tip fajla koji tražimo f za fajl d za direktorijum: " TIP
find "${MESTO_PRETRAGE}" -maxdepth 1 -type "${TIP}" -size +1M -exec du -h {} + | sort
