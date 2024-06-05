#!/bin/sh
#
# To download this script directly from freeBSD:
# $ pkg install git
# you need to pull hw2.sh from my git to run the bash script 
# in order to update the ssh configuration. 
# git clone https://gitlab.cecs.pdx.edu/anhho/secdevops-anhho.git
# then go to the folder which has hw2.sh file. 
# root@freebsd:~ # cd secdevops-anhho/hw2
# then run the script by sh hw2.sh


#The following features are added:
# - switching (internal to the network) via FreeBSD pf
# - DHCP server, DNS server via dnsmasq
# - firewall via FreeBSD pf
# - NAT layer via FreeBSD pf
#

# Set your network interfaces names; set these as they appear in ifconfig
# they will not be renamed during the course of installation
# update the network name if needed based on your network name setting
# command: sed -i '' -e 's/WAN="hn0"/WAN="vtnet0"/g; s/LAN="hn1"/LAN="vtnet1"/g' hw2.sh
WAN="hn0"
LAN="hn1"

# Install dnsmasq
pkg install -y dnsmasq

# Enable forwarding
sysrc gateway_enable="YES"
# Enable immediately
sysctl net.inet.ip.forwarding=1

# Set LAN IP
ifconfig ${LAN} inet 192.168.33.1 netmask 255.255.255.0
# Make IP setting persistent
sysrc "ifconfig_${LAN}=inet 192.168.33.1 netmask 255.255.255.0"

ifconfig ${LAN} up
ifconfig ${LAN} promisc

# Enable dnsmasq on boot
sysrc dnsmasq_enable="YES"

# Edit dnsmasq configuration
echo "interface=${LAN}" >> /usr/local/etc/dnsmasq.conf
echo "dhcp-range=192.168.33.50,192.168.33.150,12h" >> /usr/local/etc/dnsmasq.conf
echo "dhcp-option=option:router,192.168.33.1" >> /usr/local/etc/dnsmasq.conf

# Configure PF for NAT

# Define the content to be added to pf.conf
content="
ext_if=\"${WAN}\"
int_if=\"${LAN}\"

icmp_types = \"{ echoreq, unreach }\"
services = \"{ ssh, domain, http, ntp, https, 6666}\"
server = \"192.168.33.63\"
ssh_rdr = \"22\"
table <rfc6890> { 0.0.0.0/8 10.0.0.0/8 100.64.0.0/10 127.0.0.0/8 169.254.0.0/16          \\
                  172.16.0.0/12 192.0.0.0/24 192.0.0.0/29 192.0.2.0/24 192.88.99.0/24    \\
                  192.168.0.0/16 198.18.0.0/15 198.51.100.0/24 203.0.113.0/24            \\
                  240.0.0.0/4 255.255.255.255/32 }
table <bruteforce> persist

#options
set skip on lo0

#normalization
scrub in all fragment reassemble max-mss 1440

#NAT rules
nat on \$ext_if from \$int_if:network to any -> (\$ext_if)

# Port Forwarding Rule for SSH to Ubuntu Queueing (if applicable)
rdr on \$ext_if proto tcp to (\$ext_if) port \$ssh_rdr -> 192.168.33.135 port 22

#blocking rules
antispoof quick for \$ext_if
block in quick on egress from <rfc6890>
block return out quick on egress to <rfc6890>
block log all

#pass rules
pass in quick on \$int_if inet proto udp from any port = bootpc to 255.255.255.255 port = bootps keep state label \"allow access to DHCP server\"
pass in quick on \$int_if inet proto udp from any port = bootpc to \$int_if:network port = bootps keep state label \"allow access to DHCP server\"
pass out quick on \$int_if inet proto udp from \$int_if:0 port = bootps to any port = bootpc keep state label \"allow access to DHCP server\"

pass in quick on \$ext_if inet proto udp from any port = bootps to \$ext_if:0 port = bootpc keep state label \"allow access to DHCP client\"
pass out quick on \$ext_if inet proto udp from \$ext_if:0 port = bootpc to any port = bootps keep state label \"allow access to DHCP client\"

pass in on \$ext_if proto tcp to port { ssh, 6666 } keep state (max-src-conn 15, max-src-conn-rate 3/1, overload <bruteforce> flush global)
pass out on \$ext_if proto { tcp, udp } to port \$services
pass out on \$ext_if inet proto icmp icmp-type \$icmp_types
pass in on \$int_if from \$int_if:network to any
pass out on \$int_if from \$int_if:network to any

# Allow incoming SSH connections - matching rules from redirect
pass in on \$ext_if proto tcp to (\$ext_if) port \$ssh_rdr
pass out on \$int_if proto { tcp } to 192.168.33.135 port ssh

# allow port 445 SMB                                                                                                                   
pass in on \$ext_if proto tcp from any to any port 445
pass out on \$ext_if proto tcp from any to any port 445
"

# Define the path to pf.conf
pf_conf="/etc/pf.conf"

# Read the content of pf.conf into a variable
existing_content=$(<"$pf_conf")

# Check if pf.conf is different from content
if [ "$existing_content" != "$content" ]; then
  # Append the content to pf.conf
  echo "$content" > "$pf_conf"
  echo "Content updated in pf.conf."
else
  echo "Content in pf.conf is already up to date."
fi

# Start dnsmasq
service dnsmasq start

# Enable PF on boot
sysrc pf_enable="YES"
sysrc pflog_enable="YES"

# Enable Snort services
sysrc snort_enable="YES"

# Start PF
service pf start

# Load PF rules
pfctl -f /etc/pf.conf