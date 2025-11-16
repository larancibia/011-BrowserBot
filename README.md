# 🤖 Web Agent with DeepSeek R1 + Vision

Autonomous web agent that uses **DeepSeek R1** for reasoning and **LLaVA** for vision to navigate and interact with websites.

## 🎯 Features

- **Vision-based navigation**: Uses LLaVA 7B to analyze screenshots
- **Chain-of-thought reasoning**: DeepSeek R1:8b decides actions intelligently
- **Autonomous execution**: Executes clicks, form fills, navigation automatically
- **Cookie extraction**: Extracts authentication cookies for automation
- **GPU optimized**: Runs on RTX 3090 24GB VRAM

## 🚀 Quick Start

### Prerequisites

- **NVIDIA GPU** with 24GB VRAM (tested on RTX 3090)
- **Ollama** installed and running
- **Python 3.10+**
- **Playwright** for browser automation

### Installation

```bash
# 1. Clone repo
git clone https://github.com/YOUR_USERNAME/web-agent.git
cd web-agent

# 2. Run setup script
./setup-ollama-agent.sh

# 3. Start Ollama (in separate terminal)
ollama serve
```

### Usage

#### Extract TurboScribe Cookies

```bash
./run-web-agent-turboscribe.sh
```

This will:
1. Download DeepSeek R1:8b (~8GB) and LLaVA 7B (~4.5GB)
2. Open browser and navigate to turboscribe.ai
3. Use vision to detect "Sign in with Google" button
4. Wait for you to complete Google OAuth manually
5. Extract and save cookies to `turboscribe-mcp/cookies.json`

#### Custom Task

```bash
python3 ollama-web-agent-reasoning.py \
    --task "Search for 'AI reasoning models' on Google" \
    --url "https://google.com" \
    --max-steps 10
```

## 🧠 How It Works

### Two-Stage Architecture

```
┌─────────────────────────────────────────────────┐
│  1. Screenshot capture                          │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  2. Vision Analysis (LLaVA 7B)                  │
│     "I see a blue button labeled 'Sign in'      │
│      at coordinates (640, 200)"                 │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  3. Reasoning (DeepSeek R1:8b)                  │
│     💭 "I need to login"                         │
│     💭 "I see a sign in button"                  │
│     💭 "Best action: click"                      │
│     → Decision: {"action": "click", ...}        │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  4. Execution (Playwright)                      │
│     🖱️ Clicks button at (640, 200)              │
└─────────────────────────────────────────────────┘
```

### Models

- **Vision**: LLaVA 7B (~4.5GB VRAM)
- **Reasoning**: DeepSeek R1:8b (~8GB VRAM)
- **Total**: ~12.5GB VRAM (fits comfortably in 24GB)

## 📊 Command Line Options

```bash
python3 ollama-web-agent-reasoning.py \
    --task "Your task description" \
    --url "https://example.com" \
    --reasoning-model "deepseek-r1:8b" \
    --vision-model "llava:7b" \
    --max-steps 20 \
    --save-cookies "/path/to/cookies.json" \
    --headless  # Run without visible browser
```

### Available Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--task` | Task description for the agent | Required |
| `--url` | Starting URL | `https://turboscribe.ai` |
| `--reasoning-model` | Ollama reasoning model | `deepseek-r1:8b` |
| `--vision-model` | Ollama vision model | `llava:7b` |
| `--max-steps` | Maximum steps to execute | `15` |
| `--save-cookies` | Path to save cookies JSON | None |
| `--headless` | Run browser in headless mode | `False` |

## 🎮 Example Tasks

### Login to Website

```bash
python3 ollama-web-agent-reasoning.py \
    --task "Login to example.com using Google OAuth" \
    --url "https://example.com/login"
```

### Fill Form

```bash
python3 ollama-web-agent-reasoning.py \
    --task "Fill contact form with name 'John Doe' and email 'john@example.com'" \
    --url "https://example.com/contact"
```

### Search and Navigate

```bash
python3 ollama-web-agent-reasoning.py \
    --task "Search for 'Claude AI' and click first result" \
    --url "https://google.com"
```

## 📁 Files

| File | Description |
|------|-------------|
| `ollama-web-agent-reasoning.py` | Main agent with DeepSeek R1 + LLaVA |
| `ollama-web-agent.py` | Simple version (single model) |
| `run-web-agent-turboscribe.sh` | TurboScribe cookie extraction script |
| `setup-ollama-agent.sh` | Setup script for dependencies |
| `extract-turboscribe-cookies.py` | Alternative Playwright-based extractor |
| `GUIA-WEB-AGENT.md` | Complete guide (Spanish) |

## 🔧 Troubleshooting

### "Error connecting to Ollama"

```bash
# Start Ollama in separate terminal
ollama serve
```

### "Model not found"

```bash
# Download models manually
ollama pull deepseek-r1:8b
ollama pull llava:7b
```

### "Playwright not installed"

```bash
pip3 install playwright httpx
python3 -m playwright install chromium
```

### VRAM issues

```bash
# Check GPU usage
nvidia-smi

# Use smaller models
python3 ollama-web-agent-reasoning.py \
    --reasoning-model deepseek-r1:1.5b \
    --vision-model llava:7b
```

## 🎯 Performance

- **First run**: ~10-30 min (downloads ~12.5GB models)
- **Subsequent runs**: ~2-5 min per task
- **Per step**: ~5-10 seconds (vision + reasoning + execution)
- **VRAM usage**: ~12.5GB / 24GB (52%)

## 💡 Tips

1. **First time**: Don't use `--headless` to see how it works
2. **Google OAuth**: Agent detects button but you complete login manually
3. **Debugging**: Agent shows detailed reasoning for each step
4. **Cookie persistence**: Saved cookies work for ~30 days

## 🆚 Alternative Models

### Larger reasoning models

```bash
# More capable but slower
ollama pull deepseek-r1:14b  # Requires 14GB VRAM
python3 ollama-web-agent-reasoning.py --reasoning-model deepseek-r1:14b
```

### Better vision models

```bash
# More accurate vision
ollama pull llava:13b  # Requires 8GB VRAM
python3 ollama-web-agent-reasoning.py --vision-model llava:13b
```

## 📚 Documentation

- **[Complete Guide](GUIA-WEB-AGENT.md)** - Detailed documentation (Spanish)
- **[Ollama Documentation](https://ollama.ai/docs)** - Ollama setup and models
- **[Playwright Documentation](https://playwright.dev/)** - Browser automation
- **[DeepSeek R1](https://github.com/deepseek-ai/DeepSeek-R1)** - Reasoning model info

## 🤝 Use Cases

- ✅ Cookie extraction for automation
- ✅ Form filling and submission
- ✅ OAuth login flows
- ✅ Web scraping with authentication
- ✅ E2E testing with AI reasoning
- ✅ Social media automation
- ✅ Data entry automation

## ⚠️ Limitations

- Google OAuth requires manual completion (anti-bot protection)
- CAPTCHAs cannot be solved automatically
- Complex SPAs may need more steps
- Rate limiting on some websites

## 📄 License

MIT License - See LICENSE file for details

## 🙏 Credits

- **DeepSeek AI** - DeepSeek R1 reasoning model
- **Haotian Liu** - LLaVA vision model
- **Ollama** - Local LLM inference
- **Microsoft** - Playwright browser automation

---

**Created with Claude Code** 🤖

Generated: 2025-11-16
