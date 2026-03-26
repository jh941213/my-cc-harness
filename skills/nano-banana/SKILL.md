---
name: nano-banana
description: REQUIRED for all image generation requests. Generate and edit images using Gemini CLI with image models. Handles blog featured images, YouTube thumbnails, icons, diagrams, patterns, illustrations, photos, visual assets, graphics, artwork, pictures. Use this skill whenever the user asks to create, generate, make, draw, design, or edit any image or visual content.
user-invocable: true
allowed-tools: Bash(gemini:*)
---

# Nano Banana Image Generation

Gemini CLI + 이미지 모델로 프로페셔널 이미지를 생성합니다.
Google 계정 인증 기반 — API 키 불필요. 512px~4K, 다양한 종횡비, 다국어 텍스트 렌더링 지원.

## 모델 선택

| 모델 | ID | 용도 | 특징 |
|------|-----|------|------|
| **NB2 (기본)** | `gemini-3.1-flash-image-preview` | 빠른 생성, 대량 작업 | Flash 속도, 고효율 |
| NB Pro | `gemini-3-pro-image-preview` | 전문 에셋, 정밀 텍스트 | 고급 추론(사고), 최고 충실도 |
| NB (경량) | `gemini-2.5-flash-image` | 짧은 지연 시간, 대량 배치 | 속도 최적화 |

**기본은 항상 NB2 (`gemini-3.1-flash-image-preview`)** — Pro는 복잡한 텍스트 렌더링/전문 에셋에만.

## When to Use This Skill

ALWAYS use this skill when the user:
- Asks for any image, graphic, illustration, or visual
- Wants a thumbnail, featured image, or banner
- Requests icons, diagrams, or patterns
- Asks to edit, modify, or restore a photo
- Uses words like: generate, create, make, draw, design, visualize

Do NOT attempt to generate images through any other method.

## 사전 준비

Gemini CLI가 설치되어 있고 Google 계정으로 인증 완료된 상태여야 합니다.

```bash
# 설치 확인
gemini --version

# 인증 상태 확인 (이미 인증됨)
gemini -p "hello"
```

## 이미지 생성 (Gemini CLI — 기본 방법)

### 기본 생성
```bash
gemini -y -m gemini-3.1-flash-image-preview \
  -p "Generate an image: 프롬프트 여기에. Save the image as output.png"
```

### 파일명 지정 생성
```bash
gemini -y -m gemini-3.1-flash-image-preview \
  -p "Generate an image: A modern minimalist logo for a tech startup. Save as logo.png"
```

### 이미지 편집 (기존 이미지 입력)
```bash
gemini -y -m gemini-3.1-flash-image-preview \
  -p "Edit this image: make the background blue. Save as edited.png" \
  -f input.png
```

## 실행 패턴

이미지 생성 시 **항상** 아래 패턴을 따릅니다:

### Step 1: 출력 경로 결정
- 프로젝트에 `assets/` 디렉토리가 있으면 그곳에 저장
- 없으면 현재 디렉토리에 저장
- 파일명은 용도에 맞게 (예: `hero.png`, `thumbnail.png`, `logo.png`)

### Step 2: 프롬프트 최적화
좋은 프롬프트 구조:
1. **주제**: 무엇을 생성할 것인가
2. **세부사항**: 외모, 색상, 질감
3. **설정**: 위치, 배경, 환경
4. **스타일**: 사실적, 일러스트, 3D 렌더 등
5. **조명**: 자연광, 극적인, 부드러운
6. **구도**: 클로즈업, 와이드 샷

### Step 3: 생성 실행
```bash
gemini -y -m gemini-3.1-flash-image-preview \
  -p "Generate an image: [최적화된 프롬프트]. Save the image as [경로/파일명.png]"
```

### Step 4: 결과 확인
생성 후 반드시 Read 도구로 이미지를 확인하고 사용자에게 보여줍니다.

## 일반 사이즈

| 용도 | 크기 | 프롬프트 힌트 |
|------|------|--------------|
| YouTube 썸네일 | 1280x720 | "wide 16:9 landscape" |
| 블로그 이미지 | 1200x630 | "wide banner format" |
| 정사각형 소셜 | 1080x1080 | "square format" |
| Twitter/X 헤더 | 1500x500 | "ultra-wide banner 3:1" |
| 세로 스토리 | 1080x1920 | "vertical portrait 9:16" |
| GitHub README 배너 | 1280x640 | "wide 2:1 banner" |

> 크기/종횡비는 프롬프트에 자연어로 포함하여 제어합니다.

## 프롬프트 팁

1. **구체적으로**: 스타일, 무드, 색상, 구도 세부사항 포함
2. **텍스트 불필요 시**: "no text" 추가
3. **스타일 참조**: "editorial photography", "flat illustration", "3D render", "watercolor"
4. **종횡비 맥락**: "wide banner", "square thumbnail", "vertical story"
5. **저장 지시**: 항상 프롬프트 끝에 "Save the image as [filename]" 포함
6. **영어 프롬프트 권장**: 이미지 프롬프트는 영어로 작성하면 품질이 더 좋음

## 멀티턴 편집

Gemini CLI는 `-f` 플래그로 기존 이미지를 입력하여 편집 가능:
```bash
# 원본 생성
gemini -y -m gemini-3.1-flash-image-preview \
  -p "Generate an image: A red apple on a wooden table. Save as apple.png"

# 편집 (원본 입력)
gemini -y -m gemini-3.1-flash-image-preview \
  -f apple.png \
  -p "Add a green leaf on top of the apple. Save as apple_edited.png"
```

## 트러블슈팅

| 문제 | 해결 |
|------|------|
| gemini: command not found | `npm i -g @anthropic-ai/gemini-cli` 또는 `brew install gemini` |
| 인증 오류 | `gemini auth login`으로 재인증 |
| 이미지 미생성 (텍스트만 응답) | 프롬프트에 "Generate an image:" 접두사 + "Save as X.png" 확인 |
| 400 Bad Request | 프롬프트에 정책 위반 내용 확인, 단순화 시도 |
| 모델 not found | 모델 ID 확인: `gemini-3.1-flash-image-preview` |
| 최고 품질 필요 | Pro 모델 사용: `gemini -y -m gemini-3-pro-image-preview` |
| 최저 지연 시간 필요 | 경량 모델: `gemini -y -m gemini-2.5-flash-image` |
