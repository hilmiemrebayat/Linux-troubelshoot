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




