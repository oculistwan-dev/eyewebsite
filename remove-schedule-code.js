const fs = require('fs');
const path = require('path');

// 获取所有HTML文件路径
const getAllHtmlFiles = (dir) => {
    let files = [];
    const items = fs.readdirSync(dir, { withFileTypes: true });
    
    for (const item of items) {
        const fullPath = path.join(dir, item.name);
        if (item.isDirectory()) {
            files = [...files, ...getAllHtmlFiles(fullPath)];
        } else if (item.isFile() && path.extname(item.name) === '.html') {
            files.push(fullPath);
        }
    }
    
    return files;
};

// 获取所有HTML文件
const htmlFiles = getAllHtmlFiles('/Users/livelive/Desktop/eyesite');

// 定义要删除的排班表相关代码正则
const scheduleRegex = /\s*<div\s+class="footer-hour">[\s\S]*?<\/div>\s*/g;
const hourTableRegex = /\s*<table\s+class="hour-table.*?<\/table>\s*/g;
const hourWarningRegex = /\s*<ul\s+class="hour-warning">[\s\S]*?<\/ul>\s*/g;

// 处理每个HTML文件
htmlFiles.forEach(filePath => {
    try {
        // 读取文件内容
        let content = fs.readFileSync(filePath, 'utf8');
        
        // 删除排班表相关代码
        const originalLength = content.length;
        content = content.replace(scheduleRegex, '');
        content = content.replace(hourTableRegex, '');
        content = content.replace(hourWarningRegex, '');
        
        // 保存修改后的文件（只有当内容发生变化时）
        if (content.length !== originalLength) {
            fs.writeFileSync(filePath, content, 'utf8');
            console.log(`✅ 已清理排班表代码: ${filePath}`);
        } else {
            console.log(`ℹ️  无排班表代码: ${filePath}`);
        }
        
    } catch (error) {
        console.error(`❌ 处理文件失败: ${filePath}`, error.message);
    }
});

console.log('\n🎉 所有文件处理完成！');
