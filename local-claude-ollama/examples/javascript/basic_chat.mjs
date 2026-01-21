/**
 * Basic chat example using Anthropic JavaScript SDK with Ollama backend.
 *
 * Prerequisites:
 *   npm install @anthropic-ai/sdk
 *
 * Usage:
 *   node basic_chat.mjs
 */

import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic({
  baseURL: "http://localhost:11434",
  apiKey: "ollama", // Any value works, Ollama doesn't validate
});

async function main() {
  const message = await client.messages.create({
    model: "qwen3-coder", // Or "glm-4.7-flash" if you have it
    max_tokens: 1024,
    messages: [
      {
        role: "user",
        content: "Write a JavaScript function to check if a string is a palindrome.",
      },
    ],
  });

  console.log("Response:");
  console.log("-".repeat(40));

  for (const block of message.content) {
    if (block.type === "text") {
      console.log(block.text);
    }
  }

  console.log("-".repeat(40));
  console.log(`Stop reason: ${message.stop_reason}`);
  console.log(`Input tokens: ${message.usage.input_tokens}`);
  console.log(`Output tokens: ${message.usage.output_tokens}`);
}

main().catch(console.error);
