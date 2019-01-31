#!/bin/bash

# Basic variables
MyUSER="username"       # DB_USERNAME
MyPASS="password"     # DB_PASSWORD
MyHOST="DB-URI"        # DB_HOSTNAME

bucket="s3://Bucket-name/directory"

# Timestamp (sortable AND readable)
#stamp=`date +"%s - %A %d %B %Y @ %H%M"`
stamp=`date +"%A %d %B %Y"`
# List all the databases
databases=DB-NAME

# Feedback
echo -e "Dumping to \e[1;32m$bucket/$stamp/\e[00m"

# Loop the databases
for db in $databases; do

  # Define our filenames
  filename="$stamp - $db.sql.gz"
  tmpfile="/opt/dbbackup/$filename"
  encfilename="$filename.enc"
  object="$bucket/$stamp/"

  # Feedback
  echo -e "\e[1;34m$db\e[00m"

  # Dump and zip
  echo -e "  creating \e[0;35m$tmpfile\e[00m"
  mysqldump -h $MyHOST -u$MyUSER -p$MyPASS --single-transaction --quick --lock-tables=false "$db" | gzip -c > "$tmpfile"
  status1=$?
 cd /opt/dbbackup
  #openssl smime -encrypt -binary -text -aes256 -in "$filename" -out "$encfilename" -outform DER /opt/script/mysqldump-secure.pub.pem
  #rm "$filename"
 echo $status1
  # Upload
  echo -e "uploading..."
  #aws s3 cp "/opt/dbbackup/$encfilename" "$object"
  aws s3 cp "/opt/dbbackup/$filename" "$object"
 status2=$?
 echo $status2
 # Delete
 # rm -f "/opt/dbbackup/$encfilename"
 rm -f "/opt/dbbackup/$filename"
done;

if [ $status1 -eq 0 ];then
echo "Success" | mail -s "sql dump success" -aFrom:HOST\<HOST@domian\> monit@domain.com
else
echo "Unsuccess" | mail -s "sql dump not success" -aFrom:HOST\<HOST@domian\> monit@domain.com
fi
if [ $status2 -eq 0 ];then
echo "Success" | mail -s "aws s3 upload success " -aFrom:HOST\<HOST@domian\> monit@domain.com
else
echo "UnSuccess" | mail -s "aws s3 upload not success " -aFrom:HOST\<HOST@domian\> monit@domain.com
fi
