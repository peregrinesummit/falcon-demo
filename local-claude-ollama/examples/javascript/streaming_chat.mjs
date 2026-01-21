/**
 * Streaming chat example with Ollama backend.
 *
 * Prerequisites:
 *   npm install @anthropic-ai/sdk
 *
 * Usage:
 *   node streaming_chat.mjs
 */

import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic({
  baseURL: "http://localhost:11434",
  apiKey: "ollama",
});

async function main() {
  console.log("Streaming response:");
  console.log("-".repeat(40));

  const stream = client.messages.stream({
    model: "qwen3-coder",
    max_tokens: 1024,
    messages: [
      {
        role: "user",
        content: "Explain async/await in JavaScript with examples.",
      },
    ],
  });

  // Process stream events
  for await (const event of stream) {
    if (
      event.type === "content_block_delta" &&
      event.delta.type === "text_delta"
    ) {
      process.stdout.write(event.delta.text);
    }
  }

  console.log();
  console.log("-".repeat(40));

  // Get final message
  const finalMessage = await stream.finalMessage();
  console.log(`Total tokens: ${finalMessage.usage.input_tokens + finalMessage.usage.output_tokens}`);
}

main().catch(console.error);
