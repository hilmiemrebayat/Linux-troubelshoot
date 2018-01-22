# Enterprise Linux Lab Report - Troubleshooting

- Student name: Hilmi Emre Bayat
- Class/group: TIN-TI-3B (Gent)

## Instructions

- Write a detailed report in the "Report" section below (in Dutch or English)
- Use correct Markdown! Use fenced code blocks for commands and their output, terminal transcripts, ...
- The different phases in the bottom-up troubleshooting process are described in their own subsections (heading of level 3, i.e. starting with `###`) with the name of the phase as title.
- Every step is described in detail:
    - describe what is being tested
    - give the command, including options and arguments, needed to execute the test, or the absolute path to the configuration file to be verified
    - give the expected output of the command or content of the configuration file (only the relevant parts are sufficient!)
    - if the actual output is different from the one expected, explain the cause and describe how you fixed this by giving the exact commands or necessary changes to configuration files
- In the section "End result", describe the final state of the service:
    - copy/paste a transcript of running the acceptance tests
    - describe the result of accessing the service from the host system
    - describe any error messages that still remain

## Report
1. Linux toestenbord is ingesteld als QWERTY. Toetsenbord veranderen naar AZERTY met de commando:  `localectl set-keymap be`
2. Uitschakelen van netwerkadapter 1 (NAT) bij Workstation: Ga naar de instellingen van Workstation in VirtualBox, klik daarna op "Netwerk" en vink netwerkadapter inschakelen uit bij adapter 1.
### Link Layer
1. Open de instellingen van Workstation, Server en router in VirtualBox. Klik daarna op "Netwerk" en kijk of "Netwerkadapter inschakelen" en "kabel aangesloten" (kan je terug vinden onder geavanceerd) is aangevinkt bij de drie VM's (behalve bij workstation moet adapter 1 uitgevinkt staan). Bij mij zijn alle adapters ingeschakeld en aangesloten, dus in het link layer is er geen probleem. 
### Network Layer
#### Server
1. IP-adres
- Commando: `ip a
- Verwachting: 172.20.0.2/24 (x.x.x.2/24) en 10.0.2.15/24
- Besluit: Ip-adres is fout, moet gewijzigd worden met de commando `vim /etc/sysconfig/network-scripts/ifcfg-enp0s8` naar 172.20.0.2
2. Default Gateway
- Commando: `ip r`
- Verwachting: 10.0.2.2
- Besluit: Juist
3. DNS
- Commando:` vi /etc/resolv.conf`
- Verwachting: 10.0.2.3
- Besluit: Juist

#### Router
1. IP-adres
- Commando: `ip a`
- Verwachting: 172.20.0.254/24 (x.x.x.2/24) en 10.0.2.15/24
- Besluit: Subnetmask is fout, moet van /8 naar /24 gewijzigd worden.
2. Default Gateway
- Commando: `ip r`
- Verwachting: 10.0.2.2
- Besluit: Juist

#### Wekstation
1. IP-adres
- Commando: `ip a`
- Verwachting: 172.20.0.X/24 
- Besluit: Geen ip-adres, waarschijnlijk fout met DHCP
2. Default Gateway
- Commando: `ip r`
- Verwachting: 172.20.0.254
- Besluit: Geen default gateway, waarschijnlijk fout met DHCP
3. DNS
- Commando: `vi /etc/resolv.conf`
- Verwachting: 172.20.0.2
- Besluit: Geen DNS, waarschijnlijk fout met DHCP

### Transport layer
#### DHCP
1. Status controleren
- Commando: `sudo systemctl status dhcpd`
- Verwachting: Inactief
- Besluit: Is inactief, proberen te activeren met `sudo systemctl start dhcpd` lunkt niet. -> Fout
- Oplossing: 
  - Kijken naar dhcpd.conf met commando `sudo vi /etc/dhcp/dhcpd.conf`
  - Subnet, option router en dns is fout. Bestand wijzigen als volgt:
```
  # dhcpd.conf -- linuxlab.lan

authoritative;

subnet 172.20.0.0 netmask 255.255.255.0 {
  interface enp0s8;
  range 172.20.0.101 172.20.0.253;

  option domain-name "linuxlab.lan";
  
  option routers 172.20.0.254;
  option domain-name-servers 172.20.0.2;

  default-lease-time 14400;
  max-lease-time 21600;
}

```
  - Server opnieuw opstarten (commando: `reboot`) en daarna DHCP opniew opstarten met commando `sudo systemctl start dhcpd`.
  - Besluit: DHCP werkt
2. Firewall controleren
- Commando: `sudo firewall-cmd --list-all`
- Verwachting: dhcp in services
- Besluit: Firewall is geconfigureerd

#### HTTP (Apahe)
1. Status controleren
- Commando: `sudo systemctl status httpd`
- Verwachting: Inactief
- Besluit: Is inactief, proberen te activeren met `sudo systemctl start httpd`. Activeren is gelukt. Zo te zien wordt het niet automatisch gestart tijdens het starten van de server.
- Oplossing: commando `sudo systemctl enable httpd` uitvoeren
2. Firewall controleren
- Commando: `sudo firewall-cmd --list-all`
- Verwachting: httpd in services
- Besluit: Firewall is geconfigureerd
#### DNS 
1. Status controleren
- Commando: `sudo systemctl status dnsmasq`
- Verwachting: Actief
- Besluit: Geen probleem
2. Firewall controleren
- Commando: `sudo firewall-cmd --list-all`
- Verwachting: dns in services
- Besluit: Niets terug gevonden
- Oplossing: commando `sudo firewall-cmd --add-service=dns --permanent` en daarna `sudo firewall-cmd --reload` uitvoeren. 
3. etc/hosts controleren
- Commando: `sudo vi /etc/hots`
- Verwachting: Drie ip-adressen (172.20.0.2,172.20.0.254 en 127.0.0.1) met hun namen
- Besluit: IP-adres van server is verkeerd, moet gewijzigd worden van 172.22.0.2 naar 172.20.0.2.
- Na wijzigen herstarten van server met de commando `reboot`
#### Server rebooten om te controleren of alle services automatisch opstarten
- Commando: `reboot` en daarna `sudo systemctl status dhcpd`,`sudo systemctl status httpd` en `sudo systemctl status dnsmasq`
- Verwachting: Alles moet actief zijn
- Besluit: Alles is actief

#### Algemeen besluit
Alles is goed geconfigureerd, de werkstation moet normaal gezien werken. We gaan dit controleren in het application layer. 

### Application Layer
- Commando: `/usr/local/bin/acceptance-tests`
- Verwachting: Alle testen moeten slagen
- Besluit: 7/7 testen slagen

