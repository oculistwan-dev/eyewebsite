#!/bin/bash

# 增强版网站性能优化脚本
# 优化图片、代码和网站加载速度

set -e  # 遇到错误立即退出

# 配置变量
SCRIPT_NAME="网站性能优化工具"
WEBSITE_ROOT="$(pwd)"
IMAGES_DIR="wp-content/themes/oculistwan/images"
UPLOADS_DIR="wp-content/uploads"
THEME_DIR="wp-content/themes/oculistwan"
JS_DIR="$THEME_DIR/js"
CSS_DIR="$THEME_DIR/css"
BACKUP_DIR="optimized_backup_$(date +%Y%m%d_%H%M%S)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 函数：打印带颜色的消息
echo_color() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

# 函数：检查命令是否存在
check_command() {
    command -v "$1" >/dev/null 2>&1 || {
        echo_color $RED "错误: 需要命令 '$1'，但未安装。"
        if [[ "$1" == "cwebp" ]]; then
            echo_color $YELLOW "提示: 使用 'brew install webp' 安装cwebp"
        elif [[ "$1" == "optipng" ]]; then
            echo_color $YELLOW "提示: 使用 'brew install optipng' 安装optipng"
        elif [[ "$1" == "jpegoptim" ]]; then
            echo_color $YELLOW "提示: 使用 'brew install jpegoptim' 安装jpegoptim"
        fi
        exit 1
    }
}

# 函数：显示进度条
show_progress() {
    local progress="$1"
    local total="$2"
    local bar_length=50
    local filled_length=$((progress * bar_length / total))
    local bar="$(printf '█%.0s' $(seq 1 $filled_length))$(printf ' %.0s' $(seq 1 $((bar_length - filled_length))))"
    printf "\r进度: [%s] %d%%" "$bar" $((progress * 100 / total))
}

# 函数：优化单个图片
optimize_image() {
    local file="$1"
    local file_ext="${file##*.}"
    local file_ext_lower="$(echo "$file_ext" | tr '[:upper:]' '[:lower:]')"
    
    case "$file_ext_lower" in
        jpg|jpeg)
            if [[ -f "${file%.jpg}.webp" ]] && [[ -f "${file%.jpeg}.webp" ]]; then
                # WebP已经存在，只优化JPG
                jpegoptim --strip-all --max=85 "$file" >/dev/null
            else
                # 优化JPG并转换为WebP
                jpegoptim --strip-all --max=85 "$file" >/dev/null
                cwebp -q 85 "$file" -o "${file%.*}.webp"
            fi
            ;;
        png)
            # 优化PNG
            optipng -o2 "$file" >/dev/null
            ;;
    esac
}

# 开始优化
echo_color $GREEN "🚀 ${SCRIPT_NAME} 开始运行..."
echo_color $BLUE "工作目录: $WEBSITE_ROOT"

# 1. 检查必要的工具
echo_color $BLUE "\n🔍 检查必要的工具..."
check_command cwebp
check_command optipng
check_command jpegoptim
check_command find
echo_color $GREEN "✓ 所有必要工具已安装"

# 2. 创建备份目录
echo_color $BLUE "\n💾 创建备份目录..."
mkdir -p "$BACKUP_DIR"
echo_color $GREEN "✓ 备份目录已创建: $BACKUP_DIR"

# 3. 图片优化
echo_color $BLUE "\n📸 开始图片优化..."

# 收集所有需要优化的图片
IMAGE_FILES=()
while IFS= read -r -d '' file; do
    IMAGE_FILES+=("$file")
done < <(find "$IMAGES_DIR" "$UPLOADS_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) -print0)

TOTAL_IMAGES=${#IMAGE_FILES[@]}
if [[ $TOTAL_IMAGES -eq 0 ]]; then
    echo_color $YELLOW "⚠️  未找到需要优化的图片"
else
    echo_color $BLUE "发现 $TOTAL_IMAGES 张图片需要优化"
    
    # 备份原始图片
echo_color $BLUE "正在备份图片..."
    for file in "${IMAGE_FILES[@]}"; do
        relative_path="${file#$WEBSITE_ROOT/}"
        backup_path="$BACKUP_DIR/$relative_path"
        mkdir -p "$(dirname "$backup_path")"
        cp "$file" "$backup_path"
    done
    
    # 优化图片
    count=0
    for file in "${IMAGE_FILES[@]}"; do
        ((count++))
        optimize_image "$file"
        show_progress $count $TOTAL_IMAGES
    done
    echo -e "\n"
    echo_color $GREEN "✓ 图片优化完成"
    
    # 统计WebP图片
echo_color $BLUE "\n📊 WebP图片统计:"
    WEBP_COUNT=$(find "$IMAGES_DIR" "$UPLOADS_DIR" -name "*.webp" | wc -l)
    echo_color $GREEN "已生成 $WEBP_COUNT 张WebP格式图片"
fi

# 4. 优化HTML文件
echo_color $BLUE "\n📄 优化HTML文件..."

# 收集所有HTML文件
HTML_FILES=()
while IFS= read -r -d '' file; do
    HTML_FILES+=($file)
done < <(find . -type f -name "*.html" -print0)

if [[ ${#HTML_FILES[@]} -eq 0 ]]; then
    echo_color $YELLOW "⚠️  未找到HTML文件"
else
    # 备份HTML文件
echo_color $BLUE "正在备份HTML文件..."
    for file in "${HTML_FILES[@]}"; do
        relative_path="${file#$WEBSITE_ROOT/}"
        backup_path="$BACKUP_DIR/$relative_path"
        mkdir -p "$(dirname "$backup_path")"
        cp "$file" "$backup_path"
    done
    
    # 优化HTML：移除不必要的API引用
echo_color $BLUE "移除不必要的WordPress API引用..."
    for file in "${HTML_FILES[@]}"; do
        sed -i '' '/api\.w\.org/d' "$file"
        sed -i '' '/wp-json/d' "$file"
        sed -i '' '/oembed/d' "$file"
    done
    
    # 修复CSS链接
echo_color $BLUE "修复CSS链接..."
    for file in "${HTML_FILES[@]}"; do
        sed -i '' 's/style\.min\.js?ver=6\.1\.1\.css/style.min.css?ver=6.1.1/g' "$file"
        sed -i '' 's/classic-themes\.min\.js?ver=1\.css/classic-themes.min.css?ver=1/g' "$file"
    done
    
    echo_color $GREEN "✓ HTML文件优化完成"
fi

# 5. 优化CSS文件
echo_color $BLUE "\n🎨 优化CSS文件..."

# 检查并使用优化的CSS文件
if [[ -f "optimized-style.css" ]]; then
    echo_color $BLUE "应用优化的CSS文件..."
    cp -f "optimized-style.css" "$CSS_DIR/style.min.css"
    echo_color $GREEN "✓ CSS文件已更新"
else
    echo_color $YELLOW "⚠️  未找到优化的CSS文件"
fi

# 6. 优化JavaScript文件
echo_color $BLUE "\n⚡ 优化JavaScript文件..."

# 检查并使用优化的JS文件
if [[ -f "optimized-libs.js" ]]; then
    echo_color $BLUE "应用优化的JavaScript文件..."
    cp -f "optimized-libs.js" "$JS_DIR/libs.js"
    echo_color $GREEN "✓ JavaScript文件已更新"
else
    echo_color $YELLOW "⚠️  未找到优化的JavaScript文件"
fi

# 7. 创建或更新.htaccess文件
echo_color $BLUE "\n🛠️  创建/更新.htaccess文件..."

cat > .htaccess << 'EOF'
# 增强版缓存和压缩配置
# 启用Gzip压缩
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/plain
    AddOutputFilterByType DEFLATE text/html
    AddOutputFilterByType DEFLATE text/xml
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE application/xml
    AddOutputFilterByType DEFLATE application/xhtml+xml
    AddOutputFilterByType DEFLATE application/rss+xml
    AddOutputFilterByType DEFLATE application/javascript
    AddOutputFilterByType DEFLATE application/x-javascript
    AddOutputFilterByType DEFLATE application/json
    AddOutputFilterByType DEFLATE application/font-woff
    AddOutputFilterByType DEFLATE image/svg+xml
</IfModule>

# 设置缓存控制
<IfModule mod_expires.c>
    ExpiresActive on
    # 文件缓存时间
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/webp "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
    ExpiresByType image/svg+xml "access plus 1 year"
    ExpiresByType application/font-woff "access plus 1 year"
    # 动态内容不缓存
    ExpiresByType text/html "access plus 0 seconds"
    ExpiresByType application/json "access plus 0 seconds"
</IfModule>

# 文件类型检测
<IfModule mod_mime.c>
    AddType image/webp .webp
</IfModule>

# WebP图片重定向
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{HTTP_ACCEPT} image/webp
    RewriteCond %{DOCUMENT_ROOT}/$1.webp -f
    RewriteRule ^(.*)\.(jpe?g|png)$ $1.webp [T=image/webp,E=accept:1]
</IfModule>

# 设置Etag
FileETag MTime Size

# 优化文件处理
<IfModule mod_negotiation.c>
    Options -MultiViews
</IfModule>

# 防爬虫过度抓取
<IfModule mod_setenvif.c>
    SetEnvIfNoCase User-Agent .*bot.* robots
    SetEnvIfNoCase User-Agent .*spider.* robots
    SetEnvIfNoCase User-Agent .*crawler.* robots
    <FilesMatch "\.(php|html|xml)$">
        Order Deny,Allow
        Deny from env=robots
        Allow from all
    </FilesMatch>
</IfModule>
EOF

echo_color $GREEN "✓ .htaccess文件已创建/更新"

# 8. 清理不必要的文件
echo_color $BLUE "\n🧹 清理不必要的文件..."

# 删除临时文件
find . -name "*.tmp" -delete 2>/dev/null || echo_color $YELLOW "⚠️  没有找到临时文件"

# 删除备份文件
find . -name "*.backup" -delete 2>/dev/null || echo_color $YELLOW "⚠️  没有找到备份文件"

# 9. 显示优化摘要
echo_color $GREEN "\n✅ ${SCRIPT_NAME} 执行完成!"

# 显示优化结果统计
echo_color $BLUE "\n📊 优化摘要报告"

# 计算节省的空间
echo_color $BLUE "\n空间节省情况:"
if [[ $TOTAL_IMAGES -gt 0 ]]; then
    ORIGINAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
    NEW_SIZE=$(du -sh "$IMAGES_DIR" "$UPLOADS_DIR" | awk '{sum+=$1} END {print sum}')
    echo_color $GREEN "原始大小: $ORIGINAL_SIZE"
    echo_color $GREEN "优化后大小: $NEW_SIZE"
fi

# 显示WebP数量
echo_color $BLUE "\nWebP转换情况:"
echo_color $GREEN "已转换WebP图片: $WEBP_COUNT 张"

# 显示HTML文件数量
echo_color $BLUE "\nHTML文件处理情况:"
echo_color $GREEN "优化HTML文件: ${#HTML_FILES[@]} 个"

# 提示下一步操作
echo_color $YELLOW "\n💡 下一步建议:"
echo_color $YELLOW "1. 测试网站加载速度和功能完整性"
echo_color $YELLOW "2. 对于大图片，考虑使用响应式图片策略"
echo_color $YELLOW "3. 考虑使用CDN加速静态资源加载"
echo_color $YELLOW "4. 定期运行此脚本保持网站性能"
echo_color $BLUE "\n✨ 祝您的网站访问顺畅！✨"

# 脚本结束