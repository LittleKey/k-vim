#!/bin/bash

# 遇到错误立即停止
set -e

# 获取当前脚本所在目录的绝对路径
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.config/nvim"
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)

echo "================================================="
echo "   Neovim Configuration Installer (Lazy.nvim)    "
echo "================================================="
echo "Source: $BASEDIR"
echo "Target: $TARGET_DIR"
echo "================================================="

# 0. 检查必要依赖
if ! command -v nvim &> /dev/null; then
    echo "Error: Neovim (nvim) is not installed."
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "Error: Git is not installed (required for Lazy.nvim)."
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "Error: python3 is not installed (required for CSpell config generation)."
    exit 1
fi

# 1. 备份现有配置
echo "[Step 1] Checking existing configuration..."

# 确保 .config 目录存在
mkdir -p "$HOME/.config"

if [ -L "$TARGET_DIR" ]; then
    # 如果已经是软链接
    CURRENT_LINK=$(readlink "$TARGET_DIR")
    if [ "$CURRENT_LINK" == "$BASEDIR" ]; then
        echo "  -> Symlink already points to the correct directory. Skipping backup."
    else
        echo "  -> Symlink exists but points to $CURRENT_LINK."
        echo "  -> Unlinking..."
        unlink "$TARGET_DIR"
    fi
elif [ -d "$TARGET_DIR" ]; then
    # 如果是真实目录，则备份
    echo "  -> Detected existing directory. Backing up to $TARGET_DIR.$BACKUP_DATE"
    mv "$TARGET_DIR" "$TARGET_DIR.$BACKUP_DATE"
fi

# 2. 创建软链接
echo "[Step 2] Creating symlink..."
if [ ! -e "$TARGET_DIR" ]; then
    ln -s "$BASEDIR" "$TARGET_DIR"
    echo "  -> Linked $BASEDIR to $TARGET_DIR"
else
    echo "  -> Target already exists (verified in Step 1)."
fi

# 2.5 生成 CSpell 配置 (新增步骤)
echo "[Step 2.5] Generating CSpell configuration..."

# 切换到 BASEDIR 确保相对路径正确
cd "$BASEDIR"

# 检查生成脚本是否存在 (虽然后缀是json，但你是用python3执行的)
if [ -f "spell/cspell.json" ]; then
    echo "  -> Found generator script: spell/cspell.json"
    
    # 执行生成命令
    if python3 spell/cspell.json; then
        echo "  -> Python script executed successfully."
        
        # 检查生成结果并移动
        if [ -f "cspell.json" ]; then
            # 确保 ./spell 目录存在
            mkdir -p ./spell/
            mv cspell.json ./spell/
            echo "  -> Moved generated cspell.json to ./spell/"
        else
            echo "  -> Warning: Python script ran, but 'cspell.json' was not found in the root."
        end
    else
        echo "  -> Error: Failed to execute python script."
        exit 1
    fi
else
    echo "  -> Warning: 'spell/cspell.json' not found. Skipping generation."
fi

# 3. 初始化 Lazy.nvim 插件
echo "[Step 3] Bootstrapping Lazy.nvim and plugins..."
echo "  -> Running Neovim in headless mode to sync plugins..."

# 使用 headless 模式触发 Lazy 的安装和更新
# "+Lazy! sync" 会安装所有缺失的插件并更新现有插件
# "+qa" 会在完成后退出
nvim --headless "+Lazy! sync" +qa

echo "================================================="
echo "   Installation Completed Successfully!          "
echo "================================================="
