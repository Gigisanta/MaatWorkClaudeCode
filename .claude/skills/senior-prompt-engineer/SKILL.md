---
name: senior-prompt-engineer
description: Prompt engineering skill for LLM optimization, prompt patterns, structured outputs, and AI product development. Expertise in Claude, prompt design patterns, few-shot learning, chain-of-thought, and AI evaluation. Includes RAG optimization, agent design, and LLM system architecture. Use when building AI products, optimizing LLM performance, designing agentic systems, or implementing advanced prompting techniques.
---

# Senior Prompt Engineer

Expert prompt engineering skill for production-grade AI systems.

## Quick Start

```bash
# Core Tools
python scripts/prompt_optimizer.py --input data/ --output results/
python scripts/rag_evaluator.py --target project/ --analyze
python scripts/agent_orchestrator.py --config config.yaml --deploy
```

## Core Expertise

- Prompt patterns (chain-of-thought, few-shot, zero-shot)
- Structured outputs (JSON schema, constrained decoding)
- LLM evaluation (RAGAS, Giskard, custom evals)
- RAG optimization (chunking, embedding, retrieval)
- Agent design (tool use, multi-step reasoning, memory)
- Prompt optimization (evolution, discrimination, attribution)

## Prompt Patterns

### Chain-of-Thought
```
Ask the model to explain its reasoning step by step before giving the final answer.
```

### Few-Shot Learning
```
Provide 2-5 examples of input → desired output before the target query.
```

### Zero-Shot with Structure
```
Format the output explicitly: "Return JSON with fields: name, age, role"
```

### Constrained Decoding
```
"Output ONLY valid JSON. No markdown, no explanation, no markdown code fences."
```

## Evaluation Frameworks

### RAGAS (RAG Assessment)
```python
from ragas import evaluate
from ragas.metrics import faithfulness, answer_relevancy, context_precision, context_recall

results = evaluate(dataset, metrics=[faithfulness, answer_relevancy])
```

### Custom Evals
```python
def correctness_eval(predicted: str, expected: str) -> float:
    # Normalized string similarity or LLM-as-judge
    return normalized_similarity(predicted, expected)
```

## LLM Frameworks

| Framework | Use Case |
|----------|----------|
| **LangChain** | Chains, agents, memory |
| **LlamaIndex** | RAG-focused data ingestion |
| **DSPy** | Compiler-based prompt optimization |
| **Outlines** | Constrained generation |

## RAG Optimization

### Chunking Strategies

| Strategy | Chunk Size | Use Case |
|----------|-----------|----------|
| Fixed | 512 tokens | General purpose |
| Semantic | ~512 tokens | Coherent paragraphs |
| Recursive | Variable | Code, nested docs |

### Retrieval Patterns

- **Hybrid search**: sparse (BM25) + dense (embeddings)
- **ColBERT**: late interaction for reranking
- **Query expansion**: expand with synonyms, hyponyms

## Agent Patterns

### Tool Use Agent
```
User → Model → [Tool: search] → Tool Result → Model → Response
```

### Memory Agent
```
User → Model → [Memory: read] → Context → Model → Response → [Memory: write]
```

## Reference Documentation

- `references/prompt_engineering_patterns.md` — Core patterns
- `references/llm_evaluation_frameworks.md` — Eval methodology
- `references/agentic_system_design.md` — Agent architecture

## Common Commands

```bash
# Prompt optimization
python scripts/prompt_optimizer.py --input prompts/ --output optimized/

# RAG evaluation
python scripts/rag_evaluator.py --retriever hybrid --top-k 5

# Agent orchestration
python scripts/agent_orchestrator.py --config config.yaml --test
```
