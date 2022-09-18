#!/bin/bash

# Skripta za instalaciju wordpress

# Globalna varijabla za ime direktorijuma
readonly OUTPUT_DIRECTORY_NAME="downloadWP"

# Kreirati bazu podataka koja ce biti dodeljena wordpress
mysql_part() {
    mysql -u "${1}" -p"${2}" <<MY_QUERY
create database ${3};
MY_QUERY
    if [[ "${?}" -ne 0 ]]; then
        echo "The mysql query command has not been executed properly" >&2
        exit 1
    fi
    echo "The database ${3} has been created"
}

command_check() {
    if [[ "${?}" -ne 0 ]]; then
        echo "The command has not been completed successfully" >&2
        exit 1
    fi
}

#Proveriti da li se skripta pokrece kao root
if [[ "${UID}" -ne 0 ]]; then
    echo "The script requires root privilages" >&2
    exit 1
fi

# Kreirati direktorijum gde ce se wordpress skinuti
DIRECTORY=/tmp/${OUTPUT_DIRECTORY_NAME}
# Ime zip fajla koji ce biti skinut na sistem
NAME_OF_THE_WP="wordpress.zip"
# Provera da li postoji ukoliko ne kreirati direktorijum
if [[ ! -d "${DIRECTORY}" ]]; then
    mkdir -p "${DIRECTORY}"
fi
# Provera da li je komanda uspesno izvrsena
echo "Creating the ${DIRECTORY} directory ..."
command_check

# Skinuti wordpress isntalaciju i proveriti da li je komanda uspesno
# izvrsena pre nego sto se da odgovor
echo "Downloading the wordpress installation ..."
wget --output-document "${DIRECTORY}/${NAME_OF_THE_WP}" https://wordpress.org/latest.zip

#Provera da li je uspesno izvrsena komanda
command_check

# Direktorijum gde treba da ide wordpress instalacija
APACHE_DIRECTORY="/var/www/html/"

# Komanda sa otpakivanje
echo "Extracting the wordpress installation to the apache directory ..."

#Provera da li direktorijum sa istim imenom vec postoji
if [[ -d "/var/www/html/wordpress" ]]; then
    echo "The directory wordpress in apache directory already exists exiting ...."
    exit 1
fi
#Otpakivanje zip fajla
unzip "${DIRECTORY}/${NAME_OF_THE_WP}" -d "${APACHE_DIRECTORY}" &>/dev/null #Poslato u dev null posto unzip pise generalno sta otpakuje pa je nebitno

# Provera da li je uspesno izvrsena
command_check

# Brisanje direktorjuma koji je koriscen za download kao i samog zip fajla
echo "Removing the wordpress download directory ..."
rm -rf "${DIRECTORY}"
# Provera da li je uspesno
command_check

# Unos od korisnika za mysql
# =======================
read -p "Input username for MySQL: " USERNAME
read -p "Input password for MySQL: " PASSWORD
read -p "Input the database name: " DATABASE
mysql_part ${USERNAME} ${PASSWORD} ${DATABASE}
# ========================

# Verovatno od ove tacke klijent ce morati postaviti ostale delove sam
exit 0
