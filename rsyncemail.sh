#!/bin/sh
# Created by Mitchell Hall <mhall@45drives.com>

# Preconfigure for your environment
logfile="/tmp/rsynctasks.tmp"
email="emailaddress@gmail.com"  # email address to send notifications to
sourcedir="/source/path"   # source directory for Rsync task
destinationdir="/destination/path" # Destination for Rsync task

 
rsync -avz ${sourcedir} user@192.0.0.0:${destinationdir} --log-file=${logfile};   # set the user and IP address here and any additional Rsync flags you may want

code=$?

if  [ $code -eq 0 ]; then

        echo "Rsync completed successfully - please log in to server and check /tmp/rsynctasks.tmp for more info" | sendmail -s $email

elif [ $code -eq 10 ]; then

        echo "Rsync task failed - Error in socket I/O - please log in to server and check /tmp/rsynctasks.tmp for more info" | sendmail -s $email

elif [ $code -eq 11 ]; then

        echo "Rsync task failed - Error in file I/O - please log in to server and check /tmp/rsynctasks.tmp for more info" | sendmail -s $email

elif [ $code -eq 12 ]; then

        echo "Rsync task failed - Error in Rsync protocol data stream - please log in to server and check /tmp/rsynctasks.tmp for more info" | sendmail -s $email

elif [ $code -eq 23 ]; then

        echo "Rsync task failed - Partial transfer due to error - please log in to server and check /tmp/rsynctasks.tmp for more info" | sendmail -s $email

elif [ $code -eq 24 ]; then 

        echo "Rsync task failed - Partial transfer due to vanished source files - please log in to server and check /tmp/rsynctasks.tmp for more info" | sendmail -s $email

elif [ $code -eq 30 ]; then

        echo "Rsync task failed - Timeout in data send/receive - please log in to server and check /tmp/rsynctasks.tmp for more info" | sendmail -s $email

elif [ $code -eq 35 ]; then

        echo "Rsync task failed - Timeout waiting for daemon connection - please log in to server and check /tmp/rsynctasks.tmp for more info" | sendmail -s $email

else 

        echo "Exit code not known - Refer to log files for more information whih can be found at /tmp/rsynctasks.tmp" | sendmail -s $email

fi
