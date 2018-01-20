# Labo Troubleshooting 3: LAN
## Enterprise Linux 17-18
Bachelor toegepaste informatica, HoGent Bedrijf en Organisatie
<br><br>
Studenten die na de eerste twee troubleshooting-labo’s hun bekwaamheid nog niet hebben aangetoond
krijgen met deze opgave nog een kans om dit te doen. Doel van deze opgave is een werkstation in een LAN
toegang te geven tot de services op het netwerk (DNS, DHCP, web) en het internet.
## Contents
### 1. Opdrachtomschrijving 
1. Vagrant-omgeving 
2. Router 
3. Server
4. Werkstation
### 2. Rapportering 
## 1. Opdrachtomschrijving
In dit labo krijg je een opstelling zoals in Figuur 1, een minimaal functioneel LAN. De opgave zal worden doorgegeven in
de vorm van de broncode voor een Vagrant-omgeving. Elke student krijgt individueel een verschillende opgave, zij het
gebaseerd op dezelfde structuur. De opgave wordt doorgegeven één week voor het finale evaluatiemoment. Je kan er
thuis aan werken en het resultaat demonstreren binnen de je toegewezen tijd op het evaluatiemoment.
<br><br>Bij vagrant up worden drie VMs, router, server en workstation, opgestart die elk geconfigureerd zijn aan de hand
van een shell-script1. Uiteraard zitten er fouten in de opstelling, het is jouw taak die op te sporen. De bedoeling is om er
voor te zorgen dat het werkstation toegang krijgt zowel tot het lokale netwerk als het Internet.
<br><br>Als voorbereiding kan je eventueel zelf al een omgeving opstellen met deze specificaties. Je kan als startpunt gebruik
maken van https://github.com/bertvv/vagrant-shell-skeleton/. Voor het configuratiescript van de router kan je baseren
op https://github.com/HoGentTIN/elnx-sme/blob/master/scripts/router-config.sh.
<br><br>De VMs zijn aangesloten op een VirtualBox interne netwerkinterface, niet op een host-only interface. Dat betekent dat
het hostsysteem niet aangesloten is op het LAN en je dus ook niet rechtstreeks vanop je hostsysteem kan pingen naar
de VMs.
<br><br>Het IP-adres van het LAN kan voor elke individuele opdracht verschillend zijn, maar voldoet altijd aan volgende
eigenschappen:
• Het subnetmasker is “/24”
• De server heeft als host-deel van het IP-adres “.2”
• De router heeft als host-deel van het IP-adres “.254”
• De DHCP-server deelt IP-adressen uit van .101 tot en met .253
1 Je zal dus exact kunnen nagaan hoe de machines opgezet zijn, maar wees a.u.b. zo verstandig om niet te veel veronderstellingen te doen naar
aanleiding van wat je daarin vindt. Niet veronderstellen, maar testen!

![IP tabel en afbeedling](https://github.com/hilmiemrebayat/Linux-troubelshoot/blob/master/afbeelding1.jpeg)
### 1.1 Vagrant-omgeving
De opstelling wordt aangeboden in de vorm van een Vagrant-omgeving die als volgt gestructureerd is:
```
$ tree
.
├── provisioning
│ ├── common.sh
│ ├── files
│ │ ├── server
│ │ │ ├── etc_dhcp_dhcpd.conf
│ │ │ ├── etc_hosts
│ │ │ └── var_www_html_index.html
│ │ └── workstation
│ │ └── acceptance_tests.bats
│ ├── router.sh
│ ├── server.sh
│ ├── util.sh
│ └── workstation.sh
├── Vagrantfile
└── vagrant-hosts.yml
```
De configuratie van de drie VMs gebeurt aan de hand van shellscripts die je vindt in de directory provisioning, met de
naam van de overeenkomstige VM. Het script util.sh bevat enkele herbruikbare Bash-functies. Bestanden die naar de
VMs gekopieerd worden vind je in een subdirectory onder provisioning/files/ met de naam van de VM.
### 1.2 Router
De router (VyOS) verbindt het LAN (gesimuleerd met een VirtualBox internal network) met het Internet via een VirtualBox
NAT-interface. De router doet zelf ook aan Network Address Translation voor netwerkverkeer dat vanuit het LAN naar het
Internet gaat. Verder heeft de router geen functies (dus geen DNS forwarding of DHCP).

### 1.3 Server
Op server (CentOS 7) zijn drie services actief: DNS, DHCP en een webserver.
- DNS:
  - Geïmplementeerd met Dnsmasq, een eenvoudige caching DNS service. Name resolution gebeurt op basis van twee bronnen:
    - eerst wordt gekeken of de opgevraagde hostnaam in /etc/hosts vermeld staat. Zo ja wordt het geassocieerde IP-adres teruggegeven.
    - Indien niet, wordt de query doorgegeven aan de DNS server(s) opgesomd in /etc/resolv.conf.
  - De DNS-server moet namen binnen het eigen domein (linuxlab.lan) kunnen omzetten (gedefinieerd in /etc/hosts)
  - De DNS-server moet ook namen van externe websites kunnen omzetten (bv. google.be, icanhazip.com, …)
- DHCP:
  - Werkstations die zich aanmelden op het LAN krijgen een geschikt IP-adres van de DHCP-server.
  - De DHCP-server geeft ook het correcte IP-adres voor de default gateway en DNS server die werkstations mogen gebruiken
- Website:
  - Een eenvoudige installatie van Apache (geen database, geen scripting) met een minimale webpagina (inhoud: “welcome to linuxlab.lan”)
### 1.4 Werkstation
Het werkstation (CentOS 7) mag enkel aangesloten zijn op het interne netwerk. Dat betekent dat na opzetten van de
VM met Vagrant de verbinding via de NAT-interface moet verbroken worden. De VM kan dan niet meer met vagrant
aangestuurd worden en je zal dus moeten inloggen op deze machine vanuit de VirtualBox GUI.
<br><br>Na opzetten van het netwerk met vagrant up ga je naar de VirtualBox GUI en selecteer je de VM lan_workstation_...
in de groep “lan”. Klik in de commandoknoppenbalk bovenaan op “Show”. In het venster van de VM kies je in het menu
bovenaan voor “Devices > Network > Connect Network Adapter 1”, wat hetzelfde effect heeft als het selectievakje
“Cable connected” uit te zetten.
<br><br>Je moet kunnen aantonen dat het werkstation:
- enkel aangesloten is op het interne netwerk
- de lokale website kan bekijken (www.linuxlab.lan)
- een site op het Internet kan bekijken (vb. icanhazip.com)
<br><br>Er worden acceptatietests geïnstalleerd op het werkstation als het commando acceptance-tests (in /usr/local/bin),
maar staar je niet altijd blind op de uitvoer hiervan. Ga zelf op een gestructureerde en grondige manier op zoek naar de
oorzaak van de problemen door de geschikte commando’s te gebruiken.
## 2. Rapportering
- Schrijf een gedetailleerd rapport ahv het bijgevoegde sjabloon (Nederlands of Engels). Gebruik telegramstijl, het is niet nodig er een doorlopende tekst (“opstel”) van te maken.
- Gebruik correcte Markdown! Dit is een eenvoudig formaat, dus geen reden om een slecht opgemaakt rapport in te dienen.
- De verschillende fasen in het bottom-up troubleshooting-proces worden in een eigen sectie besproken met de naam van de fase als titel.
- Elke stap is gedetailleerd beschreven:
  - Wat getest wordt;
  - Gebruikte commando’s, inclusief opties en argumenten, en/of absolute paden naar de configuratiebestanden die nagekeken moeten worden;
  - De verwachte uitvoer van het commando/inhoud van het configuratiebestand (enkel relevante delen zijn
voldoende);
  -Als de bekomen uitvoer verschilt van de verwachte, geef de vermoedelijke oorzaak en beschrijf hoe je dit hebt opgelost door opgave van de exacte commando’s en/of wijzigingen in configuratiebestanden.
- Beschrijf het eindresultaat:
  - Wat werkt, wat werkt niet?
  - Kopieer een transcriptie van de uitvoer van de acceptatietests op het werkstation
  - Beschrijf enige foutboodschappen die nog overblijven
