#!/bin/bash
# network_info.sh - shows network info and saves it to a dated file

Name="ari"
Date=$(date +%Y-%m-%d)
Outfile="${Name}_network_info_${Date}.txt"

{
echo "== Network Info Report =="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo
echo "== IP Addresses =="
ip addr
echo
echo "== Routes / Gateway =="
ip route
echo
echo "== DNS =="
cat /etc/resolv.conf
echo
echo "== Listening Ports =="
ss -tuln
echo
echo "== Ping Test =="
ping -c 3 8.8.8.8
} | tee "$Outfile"
echo "Report saved to $Outfile"
