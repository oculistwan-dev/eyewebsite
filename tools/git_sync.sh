#!/bin/bash

# eyesite Git Sync Script
# 一键提交和推送所有本地变更到远程仓库
# 用法: bash tools/git_sync.sh [branch_name]
# 默认在 main 分支提交推送；如果想创建新分支，传入分支名

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

echo "=========================================="
echo "  eyesite Git Sync Tool"
echo "=========================================="
echo ""

# 检查 git 是否可用
if ! command -v git &> /dev/null; then
    echo "❌ 错误：git 未找到。请先安装 git："
    echo "   brew install git"
    exit 1
fi

# 显示当前状态
echo "📍 当前目录：$REPO_ROOT"
echo "📍 Git 版本：$(git --version)"
echo ""

# 检查是否在 git 仓库里
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ 错误：不是 git 仓库目录"
    exit 1
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "📍 当前分支：$CURRENT_BRANCH"
echo ""

# 可选：如果指定了新分支名，则创建并切换
if [[ -n "$1" ]]; then
    NEW_BRANCH="$1"
    echo "🔀 创建并切换到新分支：$NEW_BRANCH"
    git checkout -b "$NEW_BRANCH" || git checkout "$NEW_BRANCH"
    CURRENT_BRANCH="$NEW_BRANCH"
    echo ""
fi

# 显示待提交的文件（dry-run）
echo "📋 待提交的变更："
git add --dry-run -A | head -20
if [[ $(git add --dry-run -A | wc -l) -gt 20 ]]; then
    echo "   ... 及更多文件"
fi
echo ""

# 询问确认
read -p "确认提交并推送？(y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 已取消"
    exit 0
fi

# 暂存所有变更
echo "📦 暂存所有文件..."
git add -A
echo "✓ 暂存完成"

# 创建提交
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
COMMIT_MSG="chore: sync local changes (${TS})"
echo "💾 创建提交：$COMMIT_MSG"
if git commit -m "$COMMIT_MSG"; then
    echo "✓ 提交成功"
else
    echo "⚠️  没有新的变更需要提交"
fi

# 推送到远程
echo ""
echo "📤 推送到远程 origin/$CURRENT_BRANCH..."
if git push -u origin "$CURRENT_BRANCH"; then
    echo "✓ 推送成功"
    echo ""
    echo "=========================================="
    echo "  ✅ 同步完成！"
    echo "=========================================="
    echo "远程分支：origin/$CURRENT_BRANCH"
    git log --oneline -1
else
    echo "❌ 推送失败"
    echo "   可能原因：分支受保护、无权限、或网络问题"
    echo "   请检查并重试"
    exit 1
fi
