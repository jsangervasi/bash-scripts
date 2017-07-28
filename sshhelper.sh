#!/bin/bash
########################################################################
#
# Usage - Use to select and SSH any box with ease
# Created 4/30/2010
# Version 1.0
# Author Joe Sangervasi
#
########################################################################
#
########################################################################
# Defaults - customize these settings for your environment
########################################################################
HOMEDIR='/home/Joe'         # local home directory
KEYDIR="$HOMEDIR/access"    # directory where ssh keys are located
USERID='jsangervasi'        # your login id
#
# List of servers - add or remove from list
# EXAMPLE:  SRVLIST=('server1' 'server2' 'server3')
SRVLIST=('ec2-184-73-125-227.compute-1.amazonaws.com')
#
# List of keys - add or remove from list
# EXAMPLE:  KEYLIST=("$KEYDIR/key.pem" "$KEYDIR/key2.pem" "$KEYDIR/key3.pem")
KEYLIST=("$KEYDIR/jsangervasi.pem")
#
########################################################################
########################################################################

# system commands
SSH='/usr/bin/ssh'
SCP='/usr/bin/scp'

connect(){
#get user selection, set to 0 by default
server=shift 1
key=shift 2
port=shift 3

#define server and key
server=${SRVLIST[$server]}
if [ $key != 'false' ];then
   key=${KEYLIST[$key]}
fi

echo "SSH or SCP? (ssh or scp, default: ssh, q to quit)"
read service 
# defaults to ssh if left blank
if [ ${#service} -eq 0 ];then
   service='ssh'
fi
if [ $service == 'ssh' ];then
      printf "##################################################\n"
      printf "##           Executing SSH Command              ##\n"
      printf "##################################################\n"
      if [ ${#key} -ne 0 ] && [ $key != 'false' ];then
         echo   "$SSH -p $port -i $key $USERID@$server"
         $SSH -p $port -i $key $USERID@$server 
         exit $?
      else
         echo "$SSH -p $port $USERID@$server"
         $SSH -p $port $USERID@$server
         exit $?
      fi
elif [ ${#service} -ne 0 ] && [ $service == 'scp' ];then
      printf "Send data to $server?\n" 
      printf "Receive data from $server?\n"
      printf "(send or recv, default: send)\n"
      read switch
      echo "Enter a source path and/or file" 
      read srcinfo
      echo "Enter a destination path and/or file"
      read destinfo
      if [ ${#srcinfo} -ne 0 ] && [ ${#destinfo} -ne 0 ];then
            printf "##################################################\n"
            printf "##           Executing SCP Command              ##\n"
            printf "##################################################\n"
            if [ ${#key} -ne 0 ] && [ $key != 'false' ];then
               if [ ${#switch} -ne 0 ] && [ $switch == 'recv' ];then
                  echo "$SCP -P $port -i $key $USERID@$server:$srcinfo $destinfo"
                  $SCP -P $port -i $key $USERID@$server:$srcinfo $destinfo
                  exit $?
               else
                  echo "$SCP -P $port -i $key $srcinfo $USERID@$server:$destinfo"
                  $SCP -P $port -i $key $srcinfo $USERID@$server:$destinfo
                  exit $?
               fi
            else
               if [ ${#switch} -ne 0 ] && [ $switch == 'recv' ];then
                  echo "$SCP -P $port $USERID@$server:$srcinfo $destinfo"
                  $SCP -P $port $USERID@$server:$srcinfo $destinfo
                  exit $?
               else
                  echo "$SCP -P $port $srcinfo $USERID@$server:$destinfo"
                  $SCP -P $port $srcinfo $USERID@$server:$destinfo
                  exit $?
               fi
            fi
      else
         echo "Sorry, you must specify source and destination information"
         echo "Goodbye"
         exit $?
      fi
elif [ $service == 'q' ];then
      exit $?
else
   exit $?
fi
}

printinfo(){
   printf "##################################################\n"
   printf "##               List of servers                ##\n"
   printf "##################################################\n"
   count=0
   for i in ${SRVLIST[@]}
      do
       printf "$count) $i\n"
       let "count+=1"
   done
   printf "\n\n"
   printf "##################################################\n"
   printf "##               List of keys                   ##\n"
   printf "##################################################\n"
   count=0
   for i in ${KEYLIST[@]}
      do
       printf "$count) $i\n"
       let "count+=1"
   done
   printf "\n\n"
}

getinfo(){
  # get server info
  echo "Enter the server number to connect (default: 0)"
  read server
  if [ ${#server} -eq 0 ] || [ $server -gt ${#SRVLIST[@]} ];then 
     echo "Using default server: 0"
     server=0
  fi
  # get key info
  echo "Is a private key needed? (y or n, default: n)"
  read needkey 
  if [ ${#needkey} -eq 0 ];then
      key='false'
  elif [ $needkey == 'y' ];then
      echo "Enter your key selection (default: 0)"
      read key
      if [ ${#key} -eq 0 ] || [ $key -gt ${#KEYLIST[@]} ];then 
        echo "Using default key: 0"
        key=0
      fi
   else
      key='false'
   fi
   # get port info
   echo "Enter a port number if other than 22 (default: 22)"
   read port
   if [ ${#port} -eq 0 ];then
      port=22
   elif [ $port -gt 65535 ];then
      port=22
   fi
   connect $server $key $port
}

#start
printinfo
getinfo
# END SCRIPT
