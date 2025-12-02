#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
最终修复验证报告生成脚本
用于验证所有日文/简体混用问题是否已修复
"""

import os
import re
from pathlib import Path
from collections import defaultdict

def scan_html_files(base_dir):
    """扫描所有 HTML 文件"""
    html_files = []
    for root, dirs, files in os.walk(base_dir):
        # 跳过备份和特殊目录
        dirs[:] = [d for d in dirs if d not in ['.git', 'node_modules', '__pycache__']]
        
        for file in files:
            if file == 'index.html' and not file.endswith('.bak'):
                html_files.append(os.path.join(root, file))
    
    return sorted(html_files)

def check_patterns(content):
    """检查混用模式"""
    patterns = {
        'japanese_phone': 'タップして电話する',
        'japanese_time': '受付時間',
        'japanese_overview': '医院概況',
    }
    
    results = {}
    for key, pattern in patterns.items():
        results[key] = pattern in content
    
    return results

def check_fixes(content):
    """检查修复是否已应用"""
    fixes = {
        'chinese_phone': '点击拨打电话',
        'chinese_time': '接诊时间',
        'chinese_overview': '医院概况',
    }
    
    results = {}
    for key, fix_text in fixes.items():
        results[key] = fix_text in content
    
    return results

def main():
    base_dir = '/Users/livelive/Desktop/eyesite'
    
    print("=" * 60)
    print("🔍 Eyesite 修复完整性验证报告")
    print("=" * 60)
    print()
    
    html_files = scan_html_files(base_dir)
    print(f"📋 扫描 HTML 文件: {len(html_files)} 个")
    print()
    
    # 统计
    mixed_files = defaultdict(list)  # 仍有混用的文件
    fixed_files = defaultdict(list)  # 已修复的文件
    total_patterns_found = defaultdict(int)
    total_fixes_found = defaultdict(int)
    
    print("检查进度:")
    print("-" * 60)
    
    for html_file in html_files:
        try:
            with open(html_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            patterns = check_patterns(content)
            fixes = check_fixes(content)
            
            # 记录混用模式
            for key, found in patterns.items():
                if found:
                    mixed_files[key].append(html_file)
                    total_patterns_found[key] += 1
            
            # 记录修复情况
            for key, found in fixes.items():
                if found:
                    fixed_files[key].append(html_file)
                    total_fixes_found[key] += 1
        
        except Exception as e:
            print(f"  ❌ 错误: {html_file}: {str(e)}")
    
    print(f"✅ 成功检查 {len(html_files)} 个文件")
    print()
    
    # 生成报告
    print("=" * 60)
    print("📊 修复验证结果")
    print("=" * 60)
    print()
    
    # 检查日文残余
    print("🔴 日文/简体混用检查 (应为 0):")
    print("-" * 60)
    
    total_remaining = 0
    for key, files in mixed_files.items():
        count = len(files)
        total_remaining += count
        status = "❌" if count > 0 else "✅"
        print(f"{status} {key}: {count} 个文件")
        if count > 0 and count <= 5:
            for f in files[:5]:
                rel_path = f.replace(base_dir, '')
                print(f"     • {rel_path}")
    
    print()
    
    # 检查中文替换
    print("🟢 中文替换验证:")
    print("-" * 60)
    
    for key, files in fixed_files.items():
        count = len(files)
        status = "✅" if count > 0 else "❓"
        print(f"{status} {key}: {count} 个文件")
    
    print()
    print("=" * 60)
    
    # 总体状态
    if total_remaining == 0:
        print("✅ 修复完成！所有日文/简体混用已清除")
        print()
        print("建议后续步骤:")
        print("  1. git add .")
        print("  2. git commit -m '🔧 fix: 修复日文/简体中文混用问题'")
        print("  3. git push origin sync/main-20251201")
        exit_code = 0
    else:
        print(f"⚠️  还有 {total_remaining} 个混用问题需要处理")
        print()
        print("建议:")
        print("  运行: bash auto_fix_complete.sh")
        exit_code = 1
    
    print()
    print("=" * 60)
    print()
    
    return exit_code

if __name__ == '__main__':
    exit(main())
