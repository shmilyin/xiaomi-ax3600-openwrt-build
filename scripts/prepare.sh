###
# @Author: zhkong
# @Date: 2023-07-25 17:07:02
 # @LastEditors: zhkong
 # @LastEditTime: 2023-08-29 17:50:45
 # @FilePath: /xiaomi-ax3600-openwrt-build/scripts/prepare.sh
###

git clone https://github.com/AgustinLorenzo/openwrt.git -b main --single-branch openwrt --depth 1
cd openwrt

# sed -i '$a src-git NueXini_Packages https://github.com/NueXini/NueXini_Packages.git' feeds.conf.default
sed -i '$a src-git kiddin9_Packages https://github.com/kiddin9/openwrt-packages.git' feeds.conf.default

# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 添加第三方软件包
## openclash
# git clone https://github.com/vernesong/OpenClash.git --single-branch --depth 1 package/new/luci-openclash
## argon theme
git clone https://github.com/jerrykuku/luci-theme-argon.git --single-branch --depth 1 package/new/luci-theme-argon
## KMS激活
svn export https://github.com/immortalwrt/luci/branches/master/applications/luci-app-vlmcsd package/new/luci-app-vlmcsd
svn export https://github.com/immortalwrt/packages/branches/master/net/vlmcsd package/new/vlmcsd
# edit package/new/luci-app-vlmcsd/Makefile
sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' package/new/luci-app-vlmcsd/Makefile

## mosdns
# git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/new/mosdns
# git clone https://github.com/sbwml/v2ray-geodata package/new/v2ray-geodata

# AutoCore
svn export https://github.com/immortalwrt/immortalwrt/branches/master/package/emortal/autocore package/new/autocore
sed -i 's/"getTempInfo" /"getTempInfo", "getCPUBench", "getCPUUsage" /g' package/new/autocore/files/luci-mod-status-autocore.json
sed -i 's/cpu_arch="?"/cpu_arch="ARMv8 Processor rev 4(v8l)"/g' package/new/autocore/files/cpuinfo

rm -rf feeds/luci/modules/luci-base
rm -rf feeds/luci/modules/luci-mod-status
rm -rf feeds/packages/utils/coremark
rm -rf package/emortal/default-settings

svn export https://github.com/immortalwrt/luci/branches/master/modules/luci-base feeds/luci/modules/luci-base
svn export https://github.com/immortalwrt/luci/branches/master/modules/luci-mod-status feeds/luci/modules/luci-mod-status
svn export https://github.com/immortalwrt/packages/branches/master/utils/coremark package/new/coremark
# cp -r ../package/coremark package/new/
svn export https://github.com/immortalwrt/immortalwrt/branches/master/package/emortal/default-settings package/emortal/default-settings
# svn export https://github.com/immortalwrt/immortalwrt/branches/openwrt-23.05/package/utils/mhz package/utils/mhz

# fix luci-theme-argon css
bash ../scripts/fix-argon.sh

# 增加 oh-my-zsh
#bash ../scripts/preset-terminal-tools.sh

# config file
cp ../config/new-config .config
sed -i '$a CONFIG_PACKAGE_luci-app-openclash=y' .config
sed -i '$a CONFIG_PACKAGE_luci-app-wireguard=y' .config
sed -i '$a CONFIG_PACKAGE_luci-i18n-wireguard-zh-cn=y' .config
sed -i '$a CONFIG_PACKAGE_luci-app-smartdns=y' .config
sed -i '$a CONFIG_PACKAGE_luci-i18n-smartdns-zh-cn=y' .config
make defconfig

# 编译固件
make download -j$(nproc)
make -j$(nproc) || make -j1 V=s
