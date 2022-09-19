#!/bin/bash
# Ova skripta predstavlja otvorene portove na sistemu
# Koristi -4 kao argument za samo IPv4 Portove
echo "Skripta nam prikazuje koji su otvoreni portovi za IPv4 na serveru "
read -p "Upisi -4 za ipv4 -6 za ipv6: " IPV
netstat -tunl "${IPV}" | grep  ':' | awk '{print $4}' | awk -F ':' '{print $NF}'|sort
# $NF znaci poslednje polje
# Moze se prosiriti sa nekim proverama ako treba
