#!/usr/bin/env python3
"""
Basic chat example using Anthropic Python SDK with Ollama backend.

Prerequisites:
    pip install anthropic

Usage:
    python basic_chat.py
"""

import anthropic


def main():
    # Configure client to use Ollama's Anthropic-compatible endpoint
    client = anthropic.Anthropic(
        base_url="http://localhost:11434",
        api_key="ollama",  # Any value works, Ollama doesn't validate
    )

    # Send a simple message
    message = client.messages.create(
        model="qwen3-coder",  # Or "glm-4.7-flash" if you have it
        max_tokens=1024,
        messages=[
            {"role": "user", "content": "Write a Python function to reverse a string."}
        ],
    )

    # Print the response
    print("Response:")
    print("-" * 40)
    for block in message.content:
        if hasattr(block, "text"):
            print(block.text)
    print("-" * 40)
    print(f"Stop reason: {message.stop_reason}")
    print(f"Input tokens: {message.usage.input_tokens}")
    print(f"Output tokens: {message.usage.output_tokens}")


if __name__ == "__main__":
    main()
