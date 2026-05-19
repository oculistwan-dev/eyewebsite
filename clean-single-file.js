const fs = require('fs');

// 文件路径
const filePath = '/Users/livelive/Desktop/eyesite/healthcare/index.html';

try {
    // 读取文件内容
    let content = fs.readFileSync(filePath, 'utf8');
    
    // 更严格地去除空行：
    // 1. 去除所有连续的空行（只保留最多一个空行）
    // 2. 去除文件开头和结尾的空行
    // 3. 去除行尾空格
    content = content
        .replace(/^\s*\n+/, '') // 去除开头空行
        .replace(/\n+\s*$/, '') // 去除结尾空行
        .replace(/\n\s*\n+/g, '\n\n') // 去除连续空行
        .replace(/\s+$/gm, ''); // 去除行尾空格
    
    // 保存修改后的文件
    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`✅ 已清理文件: ${filePath}`);
    
    // 验证结果
    const cleanedContent = fs.readFileSync(filePath, 'utf8');
    const lineCount = cleanedContent.split('\n').length;
    console.log(`📄 文件共有 ${lineCount} 行`);
    
} catch (error) {
    console.error(`❌ 处理文件失败: ${filePath}`, error.message);
}
