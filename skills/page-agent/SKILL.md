---
name: page-agent
description: "AI-powered browser automation via Playwright Page Agent: perform actions, verify expectations, extract data using natural language. Use when: (1) automating web interactions with natural language, (2) extracting structured data from web pages, (3) verifying page states and content, (4) testing web applications. NOT for: simple page fetching (use web_fetch), static content scraping (use web_fetch), or when Playwright is not available."
metadata:
  {
    "openclaw":
      {
        "emoji": "🎭",
        "requires": { "bins": ["node", "npx"] },
        "install":
          [
            {
              "id": "npm-playwright",
              "kind": "npm",
              "package": "playwright",
              "global": true,
              "bins": ["playwright"],
              "label": "Install Playwright (npm)",
            },
            {
              "id": "playwright-browsers",
              "kind": "shell",
              "command": "npx playwright install chromium",
              "label": "Install Chromium browser",
            },
          ],
      },
  }
---

# Page Agent Skill

Use Playwright's AI-powered Page Agent to automate browser interactions using natural language descriptions.

## When to Use

✅ **USE this skill when:**

- Automating complex web interactions (forms, navigation, clicks)
- Extracting structured data from dynamic web pages
- Verifying page states and content expectations
- Testing web applications with natural language assertions
- Performing multi-step browser workflows
- Interacting with JavaScript-heavy SPAs

## When NOT to Use

❌ **DON'T use this skill when:**

- Simple page content fetching → use `web_fetch` tool
- Static HTML scraping → use `web_fetch` tool
- Playwright is not installed → install first
- API endpoints are available → use direct HTTP requests
- Simple URL checks → use `curl` or `web_fetch`

## Setup

```bash
# Install Playwright globally
npm install -g playwright

# Install browsers
npx playwright install chromium

# Configure API (required for AI features)
# Set environment variables or use config file
export OPENAI_API_KEY="sk-..."
# or
export ANTHROPIC_API_KEY="sk-ant-..."
```

## Core Operations

### 1. Perform Actions

Execute browser actions using natural language:

```bash
# Basic click
page-agent perform "Click the login button" --url https://example.com

# Form filling
page-agent perform "Enter 'user@example.com' in email field and 'password123' in password field, then click submit" \
  --url https://example.com/login

# Navigation
page-agent perform "Click on the 'Products' menu and select 'Electronics'" \
  --url https://shop.example.com

# Complex workflow
page-agent perform "Search for 'laptop', filter by price under $1000, and sort by rating" \
  --url https://shop.example.com
```

### 2. Verify Expectations

Assert page states and content:

```bash
# Check page content
page-agent expect "Page title contains 'Welcome'" --url https://example.com

# Verify elements
page-agent expect "Login button is visible and enabled" --url https://example.com/login

# Check data
page-agent expect "Product price is displayed as $99.99" --url https://shop.example.com/product/123

# Verify state
page-agent expect "User is logged in and dashboard is visible" --url https://app.example.com
```

### 3. Extract Data

Extract structured information from pages:

```bash
# Extract product info
page-agent extract "Get all product names and prices" --url https://shop.example.com/products

# Extract table data
page-agent extract "Extract all rows from the data table" --url https://example.com/data

# Extract contact info
page-agent extract "Get email addresses and phone numbers from the page" --url https://example.com/contact

# Extract with structure
page-agent extract "Get product details including name, price, rating, and availability" \
  --url https://shop.example.com/product/123
```

## Options

### Global Options

- `--url <url>`: Target page URL (required)
- `--headless`: Run in headless mode (default)
- `--no-headless`: Show browser window for debugging
- `--timeout <ms>`: Operation timeout in milliseconds (default: 30000)

### Perform Options

- `--max-actions <n>`: Maximum number of actions to perform (default: 10)
- `--cache-file <path>`: Cache file for reusing action sequences

### API Configuration

- `--api <provider>`: API provider (openai/anthropic)
- `--api-key <key>`: API key for the provider
- `--model <model>`: Model to use (e.g., gpt-4, claude-3-5-sonnet-20241022)
- `--api-endpoint <url>`: Custom API endpoint

## Configuration

Create a config file at `~/.openclaw/workspace/skills/page-agent/config.json`:

```json
{
  "api": "openai",
  "apiKey": "sk-...",
  "model": "gpt-4",
  "maxActions": 10,
  "defaultTimeout": 30000
}
```

Or configure via command:

```bash
page-agent config --api openai --api-key sk-... --model gpt-4
```

## Advanced Usage

### Using Cache for Repeated Operations

Cache action sequences to avoid repeated AI calls:

```bash
# First run (calls AI)
page-agent perform "Login with test credentials" \
  --url https://example.com/login \
  --cache-file ./login-cache.json

# Subsequent runs (uses cache, no AI call)
page-agent perform "Login with test credentials" \
  --url https://example.com/login \
  --cache-file ./login-cache.json
```

### Debugging with Visible Browser

```bash
page-agent perform "..." --url ... --no-headless
```

### Combining with jq for Data Processing

```bash
# Extract and format data
page-agent extract "Get product information" --url ... | jq '.result'

# Filter extracted data
page-agent extract "Get all products" --url ... | jq '.result[] | select(.price < 100)'
```

### Integration with Scripts

```bash
#!/bin/bash
# Automated testing script

# Test login
page-agent perform "Login with valid credentials" --url https://app.example.com/login
page-agent expect "Dashboard is visible" --url https://app.example.com/dashboard

# Test feature
page-agent perform "Create new item with name 'Test Item'" --url https://app.example.com/items
page-agent expect "Item 'Test Item' appears in the list" --url https://app.example.com/items

echo "✓ All tests passed"
```

## Use Cases

### 1. Automated Testing

```bash
# E2E test flow
page-agent perform "Complete checkout process with test card" --url https://shop.example.com
page-agent expect "Order confirmation page is displayed" --url https://shop.example.com/confirmation
```

### 2. Data Collection

```bash
# Scrape product catalog
for page in {1..10}; do
  page-agent extract "Get all products on this page" \
    --url "https://shop.example.com/products?page=$page" \
    >> products.jsonl
done
```

### 3. Monitoring

```bash
# Check site health
page-agent expect "Page loads successfully and shows latest content" \
  --url https://example.com \
  --timeout 10000
```

### 4. Form Automation

```bash
# Bulk form submission
while IFS=, read -r name email message; do
  page-agent perform "Fill name '$name', email '$email', message '$message', and submit" \
    --url https://example.com/contact
done < contacts.csv
```

## How It Works

Page Agent combines Playwright's browser automation with AI language models:

1. **Snapshot**: Captures page accessibility tree
2. **Understanding**: AI interprets natural language task
3. **Planning**: Generates action sequence
4. **Execution**: Playwright performs browser actions
5. **Verification**: Validates results

```
┌─────────────────┐
│  Natural Lang   │
│  Description    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  AI Model       │
│  (GPT-4/Claude) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Playwright     │
│  Actions        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Browser        │
│  Automation     │
└─────────────────┘
```

## Notes

- **API Costs**: Each operation calls AI API; use caching for repeated tasks
- **Timeout**: Complex operations may need longer timeouts
- **Headless**: Use `--no-headless` for debugging
- **Security**: Don't expose sensitive credentials in commands
- **Rate Limits**: Be mindful of API rate limits for bulk operations

## Troubleshooting

### Issue: API Key Not Configured

```
Error: This action requires API key to be set
```

**Solution**: Configure API key via config command or environment variable

### Issue: Playwright Not Installed

```
Error: Cannot find module 'playwright'
```

**Solution**: Install Playwright
```bash
npm install -g playwright
npx playwright install chromium
```

### Issue: Operation Timeout

```
Error: Operation timed out
```

**Solution**: Increase timeout
```bash
page-agent perform "..." --url ... --timeout 60000
```

### Issue: Action Failed

**Solution**: Try with visible browser to debug
```bash
page-agent perform "..." --url ... --no-headless
```

## Related Skills

- `browser` - OpenClaw's built-in browser control
- `web_fetch` - Simple page content fetching
- `coding-agent` - Code analysis and generation

## Resources

- [Playwright Documentation](https://playwright.dev/)
- [Playwright Page Agent](https://playwright.dev/docs/page-agent)
- [OpenAI API](https://platform.openai.com/docs)
- [Anthropic API](https://docs.anthropic.com/)
