#!/bin/bash

version="0.1.0"
author="Julia Hardy"

date=`date +"%Y_%m_%d_%H_%M"`

# Usage message
usage() {
    echo -n "$(basename "$0"), ${version}
Usage: $(basename "$0") [OPTION]...

Program used to generate full and incremental backups at the time specified by user
Program contains option to restore copy indicated by 'date' option or the latest one

 Options (backup creation):
  --name            Backup file name prefix
  --full-interval   Time interval between full backups
  --inc-interval    Time interval between full and incremental backup or two incremental backups
  --path            Path to files to be backup
  --gzip            gzip compression
  --ext             List of file extensions to be backup format:(.txt .py)
  --backup-dir      Destination folder, where backup will be stored
  -h, --help        Display this help and exit
  -v, --version     Output version information and exit

  Options (reproduce copy):
  --name            Backup file name prefix
  --date            Specific date for witch restore copy format:year_month_day_hour_minute_second
  --backup-dir      Destination folder, where backups are stored
  --out-dir         Destination folder, where to restore copy
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
    if [[ -z ${backupDate} ]]; then
        if [[ -z ${pathTo} ]]; then
          echo "Please provide source path to backup (e.g. --path=./dir-to-backup)"
          exit
        fi
    else
      if [[ -z ${backupDir} ]]; then
        echo "Plaese provide directory of bakup folders"
        exit
      fi
      if [[ -z ${outDir} ]]; then
        echo "please provide directore where restore copy"
        exit
      fi
    fi
    # if [ -z ${fullInterval} ] || [ -z ${incInterval} ]; then
    #     echo "Please provide time interval between full/incremental backups (e.g. --full-interval=10m/ --inc-interval=10m)"
    #     exit
    # fi
}
# File name generator
fileNameGenerator() {
    fileName="${name}_${date}.tar"
    if [[ -z ${gzip} ]]; then : ;
        else fileName="${fileName}.gz";
    fi
    echo ${fileName}
}

# files to backup
pathGenerator() {
  if [[ -z ${extensions} ]]; then
    backupPath=${pathTo}
  else
    for ext in ${extensions[@]}; do
      local files+=" "$(find "$pathTo" -name *.${ext})
    done
    backupPath=${files}
  fi
  echo ${backupPath}
}

# Backup
backup() {
    fileName=$(fileNameGenerator)
    backupPath=$(pathGenerator)
    #create backup
    if [[ -z ${backupDate} ]]; then #check if user want backup or restore
      if [[ -z ${fullInterval} ]] && [[ -z ${incInterval} ]]; then #check full and inc interval options
        if [[ -z ${backupDir} ]]; then #check where to crete backup default:currecnt location
          if [[ -z ${gzip} ]]; then #check format
            tar -cpf ${fileName} ${backupPath};
            else tar -cpzf ${fileName} ${backupPath};
          fi
        else
          fileName="${backupDir}/${fileName}"
          if [[ -z ${gzip} ]]; then
              tar -cpf ${fileName} ${backupPath};
            else tar -cpzf ${fileName} ${backupPath};
          fi
        fi
      fi
    fi
        # elif [[ -z ${fullInterval} ]]; then
        #   #statements
        # elif [[ -z ${incInterval} ]]; then
        #   #statements
      # fi
      #resore copy
    # else
    #   #resore
    # fi
}

## Extract options
for i in "$@"
do
case ${i} in
    --name=*) name="${i#*=}" ;; # remove everything before (and including) '='
    --full-interval=*) fullInterval="${i#*=}" ;;
    --inc-interval=*) incInterval="${i#*=}" ;;
    --path=*) pathTo="${i#*=}" ;;
    --ext=*) extensions="${i#*=}" ;;
    --backup-dir=*) backupDir="${i#*=}" ;;
    --gzip) gzip=true ;;
    --date=*) backupDate="${#*=}";;
    --out-dir=*) outDir="${i#*=}";;
    -h|--help) usage >&2; exit ;;
    -v|--version) version >&2; exit ;;
    *) "Unknown option: ${i%=*}" >&2; exit ;; # remove everything after (and including) '='
esac
done
requirements

backup








# name_full_rok_miesiąc_dzień_godzina_minuta.tar
