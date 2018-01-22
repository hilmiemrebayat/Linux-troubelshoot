#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

configure

# Fix for error "INIT: Id "TO" respawning too fast: disabled for 5 minutes"
delete system console device ttyS0

#------------------------------------------------------------------------------
# Basic settings
#------------------------------------------------------------------------------

set system host-name 'Router'

#------------------------------------------------------------------------------
# IP settings
#------------------------------------------------------------------------------

set interfaces ethernet eth0 description 'WAN'
set interfaces ethernet eth0 address dhcp

set interfaces ethernet eth1 description 'LAN'
set interfaces ethernet eth1 address 172.20.0.254/24

set system gateway-address 10.0.2.2
set system name-server 172.20.0.254

#------------------------------------------------------------------------------
# Network Address Translation
#------------------------------------------------------------------------------

set nat source rule 100 outbound-interface 'eth0'
set nat source rule 100 source address '172.20.0.0/24'
set nat source rule 100 translation address 'masquerade'

set nat source rule 200 outbound-interface 'eth1'
set nat source rule 200 translation address 'masquerade'
set nat source rule 200 source address '172.20.0.0/24'
#------------------------------------------------------------------------------
# Time
#------------------------------------------------------------------------------

# Set time zone and use the Belgian NTP servers for synchronizing time
set system time-zone 'Europe/Brussels'

#------------------------------------------------------------------------------
# Clean up, commit changes
#------------------------------------------------------------------------------
set service dns forwarding domain avalon.lan server 172.22.0.2
set service dns forwarding name-server 10.0.2.15
set service dns forwarding listen-on 'eth1'

commit
save

# Fix permissions on configuration
sudo chown -R root:vyattacfg /opt/vyatta/config/active

# vim: set ft=sh
