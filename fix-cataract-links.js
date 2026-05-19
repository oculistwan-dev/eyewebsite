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

// 遍历所有HTML文件
htmlFiles.forEach(filePath => {
    try {
        // 读取文件内容
        let content = fs.readFileSync(filePath, 'utf8');
        
        // 获取当前文件所在的目录深度，用于计算正确的相对路径
        const relativePath = path.relative(path.dirname(filePath), '/Users/livelive/Desktop/eyesite');
        const healthcareLink = relativePath ? `${relativePath}/healthcare/index.html` : 'healthcare/index.html';
        
        // 修改PC端导航
        const pcNavRegex = /<li class="healthcare-nav"><a>白内障和手术<\/a><\/li>/g;
        content = content.replace(pcNavRegex, `<li class="healthcare-nav"><a href="${healthcareLink}">白内障和手术</a></li>`);
        
        // 修改移动端导航 - 主按钮
        const mobileNavRegex = /<li><div>白内障和手术<div class="icon-wrap"><span class="icon"><\/span><\/div><\/div>/g;
        content = content.replace(mobileNavRegex, `<li><div><a href="${healthcareLink}" onclick="event.stopPropagation();">白内障和手术</a><div class="icon-wrap"><span class="icon"></span></div></div>`);
        
        // 修改子菜单中的链接（确保所有子按钮都链接到正确页面）
        const subMenuRegex = /<li><a href="[^"]*">白内障和手术<\/a><\/li>/g;
        content = content.replace(subMenuRegex, `<li><a href="${healthcareLink}">白内障和手术</a></li>`);
        
        // 保存修改后的文件
        fs.writeFileSync(filePath, content, 'utf8');
        console.log(`✅ 已修改文件: ${filePath}`);
        
    } catch (error) {
        console.error(`❌ 处理文件失败: ${filePath}`, error.message);
    }
});

console.log('\n🎉 所有文件修改完成！');
