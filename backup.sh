#!/bin/bash

version="0.1.0"
author="Julia Hardy"

date=`date +"%Y_%m_%d_%H_%M"`

# Usage message
# PO ANGIELSKU NAPISZ ZEBY BYŁO PRAWILNIE
usage() {
    echo -n "$(basename "$0"), ${version}
Usage: $(basename "$0") [OPTION]...

Program used to generate backups TU COś WIECEJ MOZNA

 Options:
  --name            Backup file name prefix
  --full-interval   Odstęp czasu pomiędzy pełnymi backupami
  --inc-interval    Odstęp czasu pomiędzy pełnym backupem a przyrostowym lub pomiędzy przyrostowymi
  --path            Scieżka wierzchołka drzewa katalogów do backupowania
  --gzip            Wynikiem będzie plik skompresowany programem gzip
  --ext             Lista rozszerzń plików; backupowane będą pliki z zadanego katalogu, które posiadają podane rozszerzenie
  --backup-dir      Katalog, gdzie będą składane pliki backupów
  -h, --help        Display this help and exit
  -v, --version     Output version information and exit
"
}

# Version message
version() {
    echo "$(basename "$0"), version: ${version}, author: ${author}"
}

# Option requirements
requirements() {
    if [[ -z ${name} ]]; then
        echo "Please provide backup file prefix (e.g. --name='prefix')"
        exit
    fi
    if [[ -z ${fullInterval} ]]; then
        echo "Please provide time interval between full backups (e.g. --full-interval=10m)"
        exit
    fi
    if [[ -z ${backupPath} ]]; then
        echo "Please provide source path to backup (e.g. --path=./dir-to-backup)"
        exit
    fi

    ## itd :) ...
}

# File name generator
fileNameGenerator() {
    fileName="${name}_${date}.tar"
    if [[ -z ${gzip} ]]; then : ;
        else fileName="${fileName}.gz";
    fi
    echo ${fileName}
}

# Backup?
backup() {
    fileName=$(fileNameGenerator)
    if [[ -z ${gzip} ]]; then
        tar -cpf ${fileName} ${backupPath};
        else tar -cpzf ${fileName} ${backupPath};
    fi

}

## Extract options
for i in "$@"
do
case ${i} in
    --name=*) name="${i#*=}" ;; # remove everything before (and including) '='
    --full-interval=*) fullInterval="${i#*=}" ;;
    --inc-interval=*) incInterval="${i#*=}" ;;
    --path=*) backupPath="${i#*=}" ;;
    --ext=*) extensions="${i#*=}" ;;
    --backup-dir=*) backupDir="${i#*=}" ;;
    --gzip) gzip=true ;;
    -h|--help) usage >&2; exit ;;
    -v|--version) version >&2; exit ;;
    *) "Unknown option: ${i%=*}" >&2; exit ;; # remove everything after (and including) '='
esac
done
requirements

backup








# name_full_rok_miesiąc_dzień_godzina_minuta.tar