#!/bin/bash

set -euo pipefail

# Download Cloudflare IPs
curl -s https://www.cloudflare.com/ips-v4 -o /tmp/cloudflare_ips_$$
echo "" >> /tmp/cloudflare_ips_$$
curl -s https://www.cloudflare.com/ips-v6 >> /tmp/cloudflare_ips_$$

# Verify download
if [[ ! -s /tmp/cloudflare_ips_$$ ]]; then
  echo "Failed to download Cloudflare IPs. Aborting." >&2
  exit 1
fi

# Reset firewall
ufw --force reset

# Enable firewall
ufw enable

# Add an exception
ufw allow from 1.1.1.1

# Allow incoming SSH
ufw allow ssh

# Allow traffic from Cloudflare IPs on all ports
for ip in $(cat /tmp/cloudflare_ips_$$)
do
  ufw allow proto tcp from $ip comment 'Cloudflare Script'
done

# Reject HTTP/HTTPS for the remaining IPs
ufw reject 80
ufw reject 443

# Reload firewall
ufw reload > /dev/null

# Show the rules
ufw status numbered