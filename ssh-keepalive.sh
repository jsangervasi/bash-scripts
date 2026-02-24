#!/bin/bash
# Author: Joseph M Sangervasi
# Title: ssh remote session keep-alive
# Created 02/24/2026
# Version 1.0
# Usage (Linux/Mac): add to .bashrc on remote server to load automatically
# Function: runs a background process which prints space to remote terminal 
# window every 5 minutes to keep ssh session alive (EC2, Virtual machines, etc)
# --- copy line below --- #
while true;do echo " ";sleep 300;done &
