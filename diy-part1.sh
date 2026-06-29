#!/bin/bash
# diy-part1.sh —— Lean's OpenWrt (lede) + 国内 Gitee 镜像源

# ===== 1. 写入 Lean lede 所需的 feeds（国内 Gitee 加速）=====
cat > feeds.conf.default << 'EOF'
src-git packages https://gitee.com/mirrors/openwrt-packages.git
src-git luci https://gitee.com/mirrors/openwrt-luci.git
src-git routing https://gitee.com/mirrors/openwrt-routing.git
src-git telephony https://gitee.com/mirrors/openwrt-telephony.git
EOF

# ===== 2. Git 稳定性优化 =====
git config --global http.postBuffer 524288000
git config --global http.lowSpeedLimit 1000
git config --global http.lowSpeedTime 30
export GIT_TERMINAL_PROMPT=0
