#!/bin/bash
# diy-part1.sh —— Before Update feeds

# Git 稳定性优化
git config --global http.postBuffer 524288000
git config --global http.lowSpeedLimit 1000
git config --global http.lowSpeedTime 30
export GIT_TERMINAL_PROMPT=0

# GitHub 加速前缀
_GHPROXY="https://ghproxy.com/"

# helloworld（ssr/v2ray/trojan 依赖，OpenClash 需要）
echo "src-git helloworld ${_GHPROXY}https://github.com/fw876/helloworld" >> feeds.conf.default

# OpenClash（kenzok8 大包源）
echo "src-git kenzo ${_GHPROXY}https://github.com/kenzok8/openwrt-packages" >> feeds.conf.default
echo "src-git small ${_GHPROXY}https://github.com/kenzok8/small" >> feeds.conf.default
