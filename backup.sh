#!/bin/bash

version="0.1.0"
author="Julia Hardy"


# Usage message
usage() {
  echo -n "$(basename "$0"), ${version}
Usage: $(basename "$0") [OPTION]...

Program used to generate full and incremental backups at the time specified by user
Program contains option to restore copy indicated by 'date' option or the latest one

 Options (backup creation):
  --name            Backup file name prefix
  --full-interval   Time interval between full backups (seconds)
  --inc-interval    Time interval between full and incremental backup or two incremental backups (seconds)
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
      echo "Please provide source path to backup (e.g. --path=dir-to-backup)"
      exit
    fi
  else
    if [[ -z ${backupDir} ]]; then
      echo "Plaese provide directory of bakup folders"
      exit
    fi
    if [[ -z ${outDir} ]]; then
      echo "please provide directory where restore copy"
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
  date=`date +"%Y_%m_%d_%H_%M_%S"`
  fileName="${name}_$1_${date}.tar"
  if [[ -z ${gzip} ]]; then : ;
    else fileName="${fileName}.gz";
  fi
  if [[ -z ${backupDir} ]]; then : ; #check where to crete backup default:currecnt location
    else fileName="${backupDir}/${fileName}"
  fi
  echo ${fileName}
}

# files to backup
pathGenerator() {
  if [[ -z ${extensions} ]]; then
    backupPath=${pathTo}
  else
    for ext in ${extensions[@]}; do
      files+=" "$(find "$pathTo" -name *.${ext})
    done
    backupPath=${files}
  fi
  echo ${backupPath}
}

# check tar or gzip
packingOptGenerator() {
  if [[ -z ${gzip} ]]; then #check format
    packingOpt="-cpf"
  else packingOpt="-cpzf";
  fi
  echo ${packingOpt}
}

# Backup
backup() {
    fileName=$(fileNameGenerator full)
    packingOpt=$(packingOptGenerator)
    backupPath=$(pathGenerator)
    #create backup
    if [[ -z ${fullInterval} ]] && [[ -z ${incInterval} ]]; then #check full and inc interval options
      tar ${packingOpt} ${fileName} ${backupPath}
    elif [[ -n ${fullInterval} ]] && [[ -n ${incInterval} ]]; then
      difference=$((${fullInterval} - ${incInterval}))
      while true; do
        fileName=$(fileNameGenerator  full)
        backupPath=$(pathGenerator)
        tar ${packingOpt} ${fileName} ${backupPath}
        sleep ${incInterval}
        fileName=$(fileNameGenerator  incr)
        backupPath=$(pathGenerator)
        tar --listed-incremental incr/backup.snar ${packingOpt} ${fileName} ${backupPath}
        sleep ${difference}
      done
    elif [[ -n ${fullInterval} ]] && [[ -z ${incInterval} ]]; then
      while true; do
        fileName=$(fileNameGenerator  full)
        backupPath=$(pathGenerator)
        tar ${packingOpt} ${fileName} ${backupPath}
        sleep ${fullInterval}
      done
    elif [[ -z ${fullInterval} ]] && [[ -n ${incInterval} ]]; then
      while true; do
        fileName=$(fileNameGenerator  incr)
        backupPath=$(pathGenerator)
        tar --listed-incremental incr/backup.snar ${packingOpt} ${fileName} ${backupPath}
        sleep ${incInterval}
      done
    fi
}

extractDateFromFileString() {
  str=$1
  # crazy date string stripping (dir/name_full_2019_01_17_11_55_22.tar -> 20190117115522)
  str=$(echo ${str} | sed -E "s#${backupDir}/${name}_(full|incr)_([0-9_]+)\.tar(\.gz)?#\2#g")
  str=${str//_/}
  echo ${str}
}

# restore copy
restore() {
  toRestore=$(find "${backupDir}" -name *"${name}_full_${backupDate}"* -o -name *"${name}_incr_${backupDate}"*)
  if [[ -z "$toRestore" ]]; then
    allFiles=$(find "${backupDir}" -name *"${name}_full_"* -o -name *"${name}_incr_"* | sort -t_ -k3)
    searchBackupDate=${backupDate//[!0-9]/}
    allFilesArr=(${allFiles})

    fileToBackup=${allFilesArr[0]} #
    fileDate=$(extractDateFromFileString ${allFilesArr[0]})
    i=0
    while [[ ${fileDate} -lt ${searchBackupDate} && ${i} -lt ${#allFilesArr[@]} ]]

    do
      fileToBackup=${allFilesArr[$i]}
      i=$[$i+1]
      fileDate=$(extractDateFromFileString ${allFilesArr[${i}]})
    done
    toRestore=${fileToBackup}
  fi
  tar -xf ${toRestore} -C ${outDir}
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
  --date=*) backupDate="${i#*=}";;
  --out-dir=*) outDir="${i#*=}";;
  -h|--help) usage >&2; exit ;;
  -v|--version) version >&2; exit ;;
  *) "Unknown option: ${i%=*}" >&2; exit ;; # remove everything after (and including) '='
esac
done

requirements
if [[ -z ${backupDate} ]]; then
  backup
else restore
fi








# name_full_rok_miesiąc_dzień_godzina_minuta.tar
