const fs = require('fs');
const { JSDOM } = require('jsdom');

// Read the HTML file
const html = fs.readFileSync('/Users/livelive/Desktop/eyesite/index.html', 'utf8');

// Parse the HTML with JSDOM
const dom = new JSDOM(html);
const document = dom.window.document;

// Check for common HTML errors
console.log('=== HTML Code Review Results ===');
console.log('1. DOCTYPE declaration:', document.doctype ? 'Present' : 'Missing');
console.log('2. HTML root element:', document.documentElement ? 'Present' : 'Missing');

// Check for unclosed tags by counting opening and closing tags
const tagNames = ['div', 'section', 'header', 'footer', 'ul', 'li', 'p', 'h1', 'h2', 'h3', 'h4', 'a', 'img'];
let hasErrors = false;

tagNames.forEach(tagName => {
  const openingTags = (html.match(new RegExp(`<${tagName}(?![/])`, 'g')) || []).length;
  const closingTags = (html.match(new RegExp(`</${tagName}>`, 'g')) || []).length;
  
  if (openingTags !== closingTags) {
    console.log(`3. Tag <${tagName}>: ${openingTags} opening tags vs ${closingTags} closing tags`);
    hasErrors = true;
  }
});

// Check for invalid attributes in img tags
const imgTags = html.match(/<img[^>]*>/g) || [];
imgTags.forEach((imgTag, index) => {
  if (!imgTag.includes('alt=')) {
    console.log(`4. Img tag ${index + 1} missing alt attribute: ${imgTag}`);
    hasErrors = true;
  }
});

// Check for duplicate IDs
const ids = html.match(/id="[^"]+"/g) || [];
const idMap = {};
ids.forEach(id => {
  const idValue = id.replace(/id="|"/g, '');
  idMap[idValue] = (idMap[idValue] || 0) + 1;
});

Object.entries(idMap).forEach(([id, count]) => {
  if (count > 1) {
    console.log(`5. Duplicate ID "${id}": ${count} occurrences`);
    hasErrors = true;
  }
});

console.log('=== Review Complete ===');
console.log('HTML syntax check result:', hasErrors ? 'Found errors' : 'No errors detected');
