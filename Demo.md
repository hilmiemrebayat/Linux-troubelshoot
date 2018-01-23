# Demo troubleshoot
## Server
1. Start alle vm's en voer de volgende commando's uit op de server:
- sudo systemctl status dhcp
- sudo systemctl status httpd
- sudo systemctl status dnsmasq
- ping 172.20.0.254
- ping 172.20.0.101
- ping 127.0.0.1
## Workstation
1. Voer de volgende commando's uit op de workstation:
- ip a
- ip r
- sudo vi /etc/resolv.conf
- ping 172.20.0.2
- ping 172.20.0.254
- ping 127.0.0.1
- /usr/local/bin/acceptance-tests

