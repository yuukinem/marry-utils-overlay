# marry-utils Gentoo Overlay

这是一个包含各种自定义软件包的 Gentoo overlay。

## 包含的软件包

- dev-libs/astal-io - Astal 核心库
- gui-libs/astal - Astal GTK3 界面组件

## 安装方法

添加此 overlay 到你的 Gentoo 系统：

\`\`\`
eselect repository add marry-utils git https://github.com/你的用户名/marry-utils-overlay.git
emerge --sync marry-utils
\`\`\`

## 使用方法

\`\`\`
emerge --ask dev-libs/astal-io::marry-utils
emerge --ask gui-libs/astal::marry-utils
\`\`\`
# marry-utils-overlay
