#!/bin/bash
# Skripta za kreiranje korisnika


#  Provera da li se skripta pokrece kao root korisnik
if [[ "${UID}" -ne 0 ]]; then
    echo "You are not executing the script as a root user " >&2
    exit 1
fi
# Ako korisnik ne stavi barem jedan argument u skriptu daj im pomoc
if [[ "${#}" -lt 1 ]]; then
    echo "Usage ${0} USER_NAME [COMMENT]..."
    echo 'Create an account on the local system with the name of USER_NAME and a comments field of COMMENT.'
    exit 1
fi
# Prvi parametar je korisnicko ime
USER_NAME="${1}"
# Sve ostalo je komentar odatle i shift sklanja iniciajlni parametar username koji je $1
shift
COMMENT="${@}" #Svaki pozicionalni parametar koji je ostao
# Generisi lozinku
SPECIAL_CHARACTERS= $(echo '$%^&*()_+#' | fold -w1 | shuf | head -c1)
PASSWORD=$(date +%s%N${RANDOM}${SPECIAL_CHARACTERS} | sha256sum | head -c10)
# Napravi korisnika za username i comment koji je specificiran
useradd -c "${COMMENT}" -m ${USER_NAME} &> /dev/null
# Provera da li je komanda uspesna
if [[ "${?}" -ne 0 ]]; then
    echo "The account has not been created" >&2
    exit 1
fi
# Postavi lozinku
echo "${PASSWORD}" | passwd --stdin ${USER_NAME} &> /dev/null
# Provera da li je komanda passwd uspesna
if [[ "${?}" -ne 0 ]]; then
    echo "Password set has not been executed successfuly" >&2
    exit 1
fi
# Korisnik ce morati da promeni lozinku prilikom inicijalnog logiranja
passwd -e ${USER_NAME} &> /dev/null
# Prikaz sta se kreiralo za lozinkom
echo "The ${USER_NAME} with the password ${PASSWORD} on the host $(hostname)"
exit 0


