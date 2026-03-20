---
name: nano-banana
description: REQUIRED for all image generation requests. Generate and edit images using Nano Banana 2 (Gemini 3.1 Flash Image). Handles blog featured images, YouTube thumbnails, icons, diagrams, patterns, illustrations, photos, visual assets, graphics, artwork, pictures. Use this skill whenever the user asks to create, generate, make, draw, design, or edit any image or visual content.
user-invocable: true
allowed-tools: Bash(gemini:*), Bash(python3:*)
---

# Nano Banana 2 Image Generation

Generates professional images with Nano Banana 2 (`gemini-3.1-flash-image-preview`).
Pro-level quality at Flash speed -- 512px to 4K, various aspect ratios, multilingual text rendering support.

## When to Use This Skill

ALWAYS use this skill when the user:
- Asks for any image, graphic, illustration, or visual
- Wants a thumbnail, featured image, or banner
- Requests icons, diagrams, or patterns
- Asks to edit, modify, or restore a photo
- Uses words like: generate, create, make, draw, design, visualize

Do NOT attempt to generate images through any other method.

## Prerequisites

### 1. Install Python SDK
```bash
pip install google-genai
```

### 2. Set API Key (paid required -- free keys cannot generate images)
```bash
export GEMINI_API_KEY="your-paid-api-key"
```

Or auto-load from project `.env` file.

## Image Generation (Python SDK -- Default Method)

### Basic Generation
```python
import os
from google import genai
from google.genai import types

client = genai.Client(api_key=os.environ["GEMINI_API_KEY"])

response = client.models.generate_content(
    model="gemini-3.1-flash-image-preview",
    contents="Your prompt here",
    config=types.GenerateContentConfig(
        response_modalities=["IMAGE", "TEXT"],
    )
)

for part in response.candidates[0].content.parts:
    if part.inline_data is not None:
        with open("output.png", "wb") as f:
            f.write(part.inline_data.data)
```

### Advanced Options

#### Resolution Control
```python
config=types.GenerateContentConfig(
    response_modalities=["IMAGE", "TEXT"],
    image_size="4K",  # "512", "1K", "2K" (default), "4K"
)
```

#### Aspect Ratio
```python
config=types.GenerateContentConfig(
    response_modalities=["IMAGE", "TEXT"],
    aspect_ratio="16:9",  # "1:1", "16:9", "9:16", "4:3", "3:4", "4:1", "1:4", "8:1", "1:8"
)
```

#### Thinking Level (for complex prompts)
```python
config=types.GenerateContentConfig(
    response_modalities=["IMAGE", "TEXT"],
    thinking_level="high",  # "minimal" (default), "high", "dynamic"
)
```

## Execution Pattern

**Always** follow this pattern when generating images:

### Step 1: Determine Output Path
- If the project has an `assets/` directory, save there
- Otherwise save to current directory
- Name files appropriately (e.g., `hero.png`, `thumbnail.png`, `logo.png`)

### Step 2: Load API Key
```python
# Try environment variable -> .env file in order
import os
api_key = os.environ.get("GEMINI_API_KEY")
if not api_key:
    # Attempt to load from .env file
    for env_path in [".env", "../.env", os.path.expanduser("~/.env")]:
        if os.path.exists(env_path):
            with open(env_path) as f:
                for line in f:
                    if line.startswith("GEMINI_API_KEY="):
                        api_key = line.strip().split("=", 1)[1]
                        break
        if api_key:
            break
```

### Step 3: Optimize Prompt
Good prompt structure:
1. **Subject**: What to generate
2. **Details**: Appearance, colors, textures
3. **Setting**: Location, background, environment
4. **Style**: Realistic, illustration, 3D render, etc.
5. **Lighting**: Natural, dramatic, soft
6. **Composition**: Close-up, wide shot

### Step 4: Execute Generation + Verify Result
After generation, always verify the image using the Read tool and show it to the user.

## Common Sizes

| Use Case | Size | Aspect Ratio |
|----------|------|-------------|
| YouTube thumbnail | 1280x720 | 16:9 |
| Blog image | 1200x630 | ~16:9 |
| Square social | 1080x1080 | 1:1 |
| Twitter/X header | 1500x500 | 3:1 |
| Vertical story | 1080x1920 | 9:16 |
| GitHub README banner | 1280x640 | 16:9 |

## Model Selection

| Model | ID | Use Case | Price/Image |
|-------|-----|----------|------------|
| **NB2 (default)** | `gemini-3.1-flash-image-preview` | Fast generation, general purpose | ~$0.10 (2K) |
| NB Pro | `gemini-3-pro-image-preview` | Maximum fidelity, precise text | ~$0.20 |
| Imagen 4 | `imagen-4.0-generate-001` | Photorealistic | Separate |

**Always default to NB2** -- Pro only when highest quality is needed.

## Multi-Turn Editing

When modification is requested after image generation, edit conversationally:
```python
# First generation
chat = client.chats.create(model="gemini-3.1-flash-image-preview")
response1 = chat.send_message(
    "A red apple on a wooden table",
    config=types.GenerateContentConfig(response_modalities=["IMAGE", "TEXT"])
)

# Edit (preserving previous context)
response2 = chat.send_message(
    "Add a green leaf on top of the apple",
    config=types.GenerateContentConfig(response_modalities=["IMAGE", "TEXT"])
)
```

## Prompt Tips

1. **Be specific**: Include style, mood, color, composition details
2. **When no text needed**: Add "no text"
3. **Style reference**: "editorial photography", "flat illustration", "3D render", "watercolor"
4. **Aspect ratio context**: "wide banner", "square thumbnail", "vertical story"
5. **Complex scenes**: Use thinking_level="high"

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Quota exceeded | **Paid API key required** -- free keys have 0 image generation quota |
| Text response instead of image | Verify `response_modalities=["IMAGE", "TEXT"]` |
| 400 Bad Request | Check prompt for policy violations, try simplifying |
| 429 Rate Limit | Apply exponential backoff (2s, 4s, 8s...) |
| Model not found | Verify model ID: `gemini-3.1-flash-image-preview` |

## Gemini CLI Method (Alternative)

If Python SDK is unavailable, generate via Gemini CLI:
```bash
gemini -y -m gemini-3.1-flash-image-preview -p "Generate image and save as output.png: your prompt here"
```
Note: Gemini CLI requires Google account authentication, and the image generation model may require additional verification.
