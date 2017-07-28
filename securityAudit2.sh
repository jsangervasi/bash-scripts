#!/bin/bash
#check local security configuration 

hostname="securityReport_`hostname`" 
email="email@domain.com"
file="/tmp/$hostname"

#remove old log file
if [ -f $file ]; then
   `/bin/rm -rf $file`
fi

#print border to separate lists     
border () 
{
   `echo "////////////////////////////////////////////////////////////////////////////////////" >> $file`
}

#print border with check type 
header () 
{
   #print header
   border
   `echo "////////////////////////////// $1 //////////////////////////////" >> $file`
   border
}

#print short description 
tiny_header ()
{
   `echo "////////////////////////////// $1 //////////////////////////////" >> $file`
}

# quick snapshot of server statistics 
check_stats ()
{
   border
   uname=`uname -a`
   uptime=`/usr/bin/uptime`
   runlevel=`/sbin/runlevel`
   users=`/usr/bin/w | /bin/awk {'print $1'} | /bin/sort | /usr/bin/uniq | /usr/bin/wc -l`
   listen=`/bin/netstat -tl | /usr/bin/wc -l`
   procs=`/bin/ps -ef | /usr/bin/wc -l`
   packages=`/usr/bin/yum list installed | /usr/bin/wc -l`
   `echo "System information:" $uname >> $file`
   `echo "Uptime:" $uptime >> $file`
   `echo "Last/Current Runlevels:" $runlevel >> $file`
   `echo "Unique users logged in:" $users >> $file`
   `echo "Listening ports:" $listen >> $file`
   `echo "Running processes:" $procs >> $file`
   `echo "Installed packages:" $packages >> $file`
   border
}

#print date at top of report
print_date () 
{
   #add date and border 
   border #print border
   `date >> $file`  
   border #print border
}

#check for open (listening) ports
listen_ports () 
{
   #check for listening ports
   border #print border
   tiny_header "LISTENING PORTS"
   `netstat -tl >> $file`
   border #print border
}

#check which processes are currently active
check_running () 
{
   border #print border
   tiny_header "RUNNING PROCESSES"
   `ps auxww | /bin/sort >> $file`
}

#print /var/log/messages, /var/log/secure and dmesg
check_logs () 
{
    # check /var/log/messages, /var/log/secure, dmesg
    border 
   tiny_header "DMESG" 
   `/bin/dmesg >> $file`
   tiny_header "LOG MESSAGES \(last 50 records\)"
   `/usr/bin/sudo /usr/bin/tail -50 /var/log/messages >> $file`
   tiny_header "SECURITY LOGS \(last 50 records\)"
   `/usr/bin/sudo /usr/bin/tail -50 /var/log/secure >> $file`
   border 
}

#check active tcp wrappers if any
tcp_wrappers () 
{
   border #print border
   tiny_header "ALLOWED HOSTS"
   `/usr/bin/sudo /bin/cat /etc/hosts.allow >> $file`
   tiny_header "DENIED HOSTS"
   `/usr/bin/sudo /bin/cat /etc/hosts.deny >> $file`
   border #print border
}

#check for any scheduled jobs
check_cron ()
{
   border #print border
   tiny_header "SCHEDULED JOBS"
   `/usr/bin/sudo /usr/bin/crontab -u root -l >> $file`
   border #print border
}

#generate list of installed packages
check_yum ()
{
   border #print border
   tiny_header "INSTALLED PACKAGES"
   `yum list installed >> $file`
   border #print border
}

#print list of users who have su prilileges
check_sudoers ()
{
   #check sudoers list
   border
   tiny_header "SUDOERS"
   `/usr/bin/sudo /bin/cat /etc/sudoers >> $file`
   border
}

#print disk usage
check_disk () 
{
   #check disk usage 
   border
   tiny_header "DISK USAGE"
   `/bin/df >> $file`
   border
}

#print list of mounted filesystems
check_mount () 
{
   #check mounted filesystems 
   border
   tiny_header "MOUNTED FILESYSTEMS"
   `/bin/mount >> $file`
   border
}

#print list of last 50 logins 
check_last () 
{
   #check last logins 
   border
   tiny_header "LAST LOGGED IN \(last 50 records\)"
   `/usr/bin/last -50 >> $file`
   border
}

#print list of currently logged in users
check_who () 
{
   #check who is logged in and what they're doing
   border
   tiny_header "CURRENTLY LOGGED IN"
   `/usr/bin/w | /bin/sort >> $file`
   border
}

#print iptables configuration
check_iptables ()
{
   #check iptables status 
   border
   tiny_header "IPTABLES STATUS"
   `/usr/bin/sudo /sbin/iptables -L >> $file`
   border
}

#print configuration of network interfaces
check_ip ()
{
   #check network settings 
   border
   tiny_header "IP ADDRESSES"
   `/sbin/ifconfig >> $file`
   border
}

#check dns configuration settings
check_dns ()
{
   #check network settings 
   border
   tiny_header "NAMESERVERS"
   `/usr/bin/sudo /bin/cat /etc/resolv.conf >> $file`
   border
}

#print list of users and groups that have access 
check_users_groups ()
{
   # list users and groups 
   border
   tiny_header "USERS"
   `/usr/bin/sudo /bin/cat /etc/passwd | /bin/awk -F : {'print $1'} | /bin/sort >> $file`
   tiny_header "GROUPS"
   `/usr/bin/sudo /bin/cat /etc/group | /bin/awk -F : {'print $1'} | /bin/sort >> $file`
   border
}

#print load information for cpu, memory, and pagefile
check_cpu_mem ()
{
   #check cpu, memory and virtual memory load status 
   border
   tiny_header "CPU/MEMORY/PF LOAD STATUS"
   `/usr/bin/vmstat >> $file`
   border
}

#print list of environment variables
check_env ()
{
   #check env 
   border
   tiny_header "ENVIRONMENT"
   `/bin/env >> $file`
   border
}

#print list of daemons started for each runlevel
check_startup ()
{
   #check list of daemons on startup  
   border
   tiny_header "STARTUP PROCESSES"
   `/sbin/chkconfig --list |grep :on >> $file`
   border
}

#prints ulimit and umask parameters
check_permissions ()
{
   #check umask and ulimit  
   border
   tiny_header "CHECK UMASK"
   umask=`umask -p`
   `echo $umask >> $file`
   tiny_header "CHECK ULIMIT"
   ulimit=`ulimit -a`
   `echo $ulimit >> $file`
   border
}

security_checks () 
{
   header "SECURITY CHECKS" 
   tcp_wrappers
   listen_ports
   check_sudoers
   check_mount
   check_iptables
   check_last
   check_who
   check_users_groups
   check_permissions
}

usage_checks ()
{
   header "USAGE CHECKS" 
   #call system usage checks
   check_cpu_mem
   check_env
   check_running
   check_disk
   check_cron
   check_startup
   check_yum
}

network_checks ()
{
   header "NETWORK CHECKS"
   #check network config
   check_ip
   check_dns
}

log_checks ()
{
   header "LOG CHECKS" 
   #call log functions
   check_logs
}

#email the report 
email_log () 
{
   #email the contents of the secure.log
   host=`hostname`
   `/bin/cat $file | /bin/mail -s "Usage & Security Report for $host" $email`
}


########### RUN CHECKS CALLED VIA USER INPUT ############

case $1 in

   security) 
      #run security_checks
      security_checks
   ;;
   
   usage)
      #run usage_checks
      usage_checks
   ;;
   
   network)
      #run network_checks
      network_checks
   ;;
   
   logs)
      #run log_checks
      log_checks
   ;;
   
   all)
      #call all functions
      print_date
      check_stats
      security_checks
      usage_checks
      network_checks
      log_checks
   ;;

   $@)
      #print usage message when invalid arguments are passed
      echo "USAGE: [$0] [ all | logs | network | security | usage ]" 
      exit 0
   ;;


esac

email_log  #sends log information in email

exit $?
