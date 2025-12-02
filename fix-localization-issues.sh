#!/bin/bash
# 修复日文/简体中文混用的脚本
# 统一所有混用文本为简体中文标准术语

SITE_DIR="/Users/livelive/Desktop/eyesite"

echo "🔧 开始修复本地化混用问题..."

# 1. 修复"タップして电话する" 为 "点击拨打电话"
echo "修复: タップして电话する -> 点击拨打电话"
find "$SITE_DIR" -name "index.html" ! -name "*.bak" -type f -exec sed -i '' 's/タップして电话する/点击拨打电话/g' {} \;

# 2. 修复"受付时间" 为 "接诊时间"
echo "修复: 受付时间 -> 接诊时间"
find "$SITE_DIR" -name "index.html" ! -name "*.bak" -type f -exec sed -i '' 's/<th>受付时间<\/th>/<th>接诊时间<\/th>/g' {} \;

# 3. 修复"医院概況" 为 "医院概况"
echo "修复: 医院概況 -> 医院概况"
find "$SITE_DIR" -name "*.html" ! -name "*.bak" -type f -exec sed -i '' 's/医院概況/医院概况/g' {} \;

# 4. 修复"お知らせ" 为 "通知"（在菜单和链接中）
echo "修复: お知らせ -> 通知"
find "$SITE_DIR" -name "*.rss" -type f -exec sed -i '' 's/<title>お知らせ<\/title>/<title>通知<\/title>/g' {} \;
find "$SITE_DIR" -name "*.rss" -type f -exec sed -i '' 's/<title>お盆休みのお知らせ/<title>盆休通知/g' {} \;
find "$SITE_DIR" -name "*.rss" -type f -exec sed -i '' 's/<title>GW休診日のお知らせ/<title>GW休诊通知/g' {} \;

echo "✅ 本地化混用问题修复完成！"
echo ""
echo "修复项目:"
echo "  ✓ タップして电话する -> 点击拨打电话"
echo "  ✓ 受付时间 -> 接诊时间"
echo "  ✓ 医院概況 -> 医院概况"
echo "  ✓ お知らせ -> 通知"
echo ""
