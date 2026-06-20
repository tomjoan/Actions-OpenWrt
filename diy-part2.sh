#!/bin/bash
# diy-part2.sh —— After feeds install
# 用途：LAN/WAN 绑定、IP、主机名、DHCP、防火墙、WAN 防扫描

# ===== 1. 修改默认 LAN IP =====
sed -i 's/192.168.1.1/192.168.56.1/g' package/base-files/files/bin/config_generate

# ===== 2. 修改主机名 =====
sed -i "s/'OpenWrt'/'tom'/g" package/base-files/files/bin/config_generate

# ===== 3. 网络接口（eth3=WAN，eth0-2=LAN）=====
mkdir -p package/base-files/files/etc/config

cat << 'EOF' > package/base-files/files/etc/config/network
config interface 'loopback'
        option device 'lo'
        option proto 'static'
        option ipaddr '127.0.0.1'
        option netmask '255.0.0.0'

config globals 'globals'
        option ula_prefix 'fd00:ab:cd::/48'

config interface 'lan'
        option device 'eth0 eth1 eth2'
        option proto 'static'
        option ipaddr '192.168.56.1'
        option netmask '255.255.255.0'
        option ip6assign '60'

config interface 'wan'
        option device 'eth3'
        option proto 'dhcp'

config interface 'wan6'
        option device 'eth3'
        option proto 'dhcpv6'
        option reqprefix 'auto'
        option reqaddress 'try'
EOF

# ===== 4. DHCP 服务 =====
cat << 'EOF' > package/base-files/files/etc/config/dhcp
config dnsmasq
        option domainneeded '1'
        option boguspriv '1'
        option filterwin2k '0'
        option localise_queries '1'
        option rebind_protection '1'
        option rebind_localhost '1'
        option local '/lan/'
        option domain 'lan'
        option expandhosts '1'
        option nonegcache '0'
        option authoritative '1'
        option readethers '1'
        option leasefile '/tmp/dhcp.leases'
        option resolvfile '/tmp/resolv.conf.d/resolv.conf.auto'
        option nonwildcard '1'

config dhcp 'lan'
        option interface 'lan'
        option start '100'
        option limit '150'
        option leasetime '12h'
        option dhcpv4 'server'
        option dhcpv6 'server'
        option ra 'server'
        option ra_management '1'

config dhcp 'wan'
        option interface 'wan'
        option ignore '1'
EOF

# ===== 5. 防火墙（安全模式 + 防 WAN 扫描）=====
cat << 'EOF' > package/base-files/files/etc/config/firewall
config defaults
        option input 'ACCEPT'
        option output 'ACCEPT'
        option forward 'REJECT'
        option synflood_protect '1'

config zone
        option name 'lan'
        option network 'lan'
        option input 'ACCEPT'
        option output 'ACCEPT'
        option forward 'ACCEPT'

config zone
        option name 'wan'
        option network 'wan wan6'
        option input 'DROP'
        option output 'ACCEPT'
        option forward 'DROP'
        option masq '1'
        option mtu_fix '1'
        option family 'any'

# ===== 6. 显式禁止 WAN Ping（IPv4 + IPv6）=====
config rule
        option name 'Block WAN Ping IPv4'
        option src 'wan'
        option proto 'icmp'
        option icmp_type 'echo-request'
        option target 'DROP'
        option family 'ipv4'

config rule
        option name 'Block WAN Ping IPv6'
        option src 'wan'
        option proto 'icmp'
        option icmp_type 'echo-request'
        option target 'DROP'
        option family 'ipv6'

config forwarding
        option src 'lan'
        option dest 'wan'
EOF
