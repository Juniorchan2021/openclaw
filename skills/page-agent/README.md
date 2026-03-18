# Page Agent CLI

基于 Playwright Page Agent 的智能网页自动化工具。使用 AI 驱动的方式执行网页操作、验证状态和提取数据。

## 功能特性

- **智能操作 (Perform)**: 使用自然语言描述执行网页操作
- **状态验证 (Expect)**: 验证网页是否符合预期状态
- **数据提取 (Extract)**: 从网页中提取结构化数据
- **操作缓存**: 支持缓存常用操作，提高执行效率
- **多 API 支持**: 支持 OpenAI、Anthropic 等 AI 提供商

## 安装

```bash
# 确保已安装 Node.js 和 Playwright
npm install -g playwright

# 安装浏览器
npx playwright install chromium

# 添加到 PATH（可选）
ln -s ~/.openclaw/workspace/skills/page-agent/page-agent.sh /usr/local/bin/page-agent
```

## 配置

首次使用前需要配置 API 密钥：

```bash
# 配置 OpenAI
page-agent config --api openai --api-key sk-xxx --model gpt-4

# 配置 Anthropic
page-agent config --api anthropic --api-key sk-ant-xxx --model claude-3-5-sonnet-20241022
```

配置文件保存在 `~/.openclaw/workspace/skills/page-agent/config.json`

## 使用方法

### 1. 执行操作 (Perform)

使用自然语言描述要执行的操作：

```bash
# 基本用法
page-agent perform "点击登录按钮" --url https://example.com

# 复杂操作
page-agent perform "在搜索框输入'Playwright'并点击搜索按钮" \
  --url https://google.com \
  --timeout 60000 \
  --max-actions 5

# 使用缓存
page-agent perform "登录系统" \
  --url https://example.com \
  --cache-file ./login-cache.json
```

### 2. 验证期望 (Expect)

验证网页是否符合预期状态：

```bash
# 验证页面标题
page-agent expect "页面标题包含'欢迎'" --url https://example.com

# 验证元素存在
page-agent expect "页面上有登录按钮" --url https://example.com

# 验证内容
page-agent expect "价格显示为 $99.99" --url https://shop.example.com/product
```

### 3. 提取数据 (Extract)

从网页中提取结构化数据：

```bash
# 提取产品信息
page-agent extract "获取所有产品的名称和价格" \
  --url https://shop.example.com

# 提取表格数据
page-agent extract "提取表格中的所有行数据" \
  --url https://example.com/data

# 提取联系信息
page-agent extract "获取页面上的邮箱和电话号码" \
  --url https://example.com/contact
```

## 选项说明

### 全局选项

- `--url <url>`: 目标网页 URL（必需）
- `--headless`: 无头模式运行（默认）
- `--no-headless`: 显示浏览器窗口
- `--timeout <ms>`: 操作超时时间（毫秒，默认 30000）

### Perform 专用选项

- `--max-actions <n>`: 最大操作次数（默认 10）
- `--cache-file <path>`: 缓存文件路径

### API 配置选项

- `--api <provider>`: API 提供商（openai/anthropic）
- `--api-key <key>`: API 密钥
- `--model <model>`: 使用的模型
- `--api-endpoint <url>`: 自定义 API 端点

## 实际应用场景

### 1. 自动化测试

```bash
# 测试登录流程
page-agent perform "输入用户名'test@example.com'，密码'password123'，点击登录" \
  --url https://app.example.com/login

page-agent expect "页面显示'登录成功'" \
  --url https://app.example.com/dashboard
```

### 2. 数据采集

```bash
# 采集产品信息
page-agent extract "获取所有产品的名称、价格、评分和库存状态" \
  --url https://shop.example.com/products > products.json
```

### 3. 监控检查

```bash
# 检查网站状态
page-agent expect "页面加载正常且显示最新内容" \
  --url https://example.com
```

### 4. 表单填写

```bash
# 自动填写表单
page-agent perform "填写姓名'张三'，邮箱'zhangsan@example.com'，选择'产品咨询'，提交表单" \
  --url https://example.com/contact
```

## 工作原理

Page Agent CLI 基于 Playwright 的 Page Agent 功能，结合 AI 模型实现：

1. **快照分析**: 获取页面的可访问性树快照
2. **任务理解**: AI 模型理解自然语言任务描述
3. **操作规划**: 生成执行计划并调用相应的工具
4. **动作执行**: 通过 Playwright 执行实际的浏览器操作
5. **结果验证**: 验证操作结果并返回

## 技术架构

```
┌─────────────────┐
│  CLI Interface  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Playwright     │
│  Page Agent     │
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌────────┐ ┌────────┐
│   AI   │ │Browser │
│ Model  │ │Actions │
└────────┘ └────────┘
```

## 注意事项

1. **API 费用**: 每次操作都会调用 AI API，注意控制使用量
2. **超时设置**: 复杂操作可能需要更长的超时时间
3. **缓存使用**: 对于重复操作，使用缓存可以节省 API 调用
4. **安全性**: 不要在命令行中直接暴露敏感信息

## 故障排除

### 问题：未配置 API 密钥

```bash
错误: 未配置 API 密钥，请先运行: page-agent config --api-key <key>
```

**解决**: 运行配置命令设置 API 密钥

### 问题：Playwright 未安装

```bash
错误: Cannot find module 'playwright'
```

**解决**: 安装 Playwright
```bash
npm install -g playwright
npx playwright install chromium
```

### 问题：操作超时

```bash
错误: 操作超时
```

**解决**: 增加超时时间
```bash
page-agent perform "..." --url ... --timeout 60000
```

## 相关资源

- [Playwright 官方文档](https://playwright.dev/)
- [Playwright Page Agent](https://playwright.dev/docs/page-agent)
- [OpenAI API](https://platform.openai.com/docs)
- [Anthropic API](https://docs.anthropic.com/)

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！
