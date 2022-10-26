#!/bin/bash
# Skripta za pretragu za direktorijumom ili fajlom

# Provera da li je korisnik zapravo root
if [[ "${UID}" -ne 0 ]]; then
        echo "Skripta nije pokrenuta kao root korisnik " >&2
        exit 1
fi

# Zahtev unosa od korisnika za pretragu
read -p "Uneti putanju koja treba da se proveri: " MESTO_PRETRAGE
read -p "Uneti tip fajla koji tražimo f za fajl d za direktorijum: " TIP
find "${MESTO_PRETRAGE}" -maxdepth 1 -type "${TIP}" -size +1M -exec du -h {} + | sort
