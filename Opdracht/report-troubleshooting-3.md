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
#### Server
1. Open de instellingen van Workstation, Server en router in VirtualBox. Klik daarna op "Netwerk" en kijk of "Netwerkadapter inschakelen" en "kabel aangesloten" (kan je terug vinden onder geavanceerd) is aangevinkt bij de drie VM's (behalve bij workstation moet adapter 1 uitgevinkt staan). Bij mij zijn alle adapters ingeschakeld en aangesloten, dus in het link layer is er geen probleem. 
#### Workstation
### Network Layer
#### Server
1. Start de VM "Server" en controleer of de ip-adressen toegekend en juist zijn. Dit controleer je met de commando `ip a`. Netwerkadapter enp0s8 heeft ip-adres 172.22.0.2/24 en enp0s3 heeft ip-adres 10.0.2.15/24 en ze zijn up. Dus de ip-adressen kloppen.
2. Nu gaan we de default gateway controlleren. Dit doen we met de commando `ip r`. Netwerkadapter enp0s8 heeft als default gateway 172.22.0.0/24 en enp0s3 heeft 10.0.2.0/24. Dus de default gateway klopt ook.
3. Nu gaan we de DNS instellingen controleren. We verwachten "10.0.2.3". Om te checken voeren we de volgende commando uit: `vi /etc/resolv.conf `. We krijgen als uitvoer "nameserver: 10.0.2.3". Dus de dns-server klopt.
We kunnen hieruit besluiten dat de network layer van de server goed geconfigureerd is.
#### Workstation
1. Start de VM "Workstation" en controleer of de ip-adressen toegekend en juist zijn. Dit controleer je met de commando `ip a`. Na het uitvoeren van de commando zien we dat de netwerkinterface op up staat maar dat er geen ip-adres is toegenkend.
- Het kan zijn dat er een comminicatiefout met de DHCP Server is ontstaan. Hierdoor gaan we de netwerkinterface uitschakelen (commando: `ifdown enp0s8`) en terug inschakelen (commando: `ifup enp0s8`) en kijken of er dan een ip-adres wordt toegekend. Na het terug in schakelen van de interface hebben we een fout gekregen, namelijk "Connection activation failed". We kunnen hieruit besluiten dat er een andere probleem is. Hoogstwaarschijnlijk is er een fout met de DHCP server. Dit gaan we controleren in de transport layer".
2. Nu gaan we de default gateway controlleren. Dit doen we met de commando `ip r`. Netwerkadapter enp0s8 heeft als default gateway 172.22.0.0/24 en enp0s3 heeft 10.0.2.0/24. Dus de default gateway klopt ook.
3. Nu gaan we de DNS instellingen controleren. We verwachten "10.0.2.3". Om te checken voeren we de volgende commando uit: `vi /etc/resolv.conf `. We krijgen als uitvoer "nameserver: 10.0.2.3". Dus de dns-server klopt.
We kunnen hieruit besluiten dat de network layer van de server goed geconfigureerd is.
### Transport Layer
### Application Layer
## End result

## Resources

