#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
完整的自动修复脚本
修复 eyesite 中所有已识别的 bug
"""

import os
import re

def fix_all_files():
    """修复所有 HTML 文件中的问题"""
    
    site_dir = '/Users/livelive/Desktop/eyesite'
    
    # 定义所有修复规则
    fixes = {
        # 电话按钮文本
        'タップして电話する': '点击拨打电话',
        # 接诊时间
        '<th>受付时间</th>': '<th>接诊时间</th>',
        # 医院概况
        '医院概況': '医院概况',
    }
    
    stats = {
        'total_files': 0,
        'modified_files': 0,
        'errors': 0,
        'fixes_applied': {}
    }
    
    # 初始化统计
    for fix_key in fixes:
        stats['fixes_applied'][fix_key] = 0
    
    print("=" * 60)
    print("🔧 Eyesite 自动修复工具")
    print("=" * 60)
    print("\n开始修复所有 HTML 文件中的本地化问题...\n")
    
    # 递归遍历所有目录
    for root, dirs, files in os.walk(site_dir):
        for file in files:
            # 仅处理 index.html 且不是备份文件
            if file == 'index.html' and not root.endswith('.bak'):
                filepath = os.path.join(root, file)
                stats['total_files'] += 1
                rel_path = filepath.replace(site_dir + '/', '')
                
                try:
                    # 读取文件
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    original_content = content
                    
                    # 应用所有修复
                    for old, new in fixes.items():
                        if old in content:
                            count = content.count(old)
                            content = content.replace(old, new)
                            stats['fixes_applied'][old] += count
                    
                    # 只有内容有变化时才写入
                    if content != original_content:
                        with open(filepath, 'w', encoding='utf-8') as f:
                            f.write(content)
                        stats['modified_files'] += 1
                        print(f"  ✓ {rel_path}")
                    
                except Exception as e:
                    stats['errors'] += 1
                    print(f"  ✗ {rel_path}: {e}")
    
    # 打印总结
    print("\n" + "=" * 60)
    print("✅ 修复完成！")
    print("=" * 60)
    print(f"\n统计信息:")
    print(f"  • 处理文件总数: {stats['total_files']}")
    print(f"  • 修改文件数量: {stats['modified_files']}")
    print(f"  • 错误数量: {stats['errors']}")
    
    print(f"\n修复项目详情:")
    for old, count in stats['fixes_applied'].items():
        if count > 0:
            new = fixes[old]
            print(f"  • '{old}' -> '{new}': {count} 处")
    
    print("\n" + "=" * 60)

if __name__ == '__main__':
    fix_all_files()
