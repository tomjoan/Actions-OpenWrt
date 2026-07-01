#!/bin/bash
# diy-part2.sh —— After feeds install
# 用途：LAN/WAN 绑定、IP、主机名、DHCP、防火墙、WAN 防扫描

# ===== 1. 修改默认 LAN IP =====
sed -i 's/192.168.1.1/192.168.56.1/g' package/base-files/files/bin/config_generate

# ===== 2. 修改主机名 =====
sed -i "s/'OpenWrt'/'tom'/g" package/base-files/files/bin/config_generate

# ===== 3. 网络接口（eth2-3=WAN，eth0-1=LAN）=====
mkdir -p package/base-files/files/etc/config

cat << 'EOF' > package/base-files/files/etc/config/network
config interface 'loopback'
        option device 'lo'
        option proto 'static'
        option ipaddr '127.0.0.1'
        option netmask '255.0.0.0'

config globals 'globals'
        option ula_prefix 'fd00:ab:cd::/48'
        option packet_steering '1'

config interface 'lan'
        option proto 'static'
        option ipaddr '192.168.56.1'
        option netmask '255.255.255.0'
        option ip6assign '60'
        option multipath 'off'
        option device 'br-lan'

config interface 'wan'
        option device 'eth3'
        option proto 'static'
        option ipaddr '183.63.179.2'
        option netmask '255.255.255.248'
        option gateway '183.63.179.1'
        option multipath 'off'
        option metric '10'

config interface 'wan6'
        option device 'eth3'
        option proto 'dhcpv6'
        option reqprefix 'auto'
        option reqaddress 'try'

config interface 'docker'
        option device 'docker0'
        option proto 'none'
        option auto '0'

config device
        option type 'bridge'
        option name 'docker0'

config device
        option name 'br-lan'
        option type 'bridge'
        list ports 'eth0'
        list ports 'eth1'
        option stp '1'
        option igmp_snooping '1'

config interface 'wan2'
        option proto 'static'
        option device 'eth2'
        option ipaddr '192.168.0.245'
        option netmask '255.255.255.0'
        option gateway '192.168.0.2'
        option multipath 'off'
        option metric '20'
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

# ========================
# 修复 autosamba 与 samba4 冲突（Lean 源码专用）
# ========================

# 1. 物理删除 Lean 自带的 autosamba 包（冲突根源）
rm -rf package/lean/autosamba
rm -rf package/feeds/*/autosamba 2>/dev/null

# 2. 清理旧的 rootfs 残留（防止 opkg clash）
rm -f build_dir/target-*/root-*/etc/hotplug.d/block/20-smb 2>/dev/null

# ========================
# 跳过 GRUB 启动延迟（x86 专用）
# ========================
sed -i 's/CONFIG_GRUB_TIMEOUT=.*/CONFIG_GRUB_TIMEOUT=0/g' .config
sed -i 's/CONFIG_GRUB_HIDDEN_TIMEOUT=.*/CONFIG_GRUB_HIDDEN_TIMEOUT=0/g' .config

# 如果 .config 里没有这些配置，则追加
grep -q "CONFIG_GRUB_TIMEOUT=" .config || echo "CONFIG_GRUB_TIMEOUT=0" >> .config
grep -q "CONFIG_GRUB_HIDDEN_TIMEOUT=" .config || echo "CONFIG_GRUB_HIDDEN_TIMEOUT=0" >> .config
grep -q "CONFIG_GRUB_TIMEOUT_STYLE=" .config || echo "CONFIG_GRUB_TIMEOUT_STYLE=hidden" >> .config
grep -q "CONFIG_GRUB_DISABLE_OS_PROBER=" .config || echo "CONFIG_GRUB_DISABLE_OS_PROBER=y" >> .config

echo "=== GRUB 启动延迟已设置为 0 ==="
