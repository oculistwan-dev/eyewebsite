# Copilot 指南 — eyesite 仓库

以下说明面向来参与本仓库的 AI 编码代理或协作开发者，重点汇总本项目的“大图景”、关键工作流、习惯用法和常见陷阱。保持简短、可执行，便于快速上手。

**项目概览**
- **类型**: 静态网站（由 WordPress 主题导出并优化），大量按目录组织的 `index.html` 页面（每个子目录一个 `index.html`）。
- **主要目录**: `wp-content/themes/oculistwan/`（主题静态资源和 CSS/JS）、`wp-content/uploads/`（图片上传）、根目录下各种页面目录（`guide/`,`healthcare/`,`topics/` 等）。
- **目标**: 将站点本地化（中文）、去除外部 Google/CDN 服务、优化性能（WebP、懒加载、缓存策略）。

**关键文件/示例（直接引用以便快速定位）**
- 本地化脚本: `complete-china-adaptation.sh` — 会创建 `.bak` 备份并使用 macOS `sed -i ''` 替换外部引用（注意：脚本内有 `SITE_DIR` 绝对路径）。
- 文本转换: `convert-to-simplified-chinese.py` — 通过两个映射字典做日文/繁体→简体转换；要扩展词条请直接编辑字典 `JAPANESE_TO_CHINESE` / `TRADITIONAL_TO_SIMPLIFIED`。
- 优化脚本: `optimize-website.sh` — 包括图片转 WebP（调用 `cwebp`）、移除 WP API 引用、生成 `.htaccess` 缓存规则。
- 模板示例: `optimized-template.html` — 展示关键 CSS 内联、WebP 检测、懒加载（IntersectionObserver）、以及 `defer` 加载脚本的惯用模式。

**立即可运行的开发命令（示例）**
- 在仓库根目录本地预览静态站点: `python3 -m http.server 8000` 然后访问 `http://localhost:8000`。
- 运行性能优化脚本: `sh optimize-website.sh`（需要 `cwebp` 可选，用 `brew install webp` 安装）。
- 运行中国适配脚本: `sh complete-china-adaptation.sh`（注意脚本中的 `SITE_DIR`，按需修改为当前路径或运行前设置环境变量）。
- 运行简体转换: `python3 convert-to-simplified-chinese.py`（会修改文件，请先备份或使用 Git 查看差异）。

**项目惯例 / 注意事项（重要）**
- 编辑保护: 多个脚本会创建 `.bak` 备份（例如 `index.html.bak`），不要直接删除这些备份，除非确认无误。
- sed 在 macOS 与 Linux 行为不同：脚本使用 `sed -i ''`（macOS BSD sed）。在 Linux 上运行需改为 `sed -i` 或安装 `gnu-sed` 并调整命令。
- 绝对路径：多个脚本默认 `SITE_DIR="/Users/livelive/Desktop/eyesite"`，在其他环境运行前请修改或将脚本改为相对路径。
- 图片处理：仓库包含 `compressed_images_backup/` 与 `optimized_backup*`，不要覆盖这些文件夹，新增 WebP 会与原 JPG 并存（脚本会生成 `${name}.webp`）。
- 模板模式：首屏关键 CSS 常内联于 `optimized-template.html`；后续加载使用 `defer` 与懒加载。修改视觉/排版优先改 `wp-content/themes/oculistwan/css` 下文件再生成静态页面。

**代码/文本修改建议（针对 AI 代理）**
- 当需替换大量文本（语言本地化或短语替换），优先查阅并扩展 `convert-to-simplified-chinese.py` 中的映射表；该脚本是项目中可复用的文本转换入口。
- 批量 HTML 修改请仅读取并写入没有 `.bak` 后缀的文件；保留并不覆盖已有 `.bak`，除非你显式确认回滚逻辑。
- 如果要移除或替换外部资源引用（CDN、Google 服务等），模仿 `complete-china-adaptation.sh` 的正则/`sed` 规则，并在本地用 `git diff` 或 `grep` 验证变更。

**调试与验证要点**
- 本地预览：用 `python3 -m http.server` 检查页面渲染与资源路径问题。
- 图片：检查 `wp-content/uploads/` 和 `wp-content/themes/oculistwan/images/`，优先用 WebP 回退到 JPG（模板中已有 `picture` 元素示例）。
- JS/CSS：`optimized-template.html` 展示 `defer` 和内联关键 CSS 的惯例；修改后检查 `Network` 面板中的加载顺序及缓存头（若使用 `.htaccess`）。

**不要做的事情**
- 不要在没有备份或未通过 Git 的情况下批量替换源文件。
- 不要假设 `sed` 命令在所有环境都一致；先在目标系统上小规模测试。

如果有需要，我可以把上述要点合并进 README 或补充更多代码示例（比如一个安全地在 Linux 上运行的 `sed` 兼容版脚本）。请告诉我是否需要把 `SITE_DIR` 改为相对路径模板或添加自动备份/回滚步骤。

---
请检查这份指南是否覆盖了你的日常工作场景或缺失的重要点；告诉我需要补充的具体示例或命令。 
