const fs = require('fs');
const path = require('path');

// 获取所有HTML文件路径
const htmlFiles = [
    '/Users/livelive/Desktop/eyesite/index.html',
    '/Users/livelive/Desktop/eyesite/team/index.html',
    '/Users/livelive/Desktop/eyesite/team/service/index.html',
    '/Users/livelive/Desktop/eyesite/topics/index.html',
    '/Users/livelive/Desktop/eyesite/topics/462/index.html',
    '/Users/livelive/Desktop/eyesite/surgical/index.html',
    '/Users/livelive/Desktop/eyesite/news/index.html',
    '/Users/livelive/Desktop/eyesite/healthcare/index.html',
    '/Users/livelive/Desktop/eyesite/guide/index.html',
    '/Users/livelive/Desktop/eyesite/facility/index.html',
    '/Users/livelive/Desktop/eyesite/cataract/index.html',
    '/Users/livelive/Desktop/eyesite/retina/index.html',
    '/Users/livelive/Desktop/eyesite/recruit/index.html'
];

// 处理每个HTML文件
htmlFiles.forEach(filePath => {
    try {
        // 读取文件内容
        let content = fs.readFileSync(filePath, 'utf8');
        
        // 去除连续的空行（保留单个空行）
        content = content.replace(/\n\s*\n\s*\n+/g, '\n\n');
        
        // 去除行尾空格
        content = content.replace(/\s+$/gm, '');
        
        // 保存修改后的文件
        fs.writeFileSync(filePath, content, 'utf8');
        console.log(`✅ 已处理文件: ${filePath}`);
        
    } catch (error) {
        console.error(`❌ 处理文件失败: ${filePath}`, error.message);
    }
});

console.log('\n🎉 所有文件处理完成！');
