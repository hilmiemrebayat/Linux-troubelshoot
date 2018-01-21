#! /usr/bin/bash
#
# Provisioning script for srv010

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------

# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't mask errors in piped commands
set -o pipefail

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

# Location of provisioning scripts and files
export readonly provisioning_scripts="/vagrant/provisioning/"
# Location of files to be copied to this server
export readonly provisioning_files="${provisioning_scripts}/files/${HOSTNAME}"

test_script_src="${provisioning_files}/acceptance_tests.bats"
test_script_dest='/usr/local/bin/acceptance-tests'

#------------------------------------------------------------------------------
# "Imports"
#------------------------------------------------------------------------------

# Utility functions
source "${provisioning_scripts}/util.sh"

#------------------------------------------------------------------------------
# Provision host
#------------------------------------------------------------------------------

info "Starting host specific provisioning tasks on ${HOSTNAME}"

# Workaround for a problem where host-only interface does not get an IP address
# from Vagrant.
systemctl restart network.service

info "Installing packages that may be of use for troubleshooting"

sudo yum install -y \
  bind-utils \
  git \
  nano \
  tree \
  vim-enhanced

ensure_bats_installed

if files_differ "${test_script_src}" "${test_script_dest}"; then
  info "Copying acceptance test script"
  cp "${test_script_src}" "${test_script_dest}"
  chmod 755 "${test_script_dest}"
fi

info "Provisioning ${HOSTNAME} finished. Don't forget to disconnect the NAT interface!"
