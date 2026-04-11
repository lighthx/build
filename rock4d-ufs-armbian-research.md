# ROCK 4D Armbian UFS 调研记录

- 调研日期：2026-04-11
- 调研对象：`Radxa ROCK 4D` 在 `Armbian` 中是否有现成的 `UFS` 镜像，以及如果没有，是否可以自行构建

## 结论

截至 **2026-04-11**，`ROCK 4D` 的 Armbian 页面里虽然明确提到了 `UFS ready images`，但 **当前公开下载页和归档目录中没有看到可直接下载的 `ROCK 4D UFS` 专用镜像**。

结合 Armbian 的构建仓库、板级配置和站点发布脚本来看，当前最稳妥的结论是：

- `ROCK 4D` 的 `UFS` 支持已经进入了 Armbian 的构建体系
- Armbian 站点和镜像索引系统也认识 `-ufs` 这种产物
- 但 `ROCK 4D` 目前没有公开发布对应的 `-ufs` 镜像
- 因此，如果目标是“可直接刷进 UFS 的 UFS-ready 镜像”，**目前基本需要自己 build**

## 证据链

### 1. 官方板卡页面提到了 UFS，但下载表没有列出 UFS 变体

官方页面：

- https://www.armbian.com/radxa-rock-4d/

页面中有两类信息同时存在：

- 一类是说明文字，明确提到：
  - `NVME/USB` 安装可用 `sudo armbian-install`
  - `UFS ready images` 需要使用带 `UFS` 扩展的镜像，并通过 `USB Adapter` 或 `rkdeveloptool` 刷写
- 另一类是实际下载表。调研时看到：
  - `Standard support`
  - `Minimal / IOT`
  - `Edge`
  - `Rolling`
  - 这些表格的 `Extensions` 列为空
  - 下载链接只指向普通镜像，比如 `Noble_vendor_minimal`、`Trixie_vendor_minimal`、`Noble_edge_minimal`

也就是说，页面文案说明了 UFS 用法，但页面本身没有公开列出 `ROCK 4D` 的 `UFS` 产物。

### 2. 实际公开归档目录里没有看到 `-ufs` 文件

归档目录：

- https://archive.armbian.com/radxa-rock-4d/archive

调研时可见的文件名包括：

- `Armbian_26.2.1_Radxa-rock-4d_noble_vendor_6.1.115_minimal.img.xz`
- `Armbian_26.2.1_Radxa-rock-4d_trixie_vendor_6.1.115_minimal.img.xz`
- `Armbian_26.2.1_Radxa-rock-4d_noble_edge_6.19.5_minimal.img.xz`

没有看到带以下特征的文件：

- `-ufs.img.xz`
- 文件名中包含 `ufs`
- 与同版本普通镜像并列的 UFS 专用变体

因此，公开可访问的归档目录不能证明 `ROCK 4D` 已发布了 UFS 镜像。

### 3. Armbian build 仓库里确实存在官方 `ufs` 扩展

构建扩展文件：

- https://github.com/armbian/build/blob/main/extensions/ufs.sh

这个扩展做的关键事情有：

- 检查 `sfdisk >= 2.41`
- 把额外镜像后缀设置为 `-ufs`
- 把镜像扇区大小设置为 `4096`

这说明 `UFS` 不是用户自定义 hack，而是 **Armbian 官方 build framework 自带的正式扩展**。

### 4. `ROCK 4D` 板级配置已经包含 UFS 相关支持

板级配置：

- https://github.com/armbian/build/blob/main/config/boards/radxa-rock-4d.conf

从板级配置可以确认：

- 板名就是 `Radxa Rock 4D`
- `KERNEL_TARGET` 包含 `vendor,edge`
- 配置里有针对 `ROCK 4D` 的 U-Boot 调整
- 明确启用了 UFS 相关配置项，例如：
  - `CONFIG_UFS`
  - `CONFIG_UFS_ROCKCHIP`
  - `CONFIG_SPL_UFS_SUPPORT`

这说明 `ROCK 4D` 的 UFS 支持不是停留在文档层，而是已经进入板级构建逻辑。

### 5. Armbian 发布记录明确提到 `ROCK 4D` 的 UFS 支持

发布记录：

- https://github.com/armbian/build/releases

调研时能在发布摘要中看到一条变更，含义是：

- `Rock-4D` 增加了 `Edge` 和带 `UFS support` 的主线 U-Boot

这进一步支持上面的判断：

- `ROCK 4D` 的 UFS 支持已经进入 Armbian 主线开发
- 但“支持已经合入”不等于“站点已经发布了对应镜像”

### 6. 站点生成脚本认识 `UFS` 镜像，但 `ROCK 4D` 没看到发布映射

相关文件：

- https://github.com/armbian/armbian.github.io/blob/main/scripts/generate-armbian-images-json.sh
- https://github.com/armbian/armbian.github.io/blob/main/release-targets/reusable.yml
- https://github.com/armbian/armbian.github.io/blob/main/release-targets/targets-extensions.map

调研得到的关键信息：

- 站点脚本会把 `-ufs` 后缀识别为 `storage="ufs"`
- `release-targets/reusable.yml` 里明确说明 `ufs.img.xz` 是合法的发布文件类型
- 但是 `targets-extensions.map` 里没有看到 `radxa-rock-4d` 对应的 `ENABLE_EXTENSIONS="ufs"` 映射

这说明：

- Armbian 的发布站点体系能够处理 `UFS` 产物
- 但 `ROCK 4D` 当前没有明显配置成“自动公开发布 UFS 镜像”

## 为什么结论是“当前基本要自己 build”

如果同时满足下面三件事，通常就说明官方已经在公开发 UFS 镜像：

1. 板卡页面下载表中能看到 UFS 变体，或 `Extensions` 列明确显示 `UFS`
2. `dl.armbian.com` / `archive.armbian.com` 能看到 `-ufs.img.xz` 文件
3. 站点发布目标里存在该板卡对应的 `ufs` 发布映射

调研时这三项都没有对 `ROCK 4D` 成立。

所以当前最合理的判断是：

- **官方支持 build UFS**
- **官方尚未公开发布 ROCK 4D 的 UFS 镜像**
- **用户若需要 UFS-ready 镜像，当前基本需要自己构建**

## 自建方式

最直接的方式是使用 Armbian 官方 `build` 仓库，加上 `ENABLE_EXTENSIONS=ufs`。

仓库：

- https://github.com/armbian/build

### 例子：Ubuntu 24.04 vendor minimal UFS 镜像

```bash
git clone https://github.com/armbian/build
cd build

./compile.sh build \
BOARD=radxa-rock-4d \
BRANCH=vendor \
RELEASE=noble \
BUILD_MINIMAL=yes \
BUILD_DESKTOP=no \
KERNEL_CONFIGURE=no \
ENABLE_EXTENSIONS=ufs
```

### 可替换组合

- 稳定 Ubuntu Minimal：
  - `BRANCH=vendor RELEASE=noble`
- 稳定 Debian Minimal：
  - `BRANCH=vendor RELEASE=trixie`
- Edge 内核 Ubuntu Minimal：
  - `BRANCH=edge RELEASE=noble`

### 自建时要注意

- `ufs` 扩展要求 `sfdisk >= 2.41`
- 官方 README 推荐的原生主机环境偏向较新的 Ubuntu/Armbian
- 如果本机环境不合适，优先走 Docker 方式构建

Docker 参考文档：

- https://docs.armbian.com/Developer-Guide_Building-with-Docker/

Build switches 文档：

- https://docs.armbian.com/Developer-Guide_Build-Switches/

Extensions 文档：

- https://docs.armbian.com/Developer-Guide_Extensions/

## 刷写方式

`ROCK 4D` 页面给出的方向是：

- 普通镜像安装到 `NVMe/USB` 时可走 `sudo armbian-install`
- `UFS-ready` 镜像应直接刷写到 UFS
- 可通过：
  - `USB Adapter`
  - `rkdeveloptool`
  - Rockchip `Maskrom` 模式

官方页面里的 Rockchip 刷写入口：

- https://docs.armbian.com/User-Guide_Getting-Started/#rockchip

板卡页面：

- https://www.armbian.com/radxa-rock-4d/

## 本次调研的边界

本次调研确认了以下事实：

- 页面文案存在 UFS 说明
- 当前公开下载表没有列出 ROCK 4D UFS 镜像
- 当前公开归档目录没有看到 ROCK 4D UFS 镜像文件
- build 仓库和板级配置已经具备 UFS 支持
- 站点发布系统总体支持 UFS 产物
- 但没有发现 ROCK 4D 已被配置成公开发布 UFS 镜像

本次没有进一步做的事情：

- 没有实际触发一次完整 build
- 没有实际把生成的镜像刷进 ROCK 4D 的 UFS
- 没有验证某个私有镜像索引或 Armbian Imager 内部清单是否存在未公开条目

## 最终判断

截至 **2026-04-11**：

- 如果你只是要 `ROCK 4D` 的普通 Armbian 镜像，直接下载官方页面现有版本即可
- 如果你要的是“可直接刷入 UFS 的 UFS-ready 镜像”，**当前基本需要自己 build**

