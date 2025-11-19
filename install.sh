#!/bin/bash

# Ubuntu 一键安装脚本：系统更新 + BBR + XrayR + 宝塔国际版 + Docker + 流媒体测试 + 三网回程

# 适用于 Ubuntu 18.04/20.04/22.04/24.04

set -e

# 检查root权限

check_root() {
if [[ $EUID -ne 0 ]]; then
echo “[错误] 此脚本必须以root权限运行”
exit 1
fi
}

# 显示菜单

show_menu() {
clear
echo “================================”
echo “  Ubuntu 一键安装脚本”
echo “================================”
echo “1. 系统更新”
echo “2. 启用 BBR 加速”
echo “3. 安装 XrayR”
echo “4. 安装宝塔面板国际版”
echo “5. 安装 Docker”
echo “6. 流媒体解锁测试”
echo “7. 三网回程路由测试”
echo “================================”
echo “8. 一键安装(更新+BBR+XrayR)”
echo “9. 一键安装(更新+BBR+宝塔+Docker)”
echo “10. VPS测试套餐(更新+BBR+XrayR+流媒体+回程)”
echo “================================”
echo “0. 退出脚本”
echo “================================”
}

# 1. 系统更新

update_system() {
echo “================================”
echo “[1/1] 开始更新系统…”
echo “================================”
apt update -y
apt upgrade -y
apt autoremove -y
apt autoclean -y
echo “[完成] 系统更新完成”
echo “”
}

# 2. 启用BBR

enable_bbr() {
echo “================================”
echo “[1/1] 配置 BBR 加速…”
echo “================================”

```
# 检查内核版本
kernel_version=$(uname -r | cut -d. -f1)
if [ "$kernel_version" -lt 4 ]; then
    echo "[警告] 内核版本过低，BBR需要4.9+内核"
    echo "[提示] 当前内核: $(uname -r)"
    return
fi

# 检查BBR是否已启用
if sysctl net.ipv4.tcp_congestion_control | grep -q bbr; then
    echo "[提示] BBR 已经启用"
    echo "[状态] $(sysctl net.ipv4.tcp_congestion_control)"
    return
fi

# 启用BBR
if ! grep -q "net.core.default_qdisc=fq" /etc/sysctl.conf; then
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
fi

if ! grep -q "net.ipv4.tcp_congestion_control=bbr" /etc/sysctl.conf; then
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
fi

sysctl -p > /dev/null 2>&1

# 验证BBR
if sysctl net.ipv4.tcp_congestion_control | grep -q bbr; then
    echo "[完成] BBR 加速已成功启用"
    echo "[状态] $(sysctl net.ipv4.tcp_congestion_control)"
else
    echo "[失败] BBR 启用失败"
fi
echo ""
```

}

# 3. 安装XrayR

install_xrayr() {
echo “================================”
echo “[1/2] 安装依赖…”
echo “================================”
apt install -y curl wget sudo

```
echo "================================"
echo "[2/2] 开始安装 XrayR..."
echo "================================"
bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)

echo ""
echo "[完成] XrayR 安装完成"
echo "================================"
echo "配置文件: /etc/XrayR/config.yml"
echo "================================"
echo "管理命令:"
echo "  xrayr start   - 启动服务"
echo "  xrayr stop    - 停止服务"
echo "  xrayr restart - 重启服务"
echo "  xrayr status  - 查看状态"
echo "  xrayr log     - 查看日志"
echo "================================"
echo ""
```

}

# 4. 安装宝塔面板国际版

install_aapanel() {
echo “================================”
echo “[1/1] 开始安装宝塔面板国际版…”
echo “================================”

```
# 检查是否已安装
if [ -f /www/server/panel/class/common.py ]; then
    echo "[提示] 检测到宝塔面板已安装"
    echo "[路径] /www/server/panel/"
    return
fi

# 安装宝塔国际版 (aaPanel)
wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh
bash install.sh

echo ""
echo "[完成] 宝塔面板安装完成"
echo "================================"
echo "面板地址会在安装结束后显示"
echo "默认端口: 8888"
echo "================================"
echo ""
```

}

# 5. 安装Docker

install_docker() {
echo “================================”
echo “[1/4] 检查 Docker 安装状态…”
echo “================================”

```
# 检查是否已安装
if command -v docker &> /dev/null; then
    echo "[提示] Docker 已安装"
    echo "[版本] $(docker --version)"
    return
fi

echo "================================"
echo "[2/4] 更新软件包..."
echo "================================"
apt update -y

echo "================================"
echo "[3/4] 安装依赖..."
echo "================================"
apt install -y ca-certificates curl gnupg lsb-release

echo "================================"
echo "[4/4] 安装 Docker..."
echo "================================"

# 添加 Docker 官方 GPG 密钥
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# 设置 Docker 仓库
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装 Docker
apt update -y
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 启动 Docker
systemctl start docker
systemctl enable docker

echo ""
echo "[完成] Docker 安装完成"
echo "================================"
echo "Docker 版本: $(docker --version)"
echo "Docker Compose 版本: $(docker compose version)"
echo "================================"
echo "常用命令:"
echo "  docker ps              - 查看运行中的容器"
echo "  docker images          - 查看镜像列表"
echo "  docker compose up -d   - 启动容器编排"
echo "================================"
echo ""
```

}

# 6. 流媒体解锁测试

test_streaming() {
echo “================================”
echo “[1/2] 准备流媒体解锁测试工具…”
echo “================================”

```
apt install -y curl wget

echo "================================"
echo "[2/2] 开始流媒体解锁测试..."
echo "================================"
echo ""

# 使用 RegionRestrictionCheck 脚本
echo "[测试] 正在检测流媒体解锁情况..."
echo "================================"
bash <(curl -L -s check.unlock.media)

echo ""
echo "================================"
echo "[完成] 流媒体解锁测试完成"
echo "================================"
echo ""
```

}

# 7. 三网回程路由测试

test_route() {
echo “================================”
echo “[1/2] 准备三网回程测试工具…”
echo “================================”

```
apt install -y curl wget traceroute mtr

echo "================================"
echo "[2/2] 开始三网回程路由测试..."
echo "================================"
echo ""

# 使用 Nexttrace 进行回程测试
echo "[测试] 正在测试三网回程路由..."
echo "================================"

# 安装 nexttrace
if ! command -v nexttrace &> /dev/null; then
    echo "[安装] 正在安装 NextTrace 工具..."
    curl -sSL https://raw.githubusercontent.com/sjlleo/nexttrace/main/nt_install.sh | bash
fi

echo ""
echo "[测试] 开始测试回程路由..."
echo "================================"

# 使用 AutoTrace 自动测试三网
bash <(curl -Ls https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh)

echo ""
echo "================================"
echo "[完成] 三网回程测试完成"
echo "================================"
echo ""
```

}

# 8. 一键安装全部 (XrayR方案)

install_all_xrayr() {
echo “================================”
echo “开始一键安装 (更新+BBR+XrayR)”
echo “================================”
sleep 2

```
update_system
enable_bbr
install_xrayr

echo "================================"
echo "全部安装完成！"
echo "================================"
echo "已安装组件:"
echo "  ✓ 系统更新"
echo "  ✓ BBR 加速"
echo "  ✓ XrayR"
echo "================================"
echo "重要提示:"
echo "  1. 编辑配置: nano /etc/XrayR/config.yml"
echo "  2. 启动服务: xrayr restart"
echo "  3. 查看状态: xrayr status"
echo "  4. 建议重启系统使 BBR 完全生效"
echo "================================"
echo ""
```

}

# 9. 一键安装全部 (宝塔+Docker方案)

install_all_panel() {
echo “================================”
echo “开始一键安装 (更新+BBR+宝塔+Docker)”
echo “================================”
sleep 2

```
update_system
enable_bbr
install_aapanel
install_docker

echo "================================"
echo "全部安装完成！"
echo "================================"
echo "已安装组件:"
echo "  ✓ 系统更新"
echo "  ✓ BBR 加速"
echo "  ✓ 宝塔面板国际版"
echo "  ✓ Docker"
echo "================================"
echo "重要提示:"
echo "  1. 宝塔面板地址已在上方显示"
echo "  2. 默认面板端口: 8888"
echo "  3. 建议重启系统使 BBR 完全生效"
echo "================================"
echo ""
```

}

# 10. VPS测试套餐

vps_test_suite() {
echo “================================”
echo “VPS 测试套餐”
echo “包含: 更新+BBR+XrayR+流媒体+回程”
echo “================================”
sleep 2

```
# 系统更新
update_system

# 启用BBR
enable_bbr

# 安装XrayR
install_xrayr

echo "================================"
echo "开始进行 VPS 性能测试..."
echo "================================"
sleep 2

# 流媒体解锁测试
test_streaming

# 三网回程测试
test_route

echo "================================"
echo "VPS 测试套餐完成！"
echo "================================"
echo "已完成项目:"
echo "  ✓ 系统更新"
echo "  ✓ BBR 加速"
echo "  ✓ XrayR 安装"
echo "  ✓ 流媒体解锁测试"
echo "  ✓ 三网回程路由测试"
echo "================================"
echo "重要提示:"
echo "  1. 配置 XrayR: nano /etc/XrayR/config.yml"
echo "  2. 启动服务: xrayr restart"
echo "  3. 建议重启系统使 BBR 完全生效"
echo "  4. 测试结果已显示在上方"
echo "================================"
echo ""
```

}

# 主函数

main() {
check_root

```
while true; do
    show_menu
    read -p "请选择操作 [0-10]: " choice
    
    case $choice in
        1)
            update_system
            read -p "按回车键继续..."
            ;;
        2)
            enable_bbr
            read -p "按回车键继续..."
            ;;
        3)
            install_xrayr
            read -p "按回车键继续..."
            ;;
        4)
            install_aapanel
            read -p "按回车键继续..."
            ;;
        5)
            install_docker
            read -p "按回车键继续..."
            ;;
        6)
            test_streaming
            read -p "按回车键继续..."
            ;;
        7)
            test_route
            read -p "按回车键继续..."
            ;;
        8)
            install_all_xrayr
            read -p "按回车键继续..."
            ;;
        9)
            install_all_panel
            read -p "按回车键继续..."
            ;;
        10)
            vps_test_suite
            read -p "按回车键继续..."
            ;;
        0)
            echo "退出脚本"
            exit 0
            ;;
        *)
            echo "[错误] 无效的选择，请重新输入"
            sleep 2
            ;;
    esac
done
```

}

# 运行主函数

main
