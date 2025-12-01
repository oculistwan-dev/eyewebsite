/**
 * 图片优化脚本
 * 包含懒加载、WebP支持检测、图片压缩等功能
 */

class ImageOptimizer {
    constructor() {
        this.init();
        this.setupLazyLoading();
        this.detectWebPSupport();
        this.optimizeExistingImages();
        this.setupErrorHandling();
        this.trackImageStats();
    }

    init() {
        // 添加CSS样式
        this.loadCSS();
        
        // 设置观察器选项
        this.observerOptions = {
            root: null,
            rootMargin: '50px',
            threshold: 0.1
        };

        // 图片统计
        this.imageStats = {
            total: 0,
            loaded: 0,
            webp: 0,
            compressed: 0,
            errors: 0
        };
    }

    loadCSS() {
        const link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = 'wp-content/themes/oculistwan/css/image-optimization.css';
        document.head.appendChild(link);
    }

    setupLazyLoading() {
        // 检查是否支持Intersection Observer
        if ('IntersectionObserver' in window) {
            this.lazyImageObserver = new IntersectionObserver((entries, observer) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        const img = entry.target;
                        this.loadImage(img);
                        observer.unobserve(img);
                    }
                });
            }, this.observerOptions);

            // 观察所有懒加载图片
            this.observeLazyImages();
        } else {
            // 降级处理：直接加载所有图片
            this.loadAllImages();
        }
    }

    observeLazyImages() {
        const lazyImages = document.querySelectorAll('img[data-src], img.lazy-image');
        lazyImages.forEach(img => {
            this.lazyImageObserver.observe(img);
            this.imageStats.total++;
        });
    }

    loadImage(img) {
        const src = img.dataset.src || img.src;
        const webpSrc = img.dataset.webp;
        
        // 创建新的图片对象进行预加载
        const imageLoader = new Image();
        
        imageLoader.onload = () => {
            // 使用WebP或原图
            img.src = (this.supportsWebP && webpSrc) ? webpSrc : src;
            img.classList.add('loaded');
            img.classList.remove('lazy-image');
            
            this.imageStats.loaded++;
            if (this.supportsWebP && webpSrc) {
                this.imageStats.webp++;
            }
            
            this.updateImageStats();
            this.addImageInfo(img);
        };
        
        imageLoader.onerror = () => {
            this.handleImageError(img);
        };
        
        // 开始加载
        imageLoader.src = (this.supportsWebP && webpSrc) ? webpSrc : src;
    }

    detectWebPSupport() {
        return new Promise((resolve) => {
            const webP = new Image();
            webP.onload = webP.onerror = () => {
                this.supportsWebP = (webP.height === 2);
                document.documentElement.classList.add(this.supportsWebP ? 'webp' : 'no-webp');
                resolve(this.supportsWebP);
            };
            webP.src = 'data:image/webp;base64,UklGRjoAAABXRUJQVlA4IC4AAACyAgCdASoCAAIALmk0mk0iIiIiIgBoSygABc6WWgAA/veff/0PP8bA//LwYAAA';
        });
    }

    optimizeExistingImages() {
        const images = document.querySelectorAll('img:not([data-src]):not(.lazy-image)');
        images.forEach(img => {
            this.addResponsiveWrapper(img);
            this.addImageInfo(img);
            this.imageStats.total++;
        });
    }

    addResponsiveWrapper(img) {
        if (img.parentElement.classList.contains('responsive-image')) {
            return; // 已经包装过了
        }

        const wrapper = document.createElement('div');
        wrapper.className = 'responsive-image';
        
        // 插入包装器
        img.parentNode.insertBefore(wrapper, img);
        wrapper.appendChild(img);
        
        // 添加加载进度条
        const progressBar = document.createElement('div');
        progressBar.className = 'image-loading-progress';
        wrapper.appendChild(progressBar);
    }

    addImageInfo(img) {
        const wrapper = img.closest('.responsive-image');
        if (!wrapper) return;

        // 添加格式信息
        if (img.src.includes('.webp')) {
            wrapper.classList.add('format-webp');
        }

        // 添加尺寸信息
        img.onload = () => {
            const dimensions = document.createElement('div');
            dimensions.className = 'image-dimensions';
            dimensions.textContent = `${img.naturalWidth}×${img.naturalHeight}`;
            wrapper.appendChild(dimensions);
        };
    }

    handleImageError(img) {
        this.imageStats.errors++;
        
        const wrapper = img.closest('.responsive-image') || img.parentElement;
        wrapper.innerHTML = `
            <div class="image-error">
                图片加载失败
                <button class="retry-load" onclick="imageOptimizer.retryLoad('${img.dataset.src || img.src}', this)">
                    重试加载
                </button>
            </div>
        `;
    }

    retryLoad(src, button) {
        const wrapper = button.closest('.responsive-image') || button.parentElement;
        const img = document.createElement('img');
        img.src = src;
        img.className = 'lazy-image';
        
        wrapper.innerHTML = '';
        wrapper.appendChild(img);
        
        this.loadImage(img);
    }

    setupErrorHandling() {
        // 全局图片错误处理
        document.addEventListener('error', (e) => {
            if (e.target.tagName === 'IMG') {
                this.handleImageError(e.target);
            }
        }, true);
    }

    trackImageStats() {
        // 创建统计显示
        const statsDiv = document.createElement('div');
        statsDiv.className = 'image-stats';
        statsDiv.id = 'imageStats';
        document.body.appendChild(statsDiv);

        // 键盘快捷键显示统计
        document.addEventListener('keydown', (e) => {
            if (e.ctrlKey && e.shiftKey && e.key === 'I') {
                this.toggleImageStats();
            }
        });
    }

    updateImageStats() {
        const statsDiv = document.getElementById('imageStats');
        if (statsDiv) {
            statsDiv.innerHTML = `
                <strong>图片统计</strong><br>
                总数: ${this.imageStats.total}<br>
                已加载: ${this.imageStats.loaded}<br>
                WebP: ${this.imageStats.webp}<br>
                错误: ${this.imageStats.errors}<br>
                加载率: ${Math.round((this.imageStats.loaded / this.imageStats.total) * 100)}%
            `;
        }
    }

    toggleImageStats() {
        const statsDiv = document.getElementById('imageStats');
        if (statsDiv) {
            statsDiv.classList.toggle('show');
        }
    }

    loadAllImages() {
        // 降级处理：直接加载所有图片
        const lazyImages = document.querySelectorAll('img[data-src]');
        lazyImages.forEach(img => {
            img.src = img.dataset.src;
            img.classList.add('loaded');
            img.classList.remove('lazy-image');
        });
    }

    // 压缩图片质量（客户端）
    compressImage(file, quality = 0.8, maxWidth = 1920) {
        return new Promise((resolve) => {
            const canvas = document.createElement('canvas');
            const ctx = canvas.getContext('2d');
            const img = new Image();
            
            img.onload = () => {
                // 计算新尺寸
                let { width, height } = img;
                if (width > maxWidth) {
                    height = (height * maxWidth) / width;
                    width = maxWidth;
                }
                
                canvas.width = width;
                canvas.height = height;
                
                // 绘制并压缩
                ctx.drawImage(img, 0, 0, width, height);
                canvas.toBlob(resolve, 'image/jpeg', quality);
            };
            
            img.src = URL.createObjectURL(file);
        });
    }

    // 生成响应式图片srcset
    generateSrcSet(baseSrc, sizes = [480, 768, 1024, 1920]) {
        return sizes.map(size => {
            const ext = baseSrc.split('.').pop();
            const name = baseSrc.replace(`.${ext}`, '');
            return `${name}-${size}w.${ext} ${size}w`;
        }).join(', ');
    }

    // 预加载关键图片
    preloadCriticalImages() {
        const criticalImages = document.querySelectorAll('.critical-image');
        criticalImages.forEach(img => {
            const link = document.createElement('link');
            link.rel = 'preload';
            link.as = 'image';
            link.href = img.src || img.dataset.src;
            document.head.appendChild(link);
        });
    }
}

// 初始化图片优化器
let imageOptimizer; // eslint-disable-line no-unused-vars
document.addEventListener('DOMContentLoaded', () => {
    imageOptimizer = new ImageOptimizer();
});

// 导出给全局使用
window.ImageOptimizer = ImageOptimizer;
