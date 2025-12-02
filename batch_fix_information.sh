#!/bin/bash
# 批量修复 information 目录下所有页面
cd /Users/livelive/Desktop/eyesite

for file in information/*/index.html information/page/*/index.html; do
  if [ -f "$file" ] && [[ "$file" != *".bak" ]]; then
    sed -i '' 's/タップして电話する/点击拨打电话/g' "$file"
    sed -i '' 's/<th>受付时间<\/th>/<th>接诊时间<\/th>/g' "$file"
    echo "修复: $file"
  fi
done

echo "✅ information 目录修复完成"
