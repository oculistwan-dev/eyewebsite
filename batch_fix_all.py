#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
批量修复所有 HTML 文件中的日文/简体中文混用问题
自动遍历所有非备份的 index.html 文件
"""

import os

def fix_all_html_files():
    """修复所有 HTML 文件"""
    site_dir = '/Users/livelive/Desktop/eyesite'
    
    # 定义修复规则
    fixes = {
        'タップして电話する': '点击拨打电话',
        '<th>受付时间</th>': '<th>接诊时间</th>',
        '医院概況': '医院概况',
    }
    
    print("🔧 开始批量修复所有 HTML 文件...\n")
    
    fixed_count = 0
    total_count = 0
    
    # 递归遍历所有目录
    for root, dirs, files in os.walk(site_dir):
        for file in files:
            if file == 'index.html' and not root.endswith('.bak'):
                filepath = os.path.join(root, file)
                total_count += 1
                rel_path = filepath.replace(site_dir + '/', '')
                
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    original_content = content
                    
                    # 应用所有修复
                    for old, new in fixes.items():
                        if old in content:
                            content = content.replace(old, new)
                    
                    # 只有内容有变化时才写入
                    if content != original_content:
                        with open(filepath, 'w', encoding='utf-8') as f:
                            f.write(content)
                        fixed_count += 1
                        print(f"✓ {rel_path}")
                    
                except Exception as e:
                    print(f"✗ {rel_path}: {e}")
    
    print(f"\n✅ 完成！")
    print(f"   总处理: {total_count} 个文件")
    print(f"   已修复: {fixed_count} 个文件")
    print(f"\n修复项目:")
    for old, new in fixes.items():
        print(f"  • {old} -> {new}")

if __name__ == '__main__':
    fix_all_html_files()
