#!/usr/bin/env python3
"""
Multi-turn conversation example demonstrating context persistence.

Prerequisites:
    pip install anthropic

Usage:
    python multi_turn_conversation.py
"""

import anthropic


def chat(client, messages: list, user_input: str) -> str:
    """Send a message and get a response, maintaining conversation history."""
    messages.append({"role": "user", "content": user_input})

    response = client.messages.create(
        model="qwen3-coder",
        max_tokens=1024,
        system="You are a helpful coding assistant. Be concise but thorough.",
        messages=messages,
    )

    # Extract text from response
    assistant_text = ""
    for block in response.content:
        if hasattr(block, "text"):
            assistant_text += block.text

    # Add assistant response to history
    messages.append({"role": "assistant", "content": assistant_text})

    return assistant_text


def main():
    client = anthropic.Anthropic(
        base_url="http://localhost:11434",
        api_key="ollama",
    )

    # Conversation history
    messages = []

    print("Multi-turn Conversation Demo")
    print("=" * 40)
    print("Type 'quit' to exit, 'clear' to reset conversation")
    print()

    while True:
        try:
            user_input = input("You: ").strip()

            if not user_input:
                continue

            if user_input.lower() == "quit":
                print("Goodbye!")
                break

            if user_input.lower() == "clear":
                messages = []
                print("[Conversation cleared]")
                continue

            response = chat(client, messages, user_input)
            print(f"\nAssistant: {response}\n")

        except KeyboardInterrupt:
            print("\nGoodbye!")
            break
        except Exception as e:
            print(f"\nError: {e}\n")


if __name__ == "__main__":
    main()
