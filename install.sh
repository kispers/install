#!/bin/bash
#
# Ubuntu All-in-One Install Script (Smart Menu)
#

set -e

green() { echo -e "\033[32m$1\033[0m"; }
yellow() { echo -e "\033[33m$1\033[0m"; }
red() { echo -e "\033[31m$1\033[0m"; }

# 状态标记
SYS_UPDATED=0
TIMEZONE_SET=0
BBR_ENABLED=0
XRAYR_INSTALLED=0
AAPANEL_INSTALLED=0
DOCKER_INSTALLED=0
STREAM_TESTED=0
ROUTE_TESTED=0

update_system() {
    green ">>> 更新系统..."
    apt update -y && apt upgrade -y
    SYS_UPDATED=1
}

set_timezone() {
    green ">>> 设置时区：Asia/Shanghai"
    timedatectl set-timezone Asia/Shanghai
    TIMEZONE_SET=1
}

enable_bbr() {
    green ">>> 开启 BBR 加速..."
    cat > /etc/sysctl.d/99-bbr.conf <<EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
    sysctl --system
    BBR_ENABLED=1
}

install_xrayr() {
    green ">>> 安装 XrayR..."
    bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)
    XRAYR_INSTALLED=1
}

install_aapanel() {
    green ">>> 安装宝塔国际版 aaPanel..."
    wget -O install.sh http://www.aapanel.com/script/install-ubuntu-en.sh && sudo bash install.sh
    bash install_ubuntu.sh
    AAPANEL_INSTALLED=1
}

install_docker() {
    green ">>> 安装 Docker..."
    curl -fsSL https://get.docker.com | bash
    systemctl enable docker
    systemctl start docker
    DOCKER_INSTALLED=1
}

streaming_test() {
    green ">>> 流媒体测试..."
    bash <(curl -Ls https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/check.sh)
    STREAM_TESTED=1
}

route_test() {
    green ">>> 三网回程测试..."
    curl -sL https://github.com/soffchen/warp-routing/raw/master/three-route.sh | bash
    ROUTE_TESTED=1
}

one_click_core() {
    green ">>> 一键执行：系统更新 + BBR + XrayR"
    update_system
    enable_bbr
    install_xrayr
    green ">>> 完成！"
}

# --------------------------
# 菜单状态显示函数
# --------------------------
status_icon() {
    [[ $1 -eq 1 ]] && echo "✅" || echo "❌"
}

# --------------------------
# 循环菜单
# --------------------------
while true; do
    clear
    echo "=================================================="
    echo "   Ubuntu All-in-One 一键脚本 (智能状态菜单)"
    echo "=================================================="
    echo ""
    echo " 1). 更新系统               $(status_icon $SYS_UPDATED)"
    echo " 2). 设置中国上海时区       $(status_icon $TIMEZONE_SET)"
    echo " 3). 开启 BBR 加速          $(status_icon $BBR_ENABLED)"
    echo " 4). 安装 XrayR             $(status_icon $XRAYR_INSTALLED)"
    echo " 5). 安装宝塔国际版 aaPanel $(status_icon $AAPANEL_INSTALLED)"
    echo " 6). 安装 Docker            $(status_icon $DOCKER_INSTALLED)"
    echo " 7). 流媒体解锁测试         $(status_icon $STREAM_TESTED)"
    echo " 8). 三网回程测试           $(status_icon $ROUTE_TESTED)"
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

    echo ""
    read -p "操作完成，按回车返回主菜单..." dummy
done
