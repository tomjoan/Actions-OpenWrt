#!/bin/bash
# diy-part1.sh —— 只用官方 LEDE 源（最稳方案）

# ===== 1. 清空并写入官方 feeds =====
# 使用 cat > 确保文件内容干净，不残留任何第三方源
cat > feeds.conf.default << 'EOF'
src-git packages https://github.com/coolsnowwolf/packages
src-git luci https://github.com/coolsnowwolf/luci.git;openwrt-25.12
src-git routing https://github.com/coolsnowwolf/routing
src-git telephony https://github.com/coolsnowwolf/telephony.git
EOF

# ===== 2. Git 稳定性优化（防超时/断流）=====
git config --global http.postBuffer 524288000
git config --global http.lowSpeedLimit 1000
git config --global http.lowSpeedTime 30
export GIT_TERMINAL_PROMPT=0 
