#!/bin/bash
set -e
FOLDER=/data/sftp
FTP=$(docker ps --format '{{.Names}}' | grep vizix_ftp.)
SFTP=$(docker ps --format '{{.Names}}' | grep vizix_sftp.)
#comment above and uncomment below for docker-compose
#FTP=ftp
#SFTP=sftp
PERMISSIONS=/data/ftp_permissions.sh

echo "Input username:"
read USER

echo "Input password:"
read PASS

echo "Creating User... please disregard next input prompt as this is an automated process..."
docker exec -ti $FTP /bin/bash -c "( echo ${PASS} ; echo ${PASS} ) | pure-pw useradd $USER -f /etc/pure-ftpd/passwd/pureftpd.passwd -m -u ftpuser -d /home/ftpusers/$USER"
docker exec -it $FTP /bin/bash -c "apt-get update && apt-get install curl -y"
docker exec -it $FTP /bin/bash -c "curl ftp://$USER:$PASSl@localhost" || true
echo "...automated proccess finished"

SFTPPASS=$(echo -n $PASS | docker run -i --rm atmoz/makepasswd --crypt-md5 --clearfrom=- | awk '{print $2}')
SEQ=$(grep -o '....$' $FOLDER/users.conf | tail -n 1)
if [ -z $SEQ ]; then
  SEQ=1000
  echo "$USER:$SFTPPASS:e:$SEQ" >> $FOLDER/users.conf
 else
  SEQ=$((SEQ + 1))
  echo "$USER:$SFTPPASS:e:$SEQ" >> $FOLDER/users.conf
fi

#FTP Folder structure
mkdir -p $FOLDER/home/$USER/ViZix/Product/Processed
mkdir -p $FOLDER/home/$USER/ViZix/SOH/Processed
mkdir -p $FOLDER/home/$USER/ViZix/POS/Processed
chown -R $SEQ:$SEQ $FOLDER/home/$USER/ViZix
chmod -R 777 /data/sftp/home/$USER/*
echo "chmod -R 777 /data/sftp/home/$USER/*" >> $PERMISSIONS

echo "Input 'yes' to restart SFTP container:"
read RESTART

if [ $RESTART = 'yes' ]; then
  docker stop $SFTP && docker rm -f $SFTP
 else
  exit 0
fi

exit 0
