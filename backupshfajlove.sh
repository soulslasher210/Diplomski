#!/bin/bash
#Skripta za backup fajlova i kreiranje direktorijuma
read -p "Unesite kako želite direktorijum za backup da se zove: " IME_BACKUP
DATUM=$(date +%Y%m%d)
if [[ ! -d ${IME_BACKUP} ]]
then
	mkdir ${IME_BACKUP} >&2
	for i in *.sh
	do
		[[ -e "$i" ]] || break #prekida izvršavanje ukoliko nema fajla
		mv "$i" ${IME_BACKUP}
	done

	tar cvf backup${DATUM}.tar ${IME_BACKUP}
	rm -rf ${IME_BACKUP}
	exit 0
else
	echo "Direktorijum već postoji" >&2
	exit 1
fi
