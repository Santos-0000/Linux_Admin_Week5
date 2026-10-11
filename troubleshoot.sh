#!/bin/bash
# troubleshoot.sh - Interactive network troubleshooting script
# Author: ari
# Purpose: Asks which server you're on, checks the network layer by layer,
#          and gives troubleshooting suggestions for that server type
# How to run: ./troubleshoot.sh  (works from any folder, may ask for sudo password)

# Ask the user which server they are on
echo "== Network Troubleshooter =="
echo "Which server are you on?"
echo "1. Ubuntu / Debian"
echo "2. CentOS / Red Hat"
read -p "Enter 1 or 2: " Choice

# Stop if the answer isn't 1 or 2
if [ "$Choice" != "1" ] && [ "$Choice" != "2" ]; then
echo "Invalid choice. Please run again and enter 1 or 2."
exit 1
fi

# Find the default gateway from the routing table
Gateway=$(ip route | awk '/default/ {print $3}')

# Layer 1/2: is the network card up?
echo
echo "== Layer 1/2: Is the interface up? =="
ip link show
echo "TIP: If enp0s3 says DOWN, check the VM network adapter is connected."
read -p "Press Enter to continue."

# Layer 3: IP address and internet connectivity
echo
echo "== Layer 3: IP Address and connectivity =="
ip addr show | grep "inet"
echo "Pinging gateway $Gateway."
ping -c 2 "$Gateway"
echo "Pinging 8.8.8.8."
ping -c 2 8.8.8.8
echo "TIP: No internet? If the gateway ping fails, the problem is your local"
echo "     network or IP. If the gateway works but 8.8.8.8 fails, the problem"
echo "     is past your router (ISP or firewall)."
read -p "Press Enter to continue."

# Layer 4: what ports and services are listening
echo
echo "== Layer 4: Listening ports =="
ss -tuln
read -p "Press Enter to continue."

# Layer 7: DNS check
echo
echo "== Layer 7: DNS =="
dig google.com +short
echo "TIP: If 8.8.8.8 pings but this lookup fails, DNS is the problem."
echo "     Test a public DNS server directly: dig @8.8.8.8 google.com +short"
read -p "Press Enter to continue."

# Traceroute to a common website
echo
echo "== Trace route to google.com =="
traceroute -m 15 google.com
echo "TIP: The last hop that answers shows where the connection stops."
read -p "Press Enter to continue."

# Server-specific config and fixes
echo
echo "== Config check and fixes =="
if [ "$Choice" = "1" ]; then
    echo "Ubuntu uses netplan:"
    sudo cat /etc/netplan/*.yaml
    echo
    echo "No internet fix: sudo netplan apply"
    echo "DNS check: resolvectl status"
    echo "Set a static IP: edit /etc/netplan/00-installer-config.yaml"
    echo "  change dhcp4: true to dhcp4: false, then add:"
    echo "    addresses: [10.0.0.50/24]"
    echo "    routes:"
    echo "      - to: default"
    echo "        via: 10.0.0.1"
    echo "    nameservers:"
    echo "      addresses: [8.8.8.8, 1.1.1.1]"
    echo "  then run: sudo netplan apply"
else
    echo "CentOS uses NetworkManager:"
    nmcli connection show
    echo
    echo "No internet fix: sudo nmcli connection up enp0s3"
    echo "DNS check: cat /etc/resolv.conf"
    echo "Set a static IP:"
    echo "  sudo nmcli connection modify enp0s3 ipv4.method manual \\"
    echo "    ipv4.addresses 10.0.0.50/24 ipv4.gateway 10.0.0.1 \\"
    echo "    ipv4.dns \"8.8.8.8 1.1.1.1\""
    echo "  then run: sudo nmcli connection up enp0s3"
fi

echo
echo "Troubleshooting complete."
