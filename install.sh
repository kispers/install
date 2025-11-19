#!/bin/bash
#
# Ubuntu All-in-One Install Script
#

set -e

green() { echo -e "\033[32m$1\033[0m"; }
yellow() { echo -e "\033[33m$1\033[0m"; }
red() { echo -e "\033[31m$1\033[0m"; }

# ---------------------------------------------------------
update_system() {
    green ">>> 更新系统..."
    apt update -y && apt upgrade -y
}

# ---------------------------------------------------------
set_timezone() {
    green ">>> 设置时区：Asia/Shanghai"
    timedatectl set-timezone Asia/Shanghai
}

# ---------------------------------------------------------
enable_bbr() {
    green ">>> 开启 BBR 加速..."
    cat > /etc/sysctl.d/99-bbr.conf <<EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
    sysctl --system
    sysctl net.ipv4.tcp_congestion_control
}

# ---------------------------------------------------------
install_xrayr() {
    green ">>> 安装 XrayR..."
    bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)
}

# ---------------------------------------------------------
install_aapanel() {
    green ">>> 安装宝塔国际版 aaPanel..."
    curl -sSO https://www.aapanel.com/script/install_ubuntu.sh
    bash install_ubuntu.sh
}

# ---------------------------------------------------------
install_docker() {
    green ">>> 安装 Docker..."
    curl -fsSL https://get.docker.com | bash
    systemctl enable docker
    systemctl start docker
}

# ---------------------------------------------------------
streaming_test() {
    green ">>> 流媒体测试..."
    bash <(curl -Ls https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/check.sh)
}

# ---------------------------------------------------------
route_test() {
    green ">>> 三网回程测试..."
    curl -sL https://github.com/soffchen/warp-routing/raw/master/three-route.sh | bash
}

# ---------------------------------------------------------
# 新增功能：一键更新 + BBR + XrayR
# ---------------------------------------------------------
one_click_core() {
    green ">>> 一键执行：系统更新 + BBR + XrayR"
    update_system
    enable_bbr
    install_xrayr
    green ">>> 完成！"
}

# ---------------------------------------------------------
menu() {
    clear
    echo "=================================================="
    echo "   Ubuntu All-in-One"
    echo "   作者：强哥"
    echo "=================================================="
    echo ""
    echo " 1). 更新系统"
    echo " 2). 设置中国上海时区"
    echo " 3). 开启 BBR 加速"
    echo " 4). 安装 XrayR"
    echo " 5). 安装宝塔国际版 aaPanel"
    echo " 6). 安装 Docker"
    echo " 7). 流媒体解锁测试"
    echo " 8). 三网回程测试"
    echo " 9). 一键全部安装（全家桶）"
    echo "10). ⭐ 一键更新 + BBR + XrayR"
    echo " 0). 退出"
    echo ""
    read -p "请输入选项编号：" num

    case $num in
        1) update_system ;;
        2) set_timezone ;;
        3) enable_bbr ;;
        4) install_xrayr ;;
        5) install_aapanel ;;
        6) install_docker ;;
        7) streaming_test ;;
        8) route_test ;;
        9)
            update_system
            set_timezone
            enable_bbr
            install_docker
            install_aapanel
            install_xrayr
            streaming_test
            route_test
        ;;
        10) one_click_core ;;
        0) exit ;;
        *) red "输入错误，请重新输入" ;;
    esac
}

menu
