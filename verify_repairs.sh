#!/bin/bash
# 修复验证和最终确认脚本
# 用于验证所有修复是否成功完成

SITE_DIR="/Users/livelive/Desktop/eyesite"

echo "=================================================="
echo "🔍 Eyesite 修复验证检查清单"
echo "=================================================="
echo ""

# 检查 1: 扫描是否还有混用的日文
echo "📌 检查 1: 扫描残余的日文字符..."
echo ""

missing_patterns=()

# 模式 1: 日文电话按钮
count=$(grep -r "タップして电話する" "$SITE_DIR" --include="*.html" ! -name "*.bak" 2>/dev/null | wc -l)
if [ "$count" -gt 0 ]; then
  echo "  ⚠️  找到 $count 个 'タップして电話する' (未修复)"
  missing_patterns+=("タップして电話する")
else
  echo "  ✅ 未找到 'タップして电話する' (已修复)"
fi

# 模式 2: 日文接待时间
count=$(grep -r "受付時間" "$SITE_DIR" --include="*.html" ! -name "*.bak" 2>/dev/null | wc -l)
if [ "$count" -gt 0 ]; then
  echo "  ⚠️  找到 $count 个 '受付時間' (未修复)"
  missing_patterns+=("受付時間")
else
  echo "  ✅ 未找到 '受付時間' (已修复)"
fi

# 模式 3: 日文医院概况
count=$(grep -r "医院概況" "$SITE_DIR" --include="*.html" ! -name "*.bak" 2>/dev/null | wc -l)
if [ "$count" -gt 0 ]; then
  echo "  ⚠️  找到 $count 个 '医院概況' (未修复)"
  missing_patterns+=("医院概況")
else
  echo "  ✅ 未找到 '医院概況' (已修复)"
fi

echo ""

# 检查 2: 验证中文替换文本的存在
echo "📌 检查 2: 验证中文替换文本..."
echo ""

# 验证 1: 电话按钮中文
count=$(grep -r "点击拨打电话" "$SITE_DIR" --include="*.html" ! -name "*.bak" 2>/dev/null | wc -l)
echo "  • 找到 $count 个 '点击拨打电话'"

# 验证 2: 接诊时间中文
count=$(grep -r "接診時間" "$SITE_DIR" --include="*.html" ! -name "*.bak" 2>/dev/null | wc -l)
echo "  • 找到 $count 个 '接診時間'"

# 验证 3: 医院概况中文
count=$(grep -r "医院概况" "$SITE_DIR" --include="*.html" ! -name "*.bak" 2>/dev/null | wc -l)
echo "  • 找到 $count 个 '医院概况'"

echo ""

# 检查 3: 统计修改的文件数
echo "📌 检查 3: 统计已修改的文件..."
echo ""

total_files=$(find "$SITE_DIR" -name "index.html" -not -name "*.bak" -type f | wc -l)
echo "  • 总 HTML 文件数 (不含备份): $total_files"

echo ""

# 检查 4: Git 状态
echo "📌 检查 4: Git 修改状态..."
echo ""

# 检查是否在 git 仓库中
if [ -d "$SITE_DIR/.git" ]; then
  cd "$SITE_DIR"
  
  # 检查未提交的修改
  modified_count=$(git status --short --untracked-files=no 2>/dev/null | wc -l)
  
  if [ "$modified_count" -gt 0 ]; then
    echo "  ✅ 检测到 $modified_count 个文件被修改（未提交）"
    echo ""
    echo "  修改文件列表（前 10 个）:"
    git status --short --untracked-files=no 2>/dev/null | head -10 | sed 's/^/    /'
    
    if [ "$modified_count" -gt 10 ]; then
      echo "    ... 以及 $((modified_count - 10)) 个其他文件"
    fi
  else
    echo "  ℹ️  没有检测到未提交的修改"
  fi
else
  echo "  ⚠️  未找到 .git 目录，无法检查 Git 状态"
fi

echo ""
echo "=================================================="
echo "📋 修复完成度检查"
echo "=================================================="
echo ""

if [ ${#missing_patterns[@]} -eq 0 ]; then
  echo "✅ 所有识别的日文/简体混用问题已修复！"
  echo ""
  echo "🎉 建议下一步："
  echo ""
  echo "1. 验证网页显示"
  echo "   python3 -m http.server 8000"
  echo ""
  echo "2. 提交修改"
  echo "   git add ."
  echo "   git commit -m '🔧 fix: 修复日文/简体中文混用问题'"
  echo ""
  echo "3. 推送到远程"
  echo "   git push origin sync/main-20251201"
else
  echo "⚠️  还有 ${#missing_patterns[@]} 个日文模式未修复："
  echo ""
  for pattern in "${missing_patterns[@]}"; do
    echo "   • $pattern"
  done
  echo ""
  echo "💡 运行 auto_fix_complete.sh 来自动修复所有问题："
  echo "   bash auto_fix_complete.sh"
fi

echo ""
echo "=================================================="
