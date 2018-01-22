#! /usr/bin/bash
#
# Provisioning script for srv010

#----------------------------------------------------------------------------
# Bash settings
#----------------------------------------------------------------------------

# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't mask errors in piped commands
set -o pipefail

#----------------------------------------------------------------------------
# Variables
#----------------------------------------------------------------------------

# Location of provisioning scripts and files
export readonly PROVISIONING_SCRIPTS="/vagrant/provisioning/"
# Location of files to be copied to this server
export readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}/files/${HOSTNAME}"

# Dhcpd config file
dhcp_conf="${PROVISIONING_FILES}/etc_dhcp_dhcpd.conf"

# /etc/hosts
hosts_file="${PROVISIONING_FILES}/etc_hosts"

# Index page for website
website_index="${PROVISIONING_FILES}/var_www_html_index.html"

#----------------------------------------------------------------------------
# "Imports"
#----------------------------------------------------------------------------

# Utility functions
source ${PROVISIONING_SCRIPTS}/util.sh
# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh

#----------------------------------------------------------------------------
# Provision server
#----------------------------------------------------------------------------

info "Starting host specific provisioning tasks on ${HOSTNAME}"

# Workaround for a problem where host-only interface does not get an IP address
# from Vagrant.
systemctl restart network.service

#---------- DHCPD -----------------------------------------------------------

info "Installing ISC-DHCP"
yum -y install dhcp

info "Enabling service"
ensure_service_enabled dhcpd.service

info "Applying firewall rules"
firewall-cmd --permanent --add-service dhcp
firewall-cmd --permanent --add-interface enp0s8
systemctl restart firewalld.service

if files_differ "${dhcp_conf}" /etc/dhcp/dhcpd.conf ; then
  info "Copying configuration file to the server"
  cp "${dhcp_conf}" /etc/dhcp/dhcpd.conf
else
  info "No changes to config"
fi

#---------- Dnsmasq ---------------------------------------------------------

info "Installing Dnsmasq"
yum -y install dnsmasq

info 'Enabling service'
ensure_service_enabled dnsmasq.service

if files_differ "${hosts_file}" /etc/hosts; then
  info "Copying hosts file"
  cp "${hosts_file}" /etc/hosts
else
  info "No changes to config"
fi

#---------- Apache ----------------------------------------------------------

info "Installing Apache"
yum -y install httpd

info 'Enabling service'
ensure_service_started httpd.service

info "Applying firewall rules"
firewall-cmd --permanent --add-service http
systemctl restart firewalld.service

if files_differ "${website_index}" /var/www/html/index.html; then
  info "Copying website index"
  cp "${website_index}" /var/www/html/index.html
fi

