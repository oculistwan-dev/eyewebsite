#!/bin/bash
# 完整的自动修复脚本 - 使用 sed 批量替换所有 HTML 文件
# 此脚本会修复所有已识别的本地化和格式问题

SITE_DIR="/Users/livelive/Desktop/eyesite"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "=================================================="
echo "🔧 Eyesite 完整自动修复脚本"
echo "=================================================="
echo ""
echo "开始修复所有 HTML 文件中的问题..."
echo ""

# 计数器
files_processed=0
files_modified=0

# 修复所有 index.html 文件（除了 .bak 备份）
for file in $(find "$SITE_DIR" -name "index.html" -type f ! -name "*.bak"); do
  files_processed=$((files_processed + 1))
  
  # 创建临时文件用于检查是否有修改
  temp_file="${file}.tmp"
  cp "$file" "$temp_file"
  
  # 应用所有修复规则
  # 1. 修复电话按钮文本
  sed -i '' 's/タップして电話する/点击拨打电话/g' "$file"
  
  # 2. 修复接诊时间表标题
  sed -i '' 's/<th>受付时间<\/th>/<th>接诊时间<\/th>/g' "$file"
  
  # 3. 修复医院名称（日文汉字）
  sed -i '' 's/医院概況/医院概况/g' "$file"
  
  # 检查文件是否有修改
  if ! diff -q "$file" "$temp_file" > /dev/null 2>&1; then
    files_modified=$((files_modified + 1))
    rel_path=${file#$SITE_DIR/}
    echo "  ✓ $rel_path"
  fi
  
  # 删除临时文件
  rm -f "$temp_file"
done

echo ""
echo "=================================================="
echo "✅ 修复完成"
echo "=================================================="
echo ""
echo "修复统计:"
echo "  • 处理文件总数: $files_processed"
echo "  • 修改文件数量: $files_modified"
echo ""
echo "修复项目:"
echo "  ✓ タップして电話する -> 点击拨打电话"
echo "  ✓ <th>受付时間</th> -> <th>接診時間</th>"
echo "  ✓ 医院概況 -> 医院概况"
echo ""
echo "=================================================="
echo ""
echo "📝 下一步建议:"
echo ""
echo "1. 验证修复结果"
echo "   python3 -m http.server 8000"
echo ""
echo "2. 查看修改"
echo "   git diff --stat"
echo ""
echo "3. 提交修改"
echo "   git add ."
echo "   git commit -m '🔧 fix: 修复日文/简体中文混用问题'"
echo ""
echo "4. 推送到远程"
echo "   git push origin sync/main-20251201"
echo ""
echo "=================================================="
