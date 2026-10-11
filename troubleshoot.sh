#!/bin/bash
# troubleshoot.sh - interactive network troubleshooting by OSI layer

echo "== Network Troubleshooter =="
echo "Which server are you on?"
echo "1. Ubuntu / Debian"
echo "2. CentOS / Red Hat"
read -p "Enter 1 or 2: " Choice

if [ "$Choice" != "1" ] && [ "$Choice" != "2" ]; then
echo "Invalid choice. Please run again and enter 1 or 2."
exit 1
fi

Gateway=$(ip route | awk '/default/ {print $3}')

echo
echo "== Layer 1/2: Is the interface up? =="
ip link show
read -p "Press Enter to continue."

echo
echo "== Layer 3: IP Address and connectivity =="
ip addr show | grep "inet"
echo "Pinging gateway $Gateway."
ping -c 2 "$Gateway"
echo "Pinging 8.8.8.8."
ping -c 2 8.8.8.8
read -p "Press Enter to continue."

echo
echo "== Layer 4: Listening ports =="
ss -tuln
read -p "Press Enter to continue."

echo
echo "== Layer 7: DNS =="
dig google.com +short
read -p "Press Enter to continue."

echo
echo "== Config check =="
if [ "$Choice" = "1" ]; then
    echo "Ubuntu uses netplan:"
    sudo cat /etc/netplan/*.yaml
    echo "To apply changes: sudo netplan apply"
else
    echo "CentOS uses NetworkManager:"
    nmcli connection show
    echo "To bring a connection back up: sudo nmcli connection up enp0s3"
fi

echo
echo "Troubleshooting complete."
