#!/bin/bash

# 定义脚本目标路径
TARGET_PATH="/usr/local/bin/xrsetup.sh"

# 检查脚本是否已在目标路径中
if [ "$(realpath "$0")" != "$TARGET_PATH" ]; then
    # 将脚本复制到 /usr/local/bin 并重命名为 xrsetup.sh
    sudo cp "$0" "$TARGET_PATH"
    sudo chmod +x "$TARGET_PATH"
    echo "脚本已移动到 $TARGET_PATH，并赋予执行权限。现在可以直接输入 'xrsetup.sh' 来运行该脚本。"
    exit 0
fi

# 提示用户输入 GitHub 个人访问令牌
read -p "请输入您的 GitHub 个人访问令牌 (PAT): " GITHUB_TOKEN

# 定义 GitHub 配置文件的 URL，请替换为你的实际 GitHub 用户名和仓库名
GITHUB_CONFIG_URL="https://$GITHUB_TOKEN@raw.githubusercontent.com/xxy0op/XrayR-config/main/config.yml"

# 创建目录 /etc/XrayR（如果不存在）
if [ ! -d "/etc/XrayR" ]; then
    sudo mkdir -p "/etc/XrayR"
    echo "创建目录 /etc/XrayR"
fi

# 下载配置文件并替换到 /etc/XrayR/config.yml
echo "正在从 GitHub 下载配置文件..."
curl -H "Authorization: token $GITHUB_TOKEN" -L -o "/etc/XrayR/config.yml" "$GITHUB_CONFIG_URL"

# 检查文件是否下载成功
if [ $? -ne 0 ]; then
    echo "配置文件下载失败，请检查 URL 和令牌是否正确。"
    exit 1
fi

# 交互式输入 NodeID
read -p "请输入第一个 NodeID 值 (上方): " NODE_ID_TOP
read -p "请输入第二个 NodeID 值 (下方): " NODE_ID_BOTTOM

# 使用行号替换指定行的 NodeID 值
sudo sed -i "20s/NodeID: [0-9]*/NodeID: $NODE_ID_TOP/" /etc/XrayR/config.yml
sudo sed -i "85s/NodeID: [0-9]*/NodeID: $NODE_ID_BOTTOM/" /etc/XrayR/config.yml

echo "配置文件中的 NodeID 已替换为 $NODE_ID_TOP（上方，第20行）和 $NODE_ID_BOTTOM（下方，第60行）"

# 重启 XrayR 服务
echo "重启 XrayR 服务以应用新配置..."
sudo systemctl restart XrayR

# 检查服务是否成功重启
if [ $? -eq 0 ]; then
    echo "XrayR 服务已成功重启。"
else
    echo "XrayR 服务重启失败，请检查服务状态。"
    exit 1
fi
