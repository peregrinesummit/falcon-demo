/**
 * Multi-turn conversation example with readline interface.
 *
 * Prerequisites:
 *   npm install @anthropic-ai/sdk readline
 *
 * Usage:
 *   node multi_turn.mjs
 */

import Anthropic from "@anthropic-ai/sdk";
import * as readline from "readline";

const client = new Anthropic({
  baseURL: "http://localhost:11434",
  apiKey: "ollama",
});

// Conversation history
const messages = [];

async function chat(userInput) {
  messages.push({ role: "user", content: userInput });

  const response = await client.messages.create({
    model: "qwen3-coder",
    max_tokens: 1024,
    system: "You are a helpful coding assistant. Be concise but thorough.",
    messages: messages,
  });

  // Extract text from response
  let assistantText = "";
  for (const block of response.content) {
    if (block.type === "text") {
      assistantText += block.text;
    }
  }

  // Add to history
  messages.push({ role: "assistant", content: assistantText });

  return assistantText;
}

async function main() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  console.log("Multi-turn Conversation Demo");
  console.log("=".repeat(40));
  console.log("Type 'quit' to exit, 'clear' to reset conversation");
  console.log();

  const prompt = () => {
    rl.question("You: ", async (input) => {
      const userInput = input.trim();

      if (!userInput) {
        prompt();
        return;
      }

      if (userInput.toLowerCase() === "quit") {
        console.log("Goodbye!");
        rl.close();
        return;
      }

      if (userInput.toLowerCase() === "clear") {
        messages.length = 0;
        console.log("[Conversation cleared]");
        prompt();
        return;
      }

      try {
        const response = await chat(userInput);
        console.log(`\nAssistant: ${response}\n`);
      } catch (error) {
        console.error(`\nError: ${error.message}\n`);
      }

      prompt();
    });
  };

  prompt();
}

main();
