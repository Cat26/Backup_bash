#!/bin/bash
DATA=`date +"%b-%d-%y"`
DESTINATION=/home/Pulpit/systemy_operacyjne/backup/backup-$DATA.tar.gz

SOURCE=/home/Pulpit/systemy_operacyjne/1example

tar -cpzf $DESTINATION $SOURCE
