#! /usr/bin/bash
#
# Provisioning script common for all servers

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
# TODO: put all variable definitions here. Tip: make them readonly if possible.

# Name of the admin user. Exporting makes it available in the server specific
# scripts.
export readonly ADMIN_USER=admin
# Password of the admin user = admin
readonly admin_passwd='$6$lrTcA7aDjoPcqZcM$3di/Ys1409AH9oxxW.0iIILSbQakLKp.0B0/t40X1bCEZjA3zv133CM/YA3xG7F6FbfpGNw2PIws7MV7igfz50'

#------------------------------------------------------------------------------
# Package installation
#------------------------------------------------------------------------------

info Starting common tasks
info Installating common packages

yum install -y epel-release
yum install -y bind-utils git nano tree vim-enhanced

#------------------------------------------------------------------------------
# Admin user
#------------------------------------------------------------------------------

info Setting up admin user account
ensure_user_exists "${ADMIN_USER}"

usermod --password="${admin_passwd}" "${ADMIN_USER}"

assign_groups "${ADMIN_USER}" wheel

