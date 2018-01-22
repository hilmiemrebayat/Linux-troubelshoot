# Demo troubleshoot
## Server
1. Start server en voer de volgende commando's ut:
- sudo systemctl status dhcp
- sudo systemctl status httpd
- sudo systemctl status dnsmasq
## Workstation
1. Start workstation en voer de volgende commando's uit:
- ip a
- ip r
- sudo vi /etc/resolv.conf
- ping 172.22.0.2
- /usr/local/bin/acceptance-tests
2. Ga terug naar de server en voer de volgende commando uit:
- ping 172.22.0.101
