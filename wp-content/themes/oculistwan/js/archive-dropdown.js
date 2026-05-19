/**
 * Archive Dropdown Handler
 * 处理归档下拉菜单的导航功能
 */

(function() {
    'use strict';
    
    /**
     * 验证URL是否为有效的HTTP(S)URL
     * @param {string} url - 要验证的URL
     * @returns {boolean} - URL是否有效
     */
    function isValidUrl(url) {
        if (!url) return false;
        try {
            const urlObj = new URL(url);
            return urlObj.protocol === 'http:' || urlObj.protocol === 'https:';
        } catch (e) {
            return false;
        }
    }
    
    /**
     * 初始化所有归档下拉菜单
     */
    function initArchiveDropdowns() {
        const dropdowns = document.querySelectorAll('select[name="archive-dropdown"]');
        
        dropdowns.forEach(function(select) {
            select.addEventListener('change', function() {
                const url = this.value;
                
                // 验证URL有效性
                if (url && isValidUrl(url)) {
                    window.location.href = url;
                } else if (url) {
                    // URL无效时输出警告，不进行导航
                    console.warn('Invalid URL in archive dropdown:', url);
                }
                
                // 重置选择器到默认选项
                this.value = '';
            });
        });
    }
    
    /**
     * 在DOM准备好时初始化
     */
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initArchiveDropdowns);
    } else {
        // DOM已经加载
        initArchiveDropdowns();
    }
})();
