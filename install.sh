#!/bin/bash

set -e

# 检查root权限
if [[ $EUID -ne 0 ]]; then
    echo "[错误] 此脚本必须以root权限运行"
    exit 1
fi

echo "================================"
echo "Ubuntu 一键安装脚本"
echo "================================"

# 系统更新
echo "[1/3] 更新系统..."
apt update -y && apt upgrade -y

# 启用BBR
echo "[2/3] 启用BBR加速..."
if ! sysctl net.ipv4.tcp_congestion_control | grep -q bbr; then
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p
fi

# 安装XrayR
echo "[3/3] 安装XrayR..."
apt install -y curl wget sudo
bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)

echo "================================"
echo "安装完成！"
echo "配置文件: /etc/XrayR/config.yml"
echo "================================"
