#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# ---------- 已有：helloworld（ssr/v2ray/trojan 依赖）----------
echo 'src-git helloworld https://github.com/fw876/helloworld' >> feeds.conf.default

# ---------- 新增：PassWall 主源 ----------
echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >> feeds.conf.default

# ---------- 新增：OpenClash（kenzok8 大包源）----------
echo 'src-git kenzo https://github.com/kenzok8/openwrt-packages' >> feeds.conf.default
echo 'src-git small https://github.com/kenzok8/small' >> feeds.conf.default
