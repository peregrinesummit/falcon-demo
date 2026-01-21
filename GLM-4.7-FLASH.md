# GLM-4.7-Flash

A 30B Mixture-of-Experts model optimized for local deployment on consumer hardware.

## Model Specifications

| Specification | Value |
|---------------|-------|
| Total Parameters | 30B |
| Active Parameters | 3B per token |
| Architecture | Mixture of Experts (MoE) |
| Context Window | 198K tokens |
| Release Date | January 19, 2026 |
| Developer | Zhipu AI (Z.AI) |
| License | MIT |

## Ollama Variants

| Variant | Size | Notes |
|---------|------|-------|
| `glm-4.7-flash` (q4_K_M) | 19GB | Default, recommended |
| `glm-4.7-flash:q8_0` | 32GB | Higher quality |
| `glm-4.7-flash:bf16` | 60GB | Full precision |

**Requirement**: Ollama 0.14.3+

## Hardware Requirements

| Configuration | RAM Required |
|---------------|--------------|
| q4_K_M (default) | 24GB+ |
| q8_0 | 40GB+ |
| bf16 | 72GB+ |

Runs efficiently on:
- Apple Silicon (M1/M2/M3/M4) with 24GB+ unified memory
- NVIDIA RTX 3090/4090 (24GB VRAM)
- Any GPU with 24GB+ VRAM

Reported inference speed: **82 tokens/second** on M4 Max MacBook Pro.

## SWE-Bench Performance

SWE-bench Verified measures a model's ability to resolve real GitHub issues.

| Model | Parameters | SWE-bench Verified |
|-------|------------|-------------------|
| **GLM-4.7** (full) | 358B | **73.8%** |
| DeepSeek-V3.2 | 385B | 73.1% |
| MiMo-V2-Flash | 309B | 73.4% |
| Qwen3-30B-A3B | 30B | 69.6% |
| **GLM-4.7-Flash** | 30B | **59.2%** |
| Qwen3-Coder (480B) | 480B | 55.4% |

GLM-4.7-Flash at 30B parameters outperforms Qwen3-Coder's 480B model on SWE-bench.

## Full Benchmark Comparison

### GLM-4.7-Flash Benchmarks

| Benchmark | Score |
|-----------|-------|
| SWE-bench Verified | 59.2% |
| AIME 2025 | 91.6% |
| GPQA-Diamond | 75.2% |
| τ²-Bench | 79.5% |

### GLM-4.7 (Full Model) Benchmarks

| Benchmark | Score |
|-----------|-------|
| SWE-bench Verified | 73.8% |
| SWE-bench Multilingual | 66.7% |
| AIME 2025 | 95.7% |
| GPQA-Diamond | 85.7% |
| MMLU-Pro | 84.3% |
| LiveCodeBench-v6 | 84.9% |
| HLE (with tools) | 42.8% |
| Terminal Bench 2.0 | 41.0% |
| τ²-Bench | 87.4% |
| BrowseComp (w/ Context) | 67.5% |

## Comparison: 30B Class Models

| Model | Total Params | Active Params | SWE-bench |
|-------|--------------|---------------|-----------|
| **GLM-4.7-Flash** | 30B | 3B | 59.2% |
| Qwen3-30B-A3B | 30.5B | 3.3B | 69.6% |
| Nemotron-3-Nano-30B-A3B | 30B | 3.5B | — |

## Key Capabilities

- **Coding**: Strong performance on real-world GitHub issue resolution
- **Tool Calling**: Native support for function calling
- **UI Generation**: Highly rated for webpage and component generation
- **Long Context**: 198K token context window
- **Local Deployment**: Runs entirely offline on consumer hardware

## Limitations

- Reasoning capabilities lag behind specialized reasoning models
- Lower SWE-bench score than full-size frontier models (73%+ range)
- Requires pre-release Ollama (0.14.3+)

## API Pricing

| Input | Output |
|-------|--------|
| $0.07 / 1M tokens | $0.40 / 1M tokens |

Free tier available via Z.AI API.

## Sources

- [GLM-4.7 on Hugging Face](https://huggingface.co/zai-org/GLM-4.7)
- [GLM-4.7 Blog Post](https://z.ai/blog/glm-4.7)
- [GLM-4.7-Flash on Ollama](https://ollama.com/library/glm-4.7-flash)
- [Z.AI Developer Documentation](https://docs.z.ai/guides/llm/glm-4.7)
