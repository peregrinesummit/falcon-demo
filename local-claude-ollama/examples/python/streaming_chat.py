#!/usr/bin/env python3
"""
Streaming chat example with Ollama backend.

Prerequisites:
    pip install anthropic

Usage:
    python streaming_chat.py
"""

import anthropic


def main():
    client = anthropic.Anthropic(
        base_url="http://localhost:11434",
        api_key="ollama",
    )

    print("Streaming response:")
    print("-" * 40)

    # Use streaming for real-time output
    with client.messages.stream(
        model="qwen3-coder",
        max_tokens=1024,
        messages=[
            {
                "role": "user",
                "content": "Explain the concept of recursion with a simple example.",
            }
        ],
    ) as stream:
        for text in stream.text_stream:
            print(text, end="", flush=True)

    print()
    print("-" * 40)


if __name__ == "__main__":
    main()
