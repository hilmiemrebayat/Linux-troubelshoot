#! /usr/bin/env bats
#
# Acceptance test script for workstation.linuxlab.lan

readonly wan_interface='enp0s3'
readonly lan_interface='enp0s8'

readonly dhcp_range_low=101
readonly dhcp_range_high=253

readonly gateway_address='172.20.0.254'
readonly nat_gateway_address='10.0.2.2'
readonly nat_dns_address='10.0.2.3'

readonly external_website='icanhazip.com'
readonly internal_website='www.linuxlab.lan'
readonly webpage_content='welcome to linuxlab.lan'


@test "The host IP address should be in the expected range" {

  # IP address with CIDR subnet mask
  my_ip_cidr=$(ip address show dev ${lan_interface} | grep '\binet\b' | awk '{print $2}')
  my_ip="${my_ip_cidr%/*}"     # CIDR netmask stripped
  host_address="${my_ip##*.}"  # host-part of the IP address

  echo "IP-address on ${lan_interface}: ${my_ip}"
  echo "Host-part: ${host_address}"

  # The host-part of the IP address should be higher than the DHCP range lower
  # bound and lower than
  [ "${host_address}" -ge "${dhcp_range_low}" ]
  [ "${host_address}" -le "${dhcp_range_high}" ]

}

@test "The gateway from the NAT interface should not be active." {
  # Get IP address(es) of the default gateway(s)
  gateway=$(ip route | grep default | awk '{print $3;}')
  # The default gateway of the NAT interface should not be in the output of
  # the default route.
  run grep --fixed-strings "${nat_gateway_address}" <<< "${gateway}"

  echo "Invalid default gateway settings. Disable the NIC attached to the NAT interface (${wan_interface})"
  echo -e "Expected gateway:\n${gateway_address}"
  echo -e "Actual default gateway(s):\n${gateway}"

  [ -z "${output}" ]
  [ "${gateway}" = "${gateway_address}" ]
}

@test "The DNS service from the NAT interface should not be active." {
  run grep --fixed-strings "${nat_dns_address}" /etc/resolv.conf

  [ -z "${output}" ]
}

@test "Name resolution for external websites should succeed" {
  dig "${external_website}" +short
}

@test "Name resolution for internal website should succeed" {
  dig "${internal_website}" +short
}

@test "It should be possible to access ${internal_website}" {
  run curl --silent "http://${internal_website}/"

  echo "Expected page content: ${webpage_content}"
  echo "Actual content:        ${output}"

  [ "${status}" -eq 0 ] # The curl command should succeed
  [ "${webpage_content}" = "${output}" ] # The web page should have the expected content
}

@test "It should be possible to access websites on the Internet" {
  run curl --silent "http://${external_website}"

  echo -e "Web page content:\n${output}"

  [ "${status}" -eq 0 ] # The curl command should succeed
  [ -n "${output}" ]    # The web page should be nonempty
}


