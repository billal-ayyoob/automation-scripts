#!/bin/bash

create_log(){
   #To get the system date in the start of the log
   echo "$(date): backup for $date date has been verified and downloaded" >> ${LOG_FILE}
}

#Step 1: Take a date as input in the yyyy-mm-dd format
read -p "Enter Date:" user_date

#If date received from user does meet the required format
if date=$(date -d "$user_date" '+%Y-%m-%d')
then
   DIR_NAME="$date.tar.gz"
   REMOTE_IP="username@remote-ip"
   KEY_NAME="ssh-key"
   DIR="backups"
   ZIPPED_DIR="zipped"
   PARENT_DIR="/devops/eval"
   UNZIPPED_DIR="unzipped"
   FILE_TO_EDIT="wp-config.php"
   SEARCH_STRING="test_user_password"
   REPLACE_STRING="replaced_password"
   NEW_ARCHIVE="new-archive"
   LOG_FILE="backup-log.log"

   # Looking for the file in remote directory.
   #Step 2: verify whether the backup exists on the remote server.
   if [[ $(sudo ssh -i ${KEY_NAME} ${REMOTE_IP} find ${DIR} -name ${DIR_NAME}) ]]
   then
      #Step 3: If the backup exists, it should be downloaded locally
      echo "Remote File Exists! Going to download it to the directory named backups at the same level."
      sudo scp -i  ${KEY_NAME} ${REMOTE_IP}:${PARENT_DIR}/${DIR}/${DIR_NAME} $PWD/${DIR}/${ZIPPED_DIR}
      echo "File Copied successfully."
      #If the copied file exists, Starts unzipping
      if [[ -f ${DIR}/${ZIPPED_DIR}/${DIR_NAME} ]]
      then
         echo "Starting to unnzip"
         #Step 4: Extract files from the backup
         if (tar -xf ${DIR}/${ZIPPED_DIR}/${DIR_NAME} -C ${DIR}/${UNZIPPED_DIR})
         then
	         echo "Unzipped!"
            if [[ -d ${DIR}/${UNZIPPED_DIR}/$date ]]
            then
               echo "Unzipped dir exists."
               #Going to check if the required file that we want to edit exists or not
               if [[ -f ${DIR}/${UNZIPPED_DIR}/$date/${FILE_TO_EDIT} ]]
               then
                  echo "File exists that we want to edit."
                  #Continuing step 4 here to replace the password in the wp-config.php file
                  if (sed -i "s|$SEARCH_STRING|$REPLACE_STRING|g" ${DIR}/${UNZIPPED_DIR}/$date/${FILE_TO_EDIT})
                  then
                     echo "String Replaced!"
                     #Step 5: Recreate the backup archive in a dir named new_archive at the same level
                     if (tar -czpf ${DIR}/${NEW_ARCHIVE}/${DIR_NAME} ${DIR}/${UNZIPPED_DIR}/$date)
                     then
                        echo "Creating log for verification"
                        if [[ ! -f ${LOG_FILE} ]]
                        then
                           touch ${LOG_FILE}
                           create_log "${LOG_FILE}"
                        else
                           create_log "${LOG_FILE}"
                        fi
                     else
                        echo "Couldn't create the new achive"
                     fi
                  else
                     echo "Couldn't replace the string"
                  fi
               else
                  echo "File doesn't exist that we want to edit."
               fi
            else
               echo "Unzipped dir doesn't exist in unzipped dir."
            fi
         else
            echo "Not able to unzip the downloaded file"
         fi
      else
         echo "Could not find file downloaded from remote server"
      fi
   else
      echo "File doesn't exist on the remote server"
   fi
else
   "Date doesn't meet the required format."
fi
