#!/bin/bash
# Page Agent CLI - 基于 Playwright Page Agent 的自动化工具
# 用于执行网页自动化任务、提取数据和验证期望

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    cat << EOF
${BLUE}Page Agent CLI${NC} - 网页自动化助手

用法:
    page-agent <command> [options]

命令:
    perform <task>          执行网页操作任务
    expect <expectation>    验证网页状态/期望
    extract <query>         从网页提取数据
    config                  配置 API 设置
    help                    显示此帮助信息

选项:
    --url <url>            目标网页 URL
    --headless             无头模式运行
    --timeout <ms>         超时时间（毫秒）
    --max-actions <n>      最大操作次数
    --cache-file <path>    缓存文件路径
    --api <provider>       API 提供商 (openai/anthropic)
    --model <model>        使用的模型
    --api-key <key>        API 密钥

示例:
    # 执行操作
    page-agent perform "点击登录按钮并输入用户名" --url https://example.com

    # 验证期望
    page-agent expect "页面标题包含'欢迎'" --url https://example.com

    # 提取数据
    page-agent extract "获取所有产品名称和价格" --url https://example.com

    # 配置 API
    page-agent config --api openai --api-key sk-xxx --model gpt-4

EOF
}

# 加载配置
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        API_PROVIDER=$(jq -r '.api // "openai"' "$CONFIG_FILE")
        API_KEY=$(jq -r '.apiKey // ""' "$CONFIG_FILE")
        MODEL=$(jq -r '.model // "gpt-4"' "$CONFIG_FILE")
        API_ENDPOINT=$(jq -r '.apiEndpoint // ""' "$CONFIG_FILE")
    else
        API_PROVIDER="openai"
        API_KEY=""
        MODEL="gpt-4"
        API_ENDPOINT=""
    fi
}

# 保存配置
save_config() {
    mkdir -p "$SCRIPT_DIR"
    cat > "$CONFIG_FILE" << EOF
{
  "api": "$API_PROVIDER",
  "apiKey": "$API_KEY",
  "model": "$MODEL",
  "apiEndpoint": "$API_ENDPOINT"
}
EOF
    echo -e "${GREEN}✓${NC} 配置已保存到 $CONFIG_FILE"
}

# 配置命令
cmd_config() {
    load_config
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --api)
                API_PROVIDER="$2"
                shift 2
                ;;
            --api-key)
                API_KEY="$2"
                shift 2
                ;;
            --model)
                MODEL="$2"
                shift 2
                ;;
            --api-endpoint)
                API_ENDPOINT="$2"
                shift 2
                ;;
            *)
                echo -e "${RED}错误:${NC} 未知选项 $1"
                exit 1
                ;;
        esac
    done
    
    save_config
}

# 执行 Playwright 脚本
run_playwright() {
    local action="$1"
    local task="$2"
    local url="$3"
    local headless="${4:-true}"
    local timeout="${5:-30000}"
    local max_actions="${6:-10}"
    local cache_file="${7:-}"
    
    load_config
    
    if [[ -z "$API_KEY" ]]; then
        echo -e "${RED}错误:${NC} 未配置 API 密钥，请先运行: page-agent config --api-key <key>"
        exit 1
    fi
    
    # 创建临时 Node.js 脚本
    local temp_script=$(mktemp /tmp/page-agent-XXXXXX.js)
    
    cat > "$temp_script" << 'EOFJS'
const { chromium } = require('playwright');

async function main() {
    const action = process.argv[2];
    const task = process.argv[3];
    const url = process.argv[4];
    const headless = process.argv[5] === 'true';
    const timeout = parseInt(process.argv[6]);
    const maxActions = parseInt(process.argv[7]);
    const cacheFile = process.argv[8] || null;
    const apiProvider = process.argv[9];
    const apiKey = process.argv[10];
    const model = process.argv[11];
    const apiEndpoint = process.argv[12] || null;
    
    const browser = await chromium.launch({ headless });
    const context = await browser.newContext();
    const page = await context.newPage();
    
    // 配置 page agent
    const agent = await page.agent({
        api: apiProvider,
        apiKey: apiKey,
        model: model,
        apiEndpoint: apiEndpoint,
        maxActions: maxActions,
        cacheFile: cacheFile
    });
    
    try {
        await page.goto(url, { timeout });
        
        let result;
        switch(action) {
            case 'perform':
                result = await agent.perform(task, { timeout });
                console.log(JSON.stringify({ success: true, usage: result.usage }));
                break;
                
            case 'expect':
                await agent.expect(task, { timeout });
                console.log(JSON.stringify({ success: true, message: '验证通过' }));
                break;
                
            case 'extract':
                result = await agent.extract(task, {}, { timeout });
                console.log(JSON.stringify({ success: true, result: result.result, usage: result.usage }));
                break;
                
            default:
                throw new Error(`未知操作: ${action}`);
        }
    } catch (error) {
        console.error(JSON.stringify({ success: false, error: error.message }));
        process.exit(1);
    } finally {
        await agent.dispose();
        await browser.close();
    }
}

main();
EOFJS
    
    # 执行脚本
    echo -e "${BLUE}→${NC} 正在执行 $action 操作..."
    local result=$(node "$temp_script" "$action" "$task" "$url" "$headless" "$timeout" "$max_actions" "$cache_file" "$API_PROVIDER" "$API_KEY" "$MODEL" "$API_ENDPOINT" 2>&1)
    
    # 清理临时文件
    rm -f "$temp_script"
    
    # 解析结果
    if echo "$result" | jq -e '.success' > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} 操作成功"
        echo "$result" | jq '.'
    else
        echo -e "${RED}✗${NC} 操作失败"
        echo "$result" | jq -r '.error // .'
        exit 1
    fi
}

# Perform 命令
cmd_perform() {
    local task=""
    local url=""
    local headless="true"
    local timeout="30000"
    local max_actions="10"
    local cache_file=""
    
    if [[ $# -eq 0 ]]; then
        echo -e "${RED}错误:${NC} 缺少任务描述"
        echo "用法: page-agent perform <task> --url <url> [options]"
        exit 1
    fi
    
    task="$1"
    shift
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --url)
                url="$2"
                shift 2
                ;;
            --headless)
                headless="true"
                shift
                ;;
            --no-headless)
                headless="false"
                shift
                ;;
            --timeout)
                timeout="$2"
                shift 2
                ;;
            --max-actions)
                max_actions="$2"
                shift 2
                ;;
            --cache-file)
                cache_file="$2"
                shift 2
                ;;
            *)
                echo -e "${RED}错误:${NC} 未知选项 $1"
                exit 1
                ;;
        esac
    done
    
    if [[ -z "$url" ]]; then
        echo -e "${RED}错误:${NC} 缺少 --url 参数"
        exit 1
    fi
    
    run_playwright "perform" "$task" "$url" "$headless" "$timeout" "$max_actions" "$cache_file"
}

# Expect 命令
cmd_expect() {
    local expectation=""
    local url=""
    local headless="true"
    local timeout="5000"
    
    if [[ $# -eq 0 ]]; then
        echo -e "${RED}错误:${NC} 缺少期望描述"
        echo "用法: page-agent expect <expectation> --url <url> [options]"
        exit 1
    fi
    
    expectation="$1"
    shift
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --url)
                url="$2"
                shift 2
                ;;
            --headless)
                headless="true"
                shift
                ;;
            --no-headless)
                headless="false"
                shift
                ;;
            --timeout)
                timeout="$2"
                shift 2
                ;;
            *)
                echo -e "${RED}错误:${NC} 未知选项 $1"
                exit 1
                ;;
        esac
    done
    
    if [[ -z "$url" ]]; then
        echo -e "${RED}错误:${NC} 缺少 --url 参数"
        exit 1
    fi
    
    run_playwright "expect" "$expectation" "$url" "$headless" "$timeout" "10" ""
}

# Extract 命令
cmd_extract() {
    local query=""
    local url=""
    local headless="true"
    local timeout="30000"
    
    if [[ $# -eq 0 ]]; then
        echo -e "${RED}错误:${NC} 缺少查询描述"
        echo "用法: page-agent extract <query> --url <url> [options]"
        exit 1
    fi
    
    query="$1"
    shift
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --url)
                url="$2"
                shift 2
                ;;
            --headless)
                headless="true"
                shift
                ;;
            --no-headless)
                headless="false"
                shift
                ;;
            --timeout)
                timeout="$2"
                shift 2
                ;;
            *)
                echo -e "${RED}错误:${NC} 未知选项 $1"
                exit 1
                ;;
        esac
    done
    
    if [[ -z "$url" ]]; then
        echo -e "${RED}错误:${NC} 缺少 --url 参数"
        exit 1
    fi
    
    run_playwright "extract" "$query" "$url" "$headless" "$timeout" "10" ""
}

# 主函数
main() {
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi
    
    local command="$1"
    shift
    
    case "$command" in
        perform)
            cmd_perform "$@"
            ;;
        expect)
            cmd_expect "$@"
            ;;
        extract)
            cmd_extract "$@"
            ;;
        config)
            cmd_config "$@"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}错误:${NC} 未知命令 '$command'"
            echo "运行 'page-agent help' 查看可用命令"
            exit 1
            ;;
    esac
}

main "$@"
