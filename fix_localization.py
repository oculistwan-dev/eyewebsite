#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
修复所有 HTML 文件中的日文/简体中文混用问题
"""

import os
import glob

# 定义修复规则
FIXES = {
    'タップして电话する': '点击拨打电话',
    '<th>受付时间</th>': '<th>接诊时间</th>',
    '医院概況': '医院概况',
    'お知らせ': '通知',
}

def fix_file(filepath):
    """修复单个文件"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # 应用所有修复
        for old, new in FIXES.items():
            if old in content:
                content = content.replace(old, new)
                print(f"  ✓ 修复: {old} -> {new}")
        
        # 只有内容有变化时才写入
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        return False
    except Exception as e:
        print(f"  ✗ 错误: {e}")
        return False

def main():
    site_dir = '/Users/livelive/Desktop/eyesite'
    
    print("🔧 开始修复所有 HTML 文件中的本地化问题...\n")
    
    # 修复所有 HTML 文件（除了 .bak 备份）
    html_files = glob.glob(os.path.join(site_dir, '**', 'index.html'), recursive=True)
    html_files = [f for f in html_files if not f.endswith('.bak')]
    
    fixed_count = 0
    processed_count = 0
    
    for filepath in sorted(html_files):
        processed_count += 1
        rel_path = filepath.replace(site_dir + '/', '')
        print(f"处理: {rel_path}")
        
        if fix_file(filepath):
            fixed_count += 1
    
    print(f"\n✅ 完成！")
    print(f"   处理文件数: {processed_count}")
    print(f"   修复文件数: {fixed_count}")
    print(f"\n修复项目:")
    for old, new in FIXES.items():
        print(f"  ✓ {old} -> {new}")

if __name__ == '__main__':
    main()
