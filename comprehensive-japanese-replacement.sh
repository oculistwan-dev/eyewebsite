#!/bin/bash
# 全站日文替换 Bash 脚本（macOS/BSD sed 版本）
# 用适合中国大陆网民的简体中文替换所有日语

SITE_DIR="/Users/livelive/Desktop/eyesite"

if [ ! -d "$SITE_DIR" ]; then
  echo "❌ 目录不存在: $SITE_DIR"
  exit 1
fi

echo "=================================================="
echo "🌍 Eyesite 全站日文替换脚本"
echo "=================================================="
echo ""

# 启用扩展 glob 以支持递归搜索
cd "$SITE_DIR" || exit 1

# 统计变量
total_files=0
modified_files=0

echo "开始替换（跳过 *.bak 文件）..."
echo ""

# 创建临时目录用于备份
BACKUP_DIR="${SITE_DIR}/.replacements_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# 循环所有 index.html 文件（不包括 .bak）
while IFS= read -r file; do
  ((total_files++))
  
  # 创建原始备份
  backup_file="${BACKUP_DIR}/$(basename $(dirname "$file"))_index.html.bak"
  cp "$file" "$backup_file"
  
  # 创建临时文件用于检查是否有改动
  temp_file="${file}.tmp"
  cp "$file" "$temp_file"
  
  # ========== 医学术语 ==========
  sed -i '' 's/近視/近视/g' "$file"
  sed -i '' 's/近視進行抑制点眼薬/近视进行抑制眼药水/g' "$file"
  sed -i '' 's/眼軸長/眼轴长度/g' "$file"
  sed -i '' 's/視能訓練士/视光师/g' "$file"
  sed -i '' 's/受付時間/接诊时间/g' "$file"
  sed -i '' 's/受付終了/挂号截止/g' "$file"
  sed -i '' 's/診療/诊疗/g' "$file"
  sed -i '' 's/手術/手术/g' "$file"
  sed -i '' 's/医療/医疗/g' "$file"
  sed -i '' 's/医院概況/医院概况/g' "$file"
  sed -i '' 's/專門外来/专科门诊/g' "$file"
  sed -i '' 's/コンタクトレンズ/隐形眼镜/g' "$file"
  sed -i '' 's/処方/配镜/g' "$file"
  sed -i '' 's/症状/症状/g' "$file"
  sed -i '' 's/検査/检查/g' "$file"
  
  # ========== 常见日文短语 ==========
  sed -i '' 's/タップして电話する/点击拨打电话/g' "$file"
  sed -i '' 's/タップしてお问い合わせ/点击咨询/g' "$file"
  sed -i '' 's/ホーム/首页/g' "$file"
  sed -i '' 's/初めての方へ/首次就诊指南/g' "$file"
  sed -i '' 's/当院について/医院介绍/g' "$file"
  sed -i '' 's/医師・スタッフ/医生和团队/g' "$file"
  sed -i '' 's/医師のご紹介/医生介绍/g' "$file"
  sed -i '' 's/スタッフのご紹介/团队介绍/g' "$file"
  sed -i '' 's/視能訓練士のご紹介/视光师介绍/g' "$file"
  sed -i '' 's/施設・設備/医疗设施/g' "$file"
  sed -i '' 's/施设・设备/医疗设施/g' "$file"
  sed -i '' 's/專門外来の通知/专科门诊公告/g' "$file"
  sed -i '' 's/専門外来の通知/专科门诊公告/g' "$file"
  sed -i '' 's/お知らせ/新闻资讯/g' "$file"
  sed -i '' 's/お気軽に/欢迎/g' "$file"
  sed -i '' 's/ご相談/咨询/g' "$file"
  sed -i '' 's/ご来院ください/欢迎就诊/g' "$file"
  sed -i '' 's/ご確認ください/请查看/g' "$file"
  sed -i '' 's/お預かり/接收/g' "$file"
  sed -i '' 's/寄付金/捐款/g' "$file"
  sed -i '' 's/ご協力/配合/g' "$file"
  sed -i '' 's/患者様/患者/g' "$file"
  sed -i '' 's/スタッフ/员工/g' "$file"
  sed -i '' 's/一緒に/一起/g' "$file"
  sed -i '' 's/働く/工作/g' "$file"
  sed -i '' 's/随時募集/持续招聘/g' "$file"
  sed -i '' 's/採用情報/招聘信息/g' "$file"
  sed -i '' 's/一覧に戻る/返回列表/g' "$file"
  
  # ========== 网络用语和文言文调整 ==========
  sed -i '' 's/こんにちは/您好/g' "$file"
  sed -i '' 's/ありがとうございました/感谢您/g' "$file"
  sed -i '' 's/様子/情景/g' "$file"
  sed -i '' 's/当日の情景/活动现场/g' "$file"
  sed -i '' 's/お話します/介绍/g' "$file"
  sed -i '' 's/対応いたします/服务/g' "$file"
  sed -i '' 's/誠心誠意/全力/g' "$file"
  sed -i '' 's/不安や疑問/疑虑/g' "$file"
  sed -i '' 's/解消できるよう/解答/g' "$file"
  sed -i '' 's/チャリティー/慈善/g' "$file"
  sed -i '' 's/イベント/活动/g' "$file"
  sed -i '' 's/申し上げます/表示感谢/g' "$file"
  sed -i '' 's/実施しております/正在进行/g' "$file"
  sed -i '' 's/行っております/正在开展/g' "$file"
  sed -i '' 's/体制を有しております/配备了系统/g' "$file"
  sed -i '' 's/有しております/拥有/g' "$file"
  sed -i '' 's/努めています/努力/g' "$file"
  
  # ========== 时间相关 ==========
  sed -i '' 's/火午後/周二下午/g' "$file"
  sed -i '' 's/午前/上午/g' "$file"
  sed -i '' 's/午後/下午/g' "$file"
  sed -i '' 's/時間/小时/g' "$file"
  
  # ========== 杂项 ==========
  sed -i '' 's/オンライン/在线/g' "$file"
  sed -i '' 's/マイナ保険証/我的号卡/g' "$file"
  sed -i '' 's/マイナンバーカード/国民卡/g' "$file"
  sed -i '' 's/事前登録/提前登记/g' "$file"
  sed -i '' 's/取得・活用/获取·应用/g' "$file"
  sed -i '' 's/登録方法等/注册方法等/g' "$file"
  sed -i '' 's/詳しくは/详情请/g' "$file"
  sed -i '' 's/ホームページ/网站/g' "$file"
  sed -i '' 's/院内モニタ/院内屏幕/g' "$file"
  sed -i '' 's/報告いたします/报告/g' "$file"
  sed -i '' 's/後日/稍后/g' "$file"
  sed -i '' 's/電子カルテ/电子病历/g' "$file"
  sed -i '' 's/情報の共有/信息共享/g' "$file"
  sed -i '' 's/サービス/服务/g' "$file"
  sed -i '' 's/実施しています/已实施/g' "$file"
  sed -i '' 's/質の高い医療/高质量医疗/g' "$file"
  sed -i '' 's/質の高い診療/优质诊疗/g' "$file"
  sed -i '' 's/体制整備/体系完善/g' "$file"
  sed -i '' 's/加算について/加成说明/g' "$file"
  sed -i '' 's/推進/推进/g' "$file"
  sed -i '' 's/関わる/相关/g' "$file"
  sed -i '' 's/遅らせる/延缓/g' "$file"
  sed -i '' 's/点眼剤/眼药/g' "$file"
  sed -i '' 's/自由診療/自费项目/g' "$file"
  sed -i '' 's/扱い/项目/g' "$file"
  sed -i '' 's/当ホームページ/本网站/g' "$file"
  sed -i '' 's/メニュー/菜单/g' "$file"
  sed -i '' 's/カテゴリー/分类/g' "$file"
  sed -i '' 's/タグ/标签/g' "$file"
  sed -i '' 's/アーカイブ/归档/g' "$file"
  sed -i '' 's/ページ/页面/g' "$file"
  sed -i '' 's/検索/搜索/g' "$file"
  
  # 检查是否有修改
  if ! diff -q "$file" "$temp_file" > /dev/null 2>&1; then
    ((modified_files++))
    rel_path="${file#$SITE_DIR/}"
    echo "  ✅ $rel_path"
  fi
  
  rm -f "$temp_file"

done < <(find "$SITE_DIR" -name "index.html" -not -name "*.bak" -type f)

echo ""
echo "=================================================="
echo "✅ 替换完成"
echo "=================================================="
echo ""
echo "统计信息:"
echo "  • 处理文件: $total_files"
echo "  • 修改文件: $modified_files"
echo ""
echo "备份位置: $BACKUP_DIR"
echo ""
echo "建议后续步骤:"
echo "  1. git status       # 查看修改"
echo "  2. git diff --stat  # 查看统计"
echo "  3. git add ."
echo "  4. git commit -m '🔧 fix: 全站日文替换为简体中文并适配中国网民用语'"
echo "  5. git push origin sync/main-20251201"
echo ""
echo "=================================================="
