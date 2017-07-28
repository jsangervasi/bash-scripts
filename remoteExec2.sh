#!/bin/bash
#shell script for executing commands remotely using SSH

domain="mydomain.com"
testuser="useradd test"

###various servers
servers=(localhost)

#web_servers
web_servers=(localhost)

###database servers
db_servers=(localhost)

echo_off () 
{
   `stty -g` #turn on echo if not already on
   stty -echo #now turn echo off
}

echo_on () 
{
   `stty -g` #turn echo back on 
}

#execute remote commands after user input
exec_cmd ()
{
   echo "Enter command you wish to execute"
   read input 
   if [ "$input" != testuser ]; then
      echo "Does this look correct? (y or n) ssh $1@$2.$domain $input"  
   else
      input=$testuser 
      echo "Run testuser command. Does this look correct? (y or n) ssh $1@$2.$domain $input"  
   fi
   read ans
   if [ $ans == n ]; then 
      exit 0
   else
       echo "Command sent to remote node"
      #turn off tty echo for password reading
      #echo_off 
      `ssh $1@$2.$domain $input`
      #echo_on 
   fi
}

#execute remote commands after user input
exec_srv_cmd ()
{
   case $2 in
      servers)
         LIST=${servers[@]}
      ;;
      web_servers)
         LIST=${web_servers[@]}
      ;;
      db_servers)
         LIST=${db_servers[@]}
      ;;
   esac

   for h in $LIST 
   do
      echo "Enter command you wish to execute"
      read input 
      if [ "$input" != testuser ]; then
         echo "Does this look correct? (y or n) ssh $1@$h.$domain $input"
      else
         input=$testuser 
         echo "Run testuser command. Does this look correct? (y or n) ssh $1@$h.$domain $input"  
      fi
      read ans
      if [ $ans == n ]; then 
         exit 0
      else
          echo "Command sent to remote node"
         #turn off tty echo for password reading
         #echo_off 
         `ssh $1@$h.$domain $input`
         #echo_on 
      fi
   done
}


case $* in

   $@)
      if [ $# -lt 2 ]; then
         echo "USAGE: [$0] [username] [host | \"servers\" | \"web_servers\" | \"db_servers\"]"
      fi
      exit 0 
   ;;

esac

#process incoming arguments and direct to the correct function
   if [ $2 == web_servers ]; then
      exec_srv_cmd $*
   elif [ $2 == db_servers ]; then
      exec_srv_cmd $*
   elif [ $2 == servers ]; then
      exec_srv_cmd $*
   else
      exec_cmd $*
   fi

exit 0
