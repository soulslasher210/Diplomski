#!/bin/bash
# Direktorijum koji ce biti kreiran ukoliko ne postoji
ARCHIVE_DIR='/archive'

# Prikazi kako se koristi skripta i zaustavi dalje izvrsavanje
usage() {
    echo "Usage: ${0} [-dra] USER [USERN]" >&2
    echo "Disable a local linux account" >&2
    echo "-d  Deletes account instead of disabling them." >&2
    echo "-r  Removes the home directory associated with the account(s)" >&2
    echo "-a  Creates an archive of the home directory associated with the accounts(s)" >&2
    exit 1
}

# Provera da li je skripta izvrsena kao super korisnik
if [[ "${UID}" -ne 0 ]]; then
    echo "You are not executing the script as an root user"
    exit 1
fi
# Prolazimo kroz opcije koje su ponudjene klijentu bilo to brisanje arhiviranje....
while getopts dra OPTION; do
    case ${OPTION} in
    d)
        DELETE_USER='true'
        ;;
    r)
        REMOVE_OPTION='-r'
        ;;
    a)
        ARCHIVE='true'
        ;;
    ?)
        usage
        ;;
    esac

done

# Brisanje opcija dra stim da ostavljamo ostale argumente
shift "$(( OPTIND - 1 ))"
# Ako korisnik ne dostavi barem jedan argument prikazi im pomoc
if [[ "${#}" -lt 1 ]]; then
    usage
fi
# Prodji kroz sve username koji su dostavljeni kao argumenti skripte
for USERNAME in "${@}"; do
    echo "Processing user: ${USERNAME}"
    # Proveriti da je USERID barem 1000 
    USERID=$(id -u "${USERNAME}")
    if [[ "${USERID}" -lt 1000 ]]; then
        echo "Refusing to remove the ${USERNAME} account with UID ${USERID}." >&2
        exit 1
    fi
    # Napravi arhivu ako je to zahtevano
    if [[ "${ARCHIVE}" = 'true' ]]; then
        # Provera da li direktorijum arhive zapravo postoji
        if [[ ! -d "${ARCHIVE_DIR}" ]]; then
            echo "Creating ${ARCHIVE_DIR} directory"
            mkdir -p ${ARCHIVE_DIR}
            if [[ "${?}" -ne 0 ]]; then
                echo "The archive director ${ARCHIVE_DIR} could not be created" >&2
                exit 1
            fi
        fi
        # Arhivirate korisnikov home direktorijum 
        HOME_DIR="/home/${USERNAME}"
        ARCHIVE_FILE="${ARCHIVE_DIR}/${USERNAME}.tar.gz"
        # Provera da li je home direktorijum korisnika zapravo prisutan
        if [[ -d "${HOME_DIR}" ]]; then
            echo "Archiving ${HOME_DIR} to ${ARCHIVE_FILE}"
            tar cvfz ${ARCHIVE_FILE} ${HOME_DIR}
            # Provera da li je komanda uspesno izvrsena ako ne zaustavi
            if [[ "${?}" -ne 0 ]]; then
                echo "Could not create ${ARCHIVE_FILE}" >&2
                exit 1
            fi
            # Izbaci poruku ukoliko direktorijum ne postoji i zaustavi skriptu
        else
            echo "${HOME_DIR} does not exist or is not a directory " >&2
            exit 1

        fi

    fi

    # Obrisi korisnika
    if [[ "${DELETE_USER}" = 'true' ]]; then
        userdel ${REMOVE_OPTION}${USERNAME}
        # Provera da li je komanda uspesno izvrsena
        if [[ "${?}" -ne 0 ]]; then
            echo "Delete ${USERNAME} operation has not been completed successfuly" >&2
            exit 1
        fi
        echo "The account ${USERNAME} was deleted"
    else
        chage -E 0 ${USERNAME}
        # Provera da li je komanda chage uspesno izvrsena, ova komanda radi expiery ako nije selektovano da se obrise 
        echo "Account ${USERNAME} has been disabled"

        # Provera da li je uspesna komanda
        if [[ "${?}" -ne 0 ]]; then
            echo "Account ${USERNAME} wasn't set to expire successfuly" >&2
            exit 1
        fi

    fi

done
exit 0