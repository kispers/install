#!/bin/bash

# Ubuntu 一键安装脚本：系统更新 + BBR加速 + XrayR

# 适用于 Ubuntu 18.04/20.04/22.04

set -e

RED=’\033[0;31m’
GREEN=’\033[0;32m’
YELLOW=’\033[1;33m’
NC=’\033[0m’

echo_info() {
echo -e “${GREEN}[信息]${NC} $1”
}

echo_error() {
echo -e “${RED}[错误]${NC} $1”
}

echo_warning() {
echo -e “${YELLOW}[警告]${NC} $1”
}

# 检查是否为root用户

check_root() {
if [[ $EUID -ne 0 ]]; then
echo_error “此脚本必须以root权限运行”
exit 1
fi
}

# 1. 系统更新

update_system() {
echo_info “开始更新系统…”
apt update -y
apt upgrade -y
apt autoremove -y
apt autoclean -y
echo_info “系统更新完成”
}

# 2. 开启BBR加速

enable_bbr() {
echo_info “开始配置BBR加速…”

```
# 检查内核版本
kernel_version=$(uname -r | cut -d. -f1)
if [ "$kernel_version" -lt 4 ]; then
    echo_warning "内核版本过低，BBR需要4.9+内核"
    return
fi

# 检查BBR是否已启用
if sysctl net.ipv4.tcp_congestion_control | grep -q bbr; then
    echo_info "BBR已经启用"
    return
fi

# 启用BBR
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

# 验证BBR
if sysctl net.ipv4.tcp_congestion_control | grep -q bbr; then
    echo_info "BBR加速已成功启用"
else
    echo_error "BBR启用失败"
fi
```

}

# 3. 安装XrayR

install_xrayr() {
echo_info “开始安装XrayR…”

```
# 安装必要的依赖
apt install -y curl wget sudo

# 下载并运行XrayR安装脚本
bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)

echo_info "XrayR安装完成"
echo_info "配置文件位置: /etc/XrayR/config.yml"
echo_info "使用以下命令管理XrayR:"
echo "  启动: xrayr start"
echo "  停止: xrayr stop"
echo "  重启: xrayr restart"
echo "  状态: xrayr status"
echo "  查看日志: xrayr log"
```

}

# 配置防火墙（可选）

configure_firewall() {
echo_info “配置防火墙…”

```
if command -v ufw &> /dev/null; then
    # 允许SSH
    ufw allow 22/tcp
    # 允许常用端口
    ufw allow 80/tcp
    ufw allow 443/tcp
    echo_info "防火墙规则已配置"
else
    echo_warning "未检测到UFW防火墙"
fi
```

}

# 显示系统信息

show_system_info() {
echo_info “================================”
echo_info “系统信息:”
echo “  操作系统: $(lsb_release -d | cut -f2)”
echo “  内核版本: $(uname -r)”
echo “  BBR状态: $(sysctl net.ipv4.tcp_congestion_control | cut -d= -f2)”
echo_info “================================”
}

# 主函数

main() {
echo_info “================================”
echo_info “Ubuntu 一键安装脚本”
echo_info “功能: 系统更新 + BBR加速 + XrayR”
echo_info “================================”

```
check_root

echo_warning "此脚本将执行以下操作："
echo "  1. 更新系统软件包"
echo "  2. 启用BBR TCP加速"
echo "  3. 安装XrayR面板对接程序"
echo ""
read -p "是否继续? (y/n): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo_info "安装已取消"
    exit 0
fi

# 执行安装步骤
update_system
enable_bbr
install_xrayr

echo_info "================================"
echo_info "安装完成！"
echo_info "================================"

show_system_info

echo ""
echo_warning "重要提示："
echo "  1. 请编辑 /etc/XrayR/config.yml 配置文件"
echo "  2. 配置完成后运行: xrayr restart"
echo "  3. 查看运行状态: xrayr status"
echo "  4. 如需BBR完全生效，建议重启系统: reboot"
```

}

# 运行主函数

main
