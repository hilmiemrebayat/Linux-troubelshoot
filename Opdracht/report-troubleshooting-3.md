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
#### Eerste controle (voordat DHCP service werkte)
1. Start de VM "Workstation" en controleer of de ip-adressen toegekend en juist zijn. Dit controleer je met de commando `ip a`. Na het uitvoeren van de commando zien we dat de netwerkinterface op up staat maar dat er geen ip-adres is toegenkend.
- Het kan zijn dat er een communicatiefout met de DHCP Server is ontstaan. Hierdoor gaan we de netwerkinterface uitschakelen (commando: `ifdown enp0s8`) en terug inschakelen (commando: `ifup enp0s8`) en kijken of er dan een ip-adres wordt toegekend. Na het terug in schakelen van de interface hebben we een fout gekregen, namelijk "Connection activation failed". We kunnen hieruit besluiten dat er een andere probleem is. Hoogstwaarschijnlijk is er een fout met de DHCP server. Dit gaan we controleren in de transport layer.
2. Nu gaan we de default gateway controlleren. Dit doen we met de commando `ip r`. Normaal gezien zou er geen default gateway zijn aangezien er ook geen ip-adres is toegekend, maar we zullen het toch controleren. Na het uitvoeren van de commando zien we dat er geen default gateway is toegekend.
3. Het controleren van de DNS server heeft geen zin aangezien er geen verbinding is.
Hieruit kunnen we besluiten dat er een probleem is met de netwerk. Vermoedelijk is er een probleem met de DHCP server. Dit gaan we nu controleren in het transport layer.
#### Tweede controle (nadat DHCP service is gestart)
1. Start de VM "Workstation" en controleer of de ip-adressen toegekend en juist zijn. Dit controleer je met de commando `ip a`. Na het uitvoeren van de commando zien we dat de netwerkinterface op up staat en dat er ip-adres wordt toegekend. Het ip-adres is namelijk 172.22.0.101/24
2. Nu gaan we de default gateway controlleren. Dit doen we met de commando `ip r`. Als uitvoer krijgen we 172.20.0.254. Hieruit besluiten we dat de default gateway ook klopt.
3. Als laatst controleren we de DNS server. Dit doen we met de commando `vi /etc/resolv.conf `. Na het uitvoeren van de commando krijgen we als uitvoer "172.22.0.2", dus de DNS klopt ook.
### Transport Layer
#### DHCP
1. Eerst controleren we of dhcp actief is. Dit doen we met de commando `service dhcpd status`.  Als uitvoer krijgen we "Active : inactive (dead). Dus er is een probleem met dhcp.
- We gaan dhcp proberen op te starten met de commando 'sudo service dhcpd start' --> Starten lukt niet. Als uitvoer wordt er gezegd dat we de logboek moeten bekijken. Na het bekijken van de logboek (commando: `sudo journalctl -xe`) kunnen we besluiten dat er een fout is met de dhcp.service.
- We gaan controleren of er fouten aanwezig zijn in de file "dhcpd.conf". Het kan zijn dat hierdoor de dhcp service niet opstart. De dhcpd.conf bekijken we met de commando `sudo vi /etc/dhcp/dhcpd.conf`. Na het bekijken zien we dat er fouten aanwezig zijn. Verander dhcpd.conf als volgt:
```
# dhcpd.conf -- linuxlab.lan

authoritative;

#subnet stond op 172.20.0.0 en netmask stond op 255.0.0.0
subnet 172.22.0.0 netmask 255.255.255.0 {
  # interface moest toegevoegd worden, anders werkte het niet. Er werd altijd een foutmelding gegeven, dat de interface niet goed werd geconfigureerd
  interface enp0s8;
  # range stond als volgt, wat verkeerd was: 172.20.0.101 tot 172.20.0.253
  range 172.22.0.101 172.22.0.253;

  option domain-name "linuxlab.lan";
  
  option routers 172.20.0.254;
  #DNS moet van 8.8.8.8 naar 172.22.0.2 veranderd worden
  option domain-name-servers 172.22.0.2;

  default-lease-time 14400;
  max-lease-time 21600;
}

```
- Na het wijzigen van de dhcpd.conf, herstart je de dhcp service met de commando `sudo systemctl restart dhcpd`.Na het uitvoeren van de commando is de dhcp service succesvol gestart en kan men zien dat het actief is. Om te cotroleren of het echt werkt gaan we de interface van de workstation uit (commando: `ifdown enp0s8`) en terug inschakelen (commando: `ifup enp0s8`)en kijken of er automatisch een ip-adres is toegekend. Na het uit en terug inschakelen zien we dat er een ip-adres is toegekend en kunnen we dus besluiten dat de dhcp service werkt.

- Als laatst gaan we ook de firewall controleren met de commando `sudo iptables -L -n`. De poort 67 moet normaalgezien open staan. Na het uitvoeren van de commando zien we dat de firewall goed is geconfigureerd.

Besluit: DHCP server werkt nu zonder problemen
#### HTTP
- We controleren of httpd actief is, dit doen we met de commando `sudo systemctl status httpd`. Na het uitvoeren van de commando zien we dat het niet actief is. Om het te activeren gebruiken we de commando `sudo systemctl start httpd`, wat normaalgezien zonder problemen moet lukken. Na het uitvoeren van de commando zien we dat httpd zonder problemen start. 
- Aangezien httpd niet start tijdens het opstarten van de server moeten we de volgende commando uitvoeren zodat het wel start tijdens het opstarten van de server: `sudo systemctl enable httpd` Na het uitvoeren en opnieuw starten van de server (commando `reboot`) controleren we nog eens de status met de commando `sudo systemctl status httpd` en zien we dat httpd automatisch is opgestard.
- Als laatst controleren we met de commando  `sudo iptables -L -n` controleren of de poort (poort 80) voor httpd open staan. Na het uitvoeren van de commando zien we dat de firewall goed is geconfigureerd. 

- Nu alles gecontrolleerd is gaan we vanuit de werkstation de acceptance-test uitvoeren en kijken of de website op de server bereikbaar is. Na het uitvoeren zien we dat de website niet bereikbaar is. Hoogstwaarschijnlijk is er een probleem met de DNS. Dit gaan we controleren in het volgende hoofdstuk.

Besuit: Apache (httpd) werkt zonder problemen maar website is niet bereikbaar.

#### DNS



### Application Layer
## End result

## Resources

