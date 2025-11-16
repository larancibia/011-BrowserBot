# 🤖 Guía: Web Agent con DeepSeek R1 + Vision

## 📦 Archivos Necesarios

Todos estos archivos ya están en `/home/luis/`:

1. **`ollama-web-agent-reasoning.py`** - El agente principal
2. **`run-web-agent-turboscribe.sh`** - Script de ejecución automática
3. **`setup-ollama-agent.sh`** - Setup inicial (opcional)

## 🚀 Ejecución Rápida (3 comandos)

### En tu máquina local con RTX 3090:

```bash
# 1. Iniciar Ollama (terminal 1)
ollama serve

# 2. Ejecutar el agente (terminal 2)
cd /home/luis
./run-web-agent-turboscribe.sh
```

El script automáticamente:
- ✅ Verifica que Ollama esté corriendo
- ✅ Descarga DeepSeek R1:8b (~8GB) si no existe
- ✅ Descarga LLaVA 7B (~4.5GB) si no existe
- ✅ Ejecuta el agente
- ✅ Guarda cookies en `/home/luis/turboscribe-mcp/cookies.json`

## 🧠 ¿Qué hace el agente?

### Arquitectura de dos etapas:

**Etapa 1: Visión (LLaVA 7B)**
```
Screenshot → LLaVA → "Veo un botón 'Sign in with Google'
                       en la posición (640, 200)"
```

**Etapa 2: Razonamiento (DeepSeek R1:8b)**
```
Descripción visual + Tarea → DeepSeek R1 → Chain-of-thought:
"Necesito loguearme → Veo botón de Google OAuth →
 Debería hacer click → Selector: button.google-oauth →
 Coordenadas fallback: (640, 200) → Confianza: 95%"
```

**Etapa 3: Ejecución**
```
Decisión → Playwright → Click en botón → Esperar resultado
```

## 📊 Flujo Completo

```
┌─────────────────────────────────────────────────┐
│  1. Abre navegador → turboscribe.ai             │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  2. Toma screenshot de la página                │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  3. LLaVA analiza imagen:                       │
│     "Hay un botón 'Sign in with Google'         │
│      en la parte superior central"              │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  4. DeepSeek R1 razona:                         │
│     💭 "Mi tarea es loguearme"                   │
│     💭 "Veo botón de Google OAuth"               │
│     💭 "Mejor acción: click"                     │
│     💭 "Confianza: 90%"                          │
│     → Decisión: {"action": "click", ...}        │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  5. Ejecuta acción:                             │
│     🖱️ Click en botón Google                     │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  6. Espera 2s → Repite desde paso 2             │
│     (máximo 20 pasos)                           │
└─────────────────────────────────────────────────┘
```

## 🎮 Uso Manual Avanzado

Si querés más control:

```bash
# Ejecutar con parámetros personalizados
python3 /home/luis/ollama-web-agent-reasoning.py \
    --task "Login to turboscribe.ai with Google OAuth" \
    --url "https://turboscribe.ai" \
    --reasoning-model "deepseek-r1:8b" \
    --vision-model "llava:7b" \
    --max-steps 20 \
    --save-cookies "/home/luis/turboscribe-mcp/cookies.json"

# Modo headless (sin UI)
python3 /home/luis/ollama-web-agent-reasoning.py \
    --task "..." \
    --headless

# Más verbose
python3 /home/luis/ollama-web-agent-reasoning.py \
    --task "..." \
    # verbose está activado por default

# Menos verbose
python3 /home/luis/ollama-web-agent-reasoning.py \
    --task "..." \
    --quiet
```

## 📝 Ejemplo de Output

```
🎯 Tarea: Login to turboscribe.ai with Google OAuth
🌐 URL: https://turboscribe.ai
🧠 Modelo razonamiento: deepseek-r1:8b
👁️  Modelo visión: llava:7b
============================================================
📦 Modelos disponibles: deepseek-r1:8b, llava:7b
✅ Modelos listos
🔗 Navegando a https://turboscribe.ai...

============================================================
PASO 1/20
============================================================
👁️  Analizando screenshot con visión...
📸 Descripción: This web page shows the TurboScribe landing page with a large "Sign in with Google" button in the center...
🧠 Razonando próxima acción...
💭 Razonamiento: I need to login. I see a Google OAuth button. I should click it to authenticate...
🎯 Acción: click - Confianza: 95%
🖱️  Click en selector: button.google-signin
✅ Click exitoso

============================================================
PASO 2/20
============================================================
👁️  Analizando screenshot con visión...
📸 Descripción: Google OAuth popup appeared with email input field...
🧠 Razonando próxima acción...
💭 Razonamiento: Google OAuth opened. I should wait for user to complete manual login...
🎯 Acción: wait - Confianza: 100%
⏳ Esperando 5s

[... continúa hasta completar el login ...]

✅ TAREA COMPLETADA

🍪 Cookies guardadas: /home/luis/turboscribe-mcp/cookies.json

📊 RESUMEN DE EJECUCIÓN
============================================================
1. ✅ click (conf: 95%)
2. ✅ wait (conf: 100%)
3. ✅ wait (conf: 100%)
4. ✅ done (conf: 100%)

💭 Total razonamientos: 4
✅ Acciones exitosas: 4/4
```

## 🔧 Troubleshooting

### Problema 1: "Error conectando a Ollama"
**Solución:**
```bash
# En otra terminal:
ollama serve
```

### Problema 2: "Modelo no encontrado"
**Solución:** El script los descarga automáticamente, pero si falla:
```bash
ollama pull deepseek-r1:8b
ollama pull llava:7b
```

### Problema 3: "Error en Playwright"
**Solución:**
```bash
pip3 install --user playwright httpx
python3 -m playwright install chromium
```

### Problema 4: VRAM insuficiente
**Solución:** DeepSeek R1:8b usa ~8GB. Si tu GPU está ocupada:
```bash
# Ver uso de GPU
nvidia-smi

# Matar procesos que usen GPU si es necesario
```

### Problema 5: El agente no encuentra el botón
**Diagnóstico:** Revisa el screenshot y la descripción de visión
**Solución:**
- Aumentar `--max-steps`
- Ajustar la tarea para ser más específica
- Revisar logs del razonamiento para ver qué decidió

## 🎯 Próximos Usos

Una vez que tengas las cookies, podés usarlas en autoscribe:

```bash
# Verificar cookies
cat /home/luis/turboscribe-mcp/cookies.json | jq .

# Copiar al servidor
scp /home/luis/turboscribe-mcp/cookies.json \
    usuario@servidor:/home/luis/turboscribe-mcp/

# Usar en autoscribe
curl -X POST https://autoscribe.guanacolabs.com/api/upload \
     -H "Cookie: $(cat /home/luis/turboscribe-mcp/cookies.json | jq -r '.[] | "\(.name)=\(.value)"' | tr '\n' ';')"
```

## 💡 Tips

1. **Primera ejecución:** NO uses `--headless`, así ves cómo funciona
2. **Google OAuth:** El agente detectará el popup pero necesitarás completar el login manualmente
3. **Paciencia:** Cada paso tarda ~5-10 segundos (análisis de imagen + razonamiento)
4. **Logs:** El agente muestra el razonamiento completo para debugging

## 📚 Modelos Alternativos

Si querés experimentar:

```bash
# Modelo de visión alternativo (más grande, más preciso)
ollama pull llava:13b
python3 ... --vision-model llava:13b

# Modelo de razonamiento alternativo
ollama pull deepseek-r1:14b  # Requiere ~14GB VRAM
python3 ... --reasoning-model deepseek-r1:14b

# Modelo sin reasoning (más rápido pero menos inteligente)
ollama pull qwen2.5:7b
python3 ... --reasoning-model qwen2.5:7b
```

## 🚀 Bonus: Otras Tareas

El agente funciona para cualquier tarea web:

```bash
# Ejemplo: Buscar en Google
python3 /home/luis/ollama-web-agent-reasoning.py \
    --task "Search for 'DeepSeek R1 benchmarks' on Google" \
    --url "https://google.com" \
    --max-steps 5

# Ejemplo: Llenar formulario
python3 /home/luis/ollama-web-agent-reasoning.py \
    --task "Fill contact form with name 'Test User' and email 'test@example.com'" \
    --url "https://example.com/contact" \
    --max-steps 10
```

---

**¿Listo para empezar? Ejecutá el script en tu máquina local! 🚀**
