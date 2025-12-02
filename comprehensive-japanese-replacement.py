#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
综合日文/简体中文全站替换脚本
用于遍历整个 eyesite 并用适合中国大陆网民的简体中文替换所有日语
"""

import os
import re
from pathlib import Path
from collections import defaultdict

# 核心替换映射表（日文 -> 简体中文）
REPLACEMENT_MAP = {
    # ========== 医学术语 ==========
    "白内障": "白内障",  # 保持不变（已是正确简体）
    "近視": "近视",
    "近視進行抑制点眼薬": "近视进行抑制眼药水",
    "眼軸長": "眼轴长度",
    "視能訓練士": "视光师",
    "受付時間": "接诊时间",
    "受付終了": "挂号截止",
    "診療": "诊疗",
    "手術": "手术",
    "医療": "医疗",
    "医院概況": "医院概况",
    "専門外来": "专科门诊",
    "コンタクトレンズ": "隐形眼镜",
    "処方": "配镜",
    "症状": "症状",
    "検査": "检查",
    
    # ========== 常见日文短语 ==========
    "タップして电話する": "点击拨打电话",  # 已做过
    "タップしてお问い合わせ": "点击咨询",
    "ホーム": "首页",
    "初めての方へ": "首次就诊指南",
    "当院について": "医院介绍",
    "医師・スタッフ": "医生和团队",
    "医師のご紹介": "医生介绍",
    "スタッフのご紹介": "团队介绍",
    "視能訓練士のご紹介": "视光师介绍",
    "施設・設備": "医疗设施",
    "専門外来の通知": "专科门诊公告",
    "お知らせ": "新闻资讯",
    "お気軽に": "欢迎",
    "ご相談": "咨询",
    "ご来院ください": "欢迎就诊",
    "ご確認ください": "请查看",
    "お預かり": "接收",
    "寄付金": "捐款",
    "ご協力": "配合",
    "患者様": "患者",
    "スタッフ": "员工",
    "一緒に": "一起",
    "働く": "工作",
    "随時募集": "持续招聘",
    "採用情報": "招聘信息",
    "一覧に戻る": "返回列表",
    
    # ========== 网络用语和文言文调整 ==========
    "こんにちは": "您好",
    "ありがとうございました": "感谢您",
    "頂いた": "提供的",
    "様子": "情景",
    "当日の様子": "活动现场",
    "お話します": "介绍",
    "対応いたします": "服务",
    "誠心誠意": "全力",
    "不安や疑問": "疑虑",
    "解消できるよう": "解答",
    "チャリティー": "慈善",
    "イベント": "活动",
    "賛同いただき": "支持",
    "あたたかい": "热心的",
    "申し上げます": "表示感谢",
    "実施しております": "正在进行",
    "行っております": "正在开展",
    "体制を有しております": "配备了系统",
    "有しております": "拥有",
    "努めています": "努力",
    "いただき": "供稿",
    "いたします": "为",
    "となります": "为",
    
    # ========== 时间和日期相关 ==========
    "月": "月",  # 保持不变
    "日": "日",  # 保持不变
    "火午後": "周二下午",
    "午前": "上午",
    "午後": "下午",
    "時間": "小时",
    "前至": "前到达",
    
    # ========== 杂项表述 ==========
    "オンライン": "在线",
    "マイナ保険証": "我的号卡",
    "マイナンバーカード": "国民卡",
    "事前登録": "提前登记",
    "取得・活用": "获取·应用",
    "登録方法等": "注册方法等",
    "詳しくは": "详情请",
    "新ページ": "新页面",
    "ご自身": "您自己",
    "ホームページ": "网站",
    "院内モニタ": "院内屏幕",
    "報告いたします": "报告",
    "後日": "稍后",
    "電子カルテ": "电子病历",
    "情報の共有": "信息共享",
    "サービス": "服务",
    "実施しています": "已实施",
    "質の高い医療": "高质量医疗",
    "質の高い診療": "优质诊疗",
    "体制整備": "体系完善",
    "加算について": "加成说明",
    "推進": "推进",
    "関わる": "相关",
    "遅らせる": "延缓",
    "点眼剤": "眼药",
    "自由診療": "自费项目",
    "扱い": "项目",
    "本薬剤に関して": "关于本眼药",
    "当ホームページ": "本网站",
    "関してお気軽に": "如有疑问欢迎",
    
    # ========== 导航和菜单 ==========
    "メニュー": "菜单",
    "サブメニュー": "子菜单",
    "検索": "搜索",
    "カテゴリー": "分类",
    "タグ": "标签",
    "アーカイブ": "归档",
    "サイト": "网站",
    "ページ": "页面",
}

# 额外的高级替换规则（正则表达式）
REGEX_REPLACEMENTS = [
    # 处理复合表述
    (r"お(\w+)いただき", r"感谢\1"),
    (r"(\w+)いたします", r"为\1"),
    (r"ご(\w+)ください", r"请\1"),
    (r"(\w+)です", r"\1"),
    (r"(\w+)します", r"进行\1"),
]

def find_all_html_files(base_dir):
    """找到所有 HTML 文件（跳过备份）"""
    html_files = []
    for root, dirs, files in os.walk(base_dir):
        # 跳过不必要的目录
        dirs[:] = [d for d in dirs if d not in ['.git', '__pycache__', '.bak', 'node_modules']]
        
        for file in files:
            if file == 'index.html' and not file.endswith('.bak'):
                html_files.append(os.path.join(root, file))
    
    return sorted(html_files)

def apply_replacements(content, replacement_map):
    """应用所有替换规则"""
    # 首先应用精确替换（保留原始文本中的大小写格式）
    for japanese, simplified in replacement_map.items():
        content = content.replace(japanese, simplified)
    
    return content

def process_html_files(base_dir, dry_run=False):
    """处理所有 HTML 文件"""
    html_files = find_all_html_files(base_dir)
    
    stats = {
        'total_files': len(html_files),
        'modified_files': 0,
        'replacements_made': defaultdict(int),
        'errors': []
    }
    
    print(f"🔍 扫描 HTML 文件: {len(html_files)} 个")
    print("=" * 70)
    
    for html_file in html_files:
        try:
            with open(html_file, 'r', encoding='utf-8') as f:
                original_content = f.read()
            
            # 应用替换
            modified_content = apply_replacements(original_content, REPLACEMENT_MAP)
            
            # 检查是否有更改
            if original_content != modified_content:
                stats['modified_files'] += 1
                
                # 统计替换
                for japanese, simplified in REPLACEMENT_MAP.items():
                    count = original_content.count(japanese)
                    if count > 0:
                        stats['replacements_made'][f"{japanese} -> {simplified}"] += count
                
                if not dry_run:
                    with open(html_file, 'w', encoding='utf-8') as f:
                        f.write(modified_content)
                    
                    rel_path = html_file.replace(base_dir, '')
                    print(f"✅ {rel_path}")
        
        except Exception as e:
            rel_path = html_file.replace(base_dir, '')
            error_msg = f"❌ {rel_path}: {str(e)}"
            print(error_msg)
            stats['errors'].append(error_msg)
    
    return stats

def generate_report(stats):
    """生成统计报告"""
    print("\n" + "=" * 70)
    print("📊 修复统计报告")
    print("=" * 70)
    
    print(f"\n扫描文件总数: {stats['total_files']}")
    print(f"修改文件数量: {stats['modified_files']}")
    print(f"修改率: {stats['modified_files'] / stats['total_files'] * 100:.1f}%")
    
    if stats['replacements_made']:
        print(f"\n✅ 替换汇总 (前 15 项):")
        sorted_replacements = sorted(
            stats['replacements_made'].items(),
            key=lambda x: x[1],
            reverse=True
        )
        for replacement, count in sorted_replacements[:15]:
            print(f"  • {replacement}: {count} 处")
    
    if stats['errors']:
        print(f"\n❌ 错误 ({len(stats['errors'])} 项):")
        for error in stats['errors'][:5]:
            print(f"  • {error}")
        if len(stats['errors']) > 5:
            print(f"  ... 以及 {len(stats['errors']) - 5} 个其他错误")
    
    print("\n" + "=" * 70)

def main():
    import sys
    
    base_dir = '/Users/livelive/Desktop/eyesite'
    dry_run = '--dry-run' in sys.argv or '-d' in sys.argv
    
    print("=" * 70)
    print("🌍 Eyesite 全站日文替换脚本")
    print("=" * 70)
    print()
    
    if dry_run:
        print("⚠️  运行在【模拟模式】，不会实际修改文件")
        print()
    
    # 处理文件
    stats = process_html_files(base_dir, dry_run=dry_run)
    
    # 生成报告
    generate_report(stats)
    
    if not dry_run:
        print("\n✨ 所有文件已处理完成！")
        print("\n建议后续步骤:")
        print("  1. git status       # 查看修改")
        print("  2. git diff --stat  # 查看统计")
        print("  3. git add .")
        print("  4. git commit -m '🔧 fix: 全站日文替换为简体中文并适配中国网民用语'")
        print("  5. git push origin sync/main-20251201")
    else:
        print("\n💾 如要实际修改，运行: python3 comprehensive-japanese-replacement.py")
    
    print()
    print("=" * 70)
    
    return 0 if not stats['errors'] else 1

if __name__ == '__main__':
    exit(main())
