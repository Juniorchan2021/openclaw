# Page Agent CLI - 快速开始

## 5 分钟上手指南

### 1. 安装依赖

```bash
# 安装 Playwright（如果还没安装）
npm install -g playwright
npx playwright install chromium
```

### 2. 配置 API

```bash
# 使用 OpenAI
~/.openclaw/workspace/skills/page-agent/page-agent.sh config \
  --api openai \
  --api-key YOUR_OPENAI_API_KEY \
  --model gpt-4

# 或使用 Anthropic Claude
~/.openclaw/workspace/skills/page-agent/page-agent.sh config \
  --api anthropic \
  --api-key YOUR_ANTHROPIC_API_KEY \
  --model claude-3-5-sonnet-20241022
```

### 3. 第一个命令

```bash
# 提取网页标题
~/.openclaw/workspace/skills/page-agent/page-agent.sh extract \
  "获取页面标题" \
  --url https://playwright.dev
```

### 4. 更多示例

#### 执行操作
```bash
# Google 搜索
./page-agent.sh perform \
  "在搜索框输入'Playwright'并点击搜索" \
  --url https://google.com \
  --no-headless
```

#### 验证状态
```bash
# 检查页面内容
./page-agent.sh expect \
  "页面包含'Playwright'文字" \
  --url https://playwright.dev
```

#### 提取数据
```bash
# 提取导航链接
./page-agent.sh extract \
  "获取导航栏中的所有链接文本和URL" \
  --url https://playwright.dev
```

## 常见用例

### 用例 1: 自动登录

```bash
./page-agent.sh perform \
  "输入用户名'demo@example.com'，密码'demo123'，点击登录按钮" \
  --url https://example.com/login \
  --cache-file ./login-cache.json
```

### 用例 2: 数据采集

```bash
./page-agent.sh extract \
  "提取所有产品的名称、价格和评分" \
  --url https://example.com/products \
  > products.json
```

### 用例 3: 表单填写

```bash
./page-agent.sh perform \
  "填写联系表单：姓名'张三'，邮箱'zhangsan@example.com'，消息'测试消息'，然后提交" \
  --url https://example.com/contact
```

### 用例 4: 监控检查

```bash
# 创建监控脚本
cat > monitor.sh << 'EOF'
#!/bin/bash
./page-agent.sh expect \
  "页面正常加载且显示最新数据" \
  --url https://example.com/status

if [ $? -eq 0 ]; then
  echo "✓ 网站运行正常"
else
  echo "✗ 网站异常，发送告警"
  # 发送告警通知
fi
EOF

chmod +x monitor.sh
```

## 添加到 PATH

为了方便使用，可以创建符号链接：

```bash
# 创建符号链接
sudo ln -s ~/.openclaw/workspace/skills/page-agent/page-agent.sh /usr/local/bin/page-agent

# 现在可以直接使用
page-agent help
```

或者添加别名到 shell 配置：

```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
echo 'alias page-agent="~/.openclaw/workspace/skills/page-agent/page-agent.sh"' >> ~/.zshrc
source ~/.zshrc
```

## 进阶技巧

### 1. 使用缓存提高效率

```bash
# 第一次执行（会调用 AI）
./page-agent.sh perform "登录系统" \
  --url https://example.com \
  --cache-file ./cache.json

# 后续执行（直接使用缓存，不调用 AI）
./page-agent.sh perform "登录系统" \
  --url https://example.com \
  --cache-file ./cache.json
```

### 2. 调试模式

```bash
# 显示浏览器窗口，方便调试
./page-agent.sh perform "..." \
  --url ... \
  --no-headless
```

### 3. 增加超时时间

```bash
# 对于复杂操作，增加超时
./page-agent.sh perform "..." \
  --url ... \
  --timeout 60000 \
  --max-actions 20
```

### 4. 结合 jq 处理输出

```bash
# 提取特定字段
./page-agent.sh extract "获取产品信息" --url ... | jq '.result'

# 格式化输出
./page-agent.sh extract "..." --url ... | jq -r '.result[] | "\(.name): \(.price)"'
```

## 集成到工作流

### Cron 定时任务

```bash
# 每小时检查一次
0 * * * * /path/to/page-agent.sh expect "网站正常" --url https://example.com
```

### CI/CD 集成

```yaml
# GitHub Actions 示例
- name: Run Page Agent Test
  run: |
    page-agent perform "执行测试流程" \
      --url ${{ secrets.TEST_URL }} \
      --timeout 60000
```

### Shell 脚本集成

```bash
#!/bin/bash
# 批量处理多个页面

urls=(
  "https://example1.com"
  "https://example2.com"
  "https://example3.com"
)

for url in "${urls[@]}"; do
  echo "处理: $url"
  ./page-agent.sh extract "获取页面信息" --url "$url"
done
```

## 下一步

- 阅读完整的 [README.md](./README.md)
- 查看 Playwright 的 [Page Agent 文档](https://playwright.dev/docs/page-agent)
- 探索更多自动化场景

## 获取帮助

```bash
# 查看帮助
./page-agent.sh help

# 查看配置
cat ~/.openclaw/workspace/skills/page-agent/config.json
```

祝使用愉快！🎉
