#!/bin/bash
# Network_Info.sh - Network info dump script
# Author: ari
# Purpose: Shows network info on screen AND saves it to a dated file
# Output file: ~/network_reports/ari_network_info_YYYY-MM-DD.txt
# How to run: ./Network_Info.sh  (works from any folder)

# Variables for the file name: name + purpose + date
Name="ari"
Date=$(date +%Y-%m-%d)
Folder="$HOME/network_reports"
Outfile="$Folder/${Name}_network_info_${Date}.txt"

# Make the reports folder if it doesn't exist yet
mkdir -p "$Folder"

# Everything inside { } goes to the screen and the file through tee
{
echo "== Network Info Report =="
echo "Date: $(date)"
echo

# System info: which machine and OS this report is from
echo "== System Info (hostname, uname -r, /etc/os-release) =="
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -r)"
grep PRETTY_NAME /etc/os-release
echo

# IP addresses on every interface
echo "== IP Addresses (ip addr) =="
ip addr
echo

# Default gateway and routes
echo "== Routes / Gateway (ip route) =="
ip route
echo

# DNS servers the system uses
echo "== DNS (cat /etc/resolv.conf) =="
cat /etc/resolv.conf
echo

# Open ports and services listening on them
echo "== Listening Ports (ss -tuln) =="
ss -tuln
echo

# Can we reach the internet?
echo "== Ping Test (ping -c 3 8.8.8.8) =="
ping -c 3 8.8.8.8
echo

# Does DNS turn names into IPs?
echo "== DNS Lookup (dig google.com +short) =="
dig google.com +short
echo

# Path packets take to a common website
echo "== Route to google.com (traceroute -m 15 google.com) =="
traceroute -m 15 google.com
} | tee "$Outfile"

echo "Report saved to $Outfile"
