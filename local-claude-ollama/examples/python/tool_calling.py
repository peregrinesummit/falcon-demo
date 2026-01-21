#!/usr/bin/env python3
"""
Tool calling (function calling) example with Ollama backend.

This demonstrates how to define tools that the model can use.
Note: Tool calling support depends on the model capabilities.

Prerequisites:
    pip install anthropic

Usage:
    python tool_calling.py
"""

import ast
import json
import operator

import anthropic


def get_weather(location: str, unit: str = "celsius") -> dict:
    """Simulated weather API call."""
    # In real use, this would call an actual weather API
    weather_data = {
        "location": location,
        "temperature": 22,
        "unit": unit,
        "condition": "sunny",
        "humidity": 45,
    }
    return weather_data


def safe_calculate(expression: str) -> dict:
    """
    Safely evaluate a math expression using AST parsing.
    Only supports basic arithmetic: +, -, *, /, **, %
    """
    # Supported operators
    ops = {
        ast.Add: operator.add,
        ast.Sub: operator.sub,
        ast.Mult: operator.mul,
        ast.Div: operator.truediv,
        ast.Pow: operator.pow,
        ast.Mod: operator.mod,
        ast.USub: operator.neg,
    }

    def _eval(node):
        if isinstance(node, ast.Constant):  # Numbers
            return node.value
        elif isinstance(node, ast.BinOp):  # Binary operations
            left = _eval(node.left)
            right = _eval(node.right)
            op_type = type(node.op)
            if op_type not in ops:
                raise ValueError(f"Unsupported operator: {op_type.__name__}")
            return ops[op_type](left, right)
        elif isinstance(node, ast.UnaryOp):  # Unary operations (e.g., -5)
            operand = _eval(node.operand)
            op_type = type(node.op)
            if op_type not in ops:
                raise ValueError(f"Unsupported operator: {op_type.__name__}")
            return ops[op_type](operand)
        elif isinstance(node, ast.Expression):
            return _eval(node.body)
        else:
            raise ValueError(f"Unsupported expression type: {type(node).__name__}")

    try:
        tree = ast.parse(expression, mode="eval")
        result = _eval(tree)
        return {"expression": expression, "result": result}
    except Exception as e:
        return {"expression": expression, "error": str(e)}


# Define available tools
tools = [
    {
        "name": "get_weather",
        "description": "Get the current weather for a location",
        "input_schema": {
            "type": "object",
            "properties": {
                "location": {
                    "type": "string",
                    "description": "The city and country, e.g., 'London, UK'",
                },
                "unit": {
                    "type": "string",
                    "enum": ["celsius", "fahrenheit"],
                    "description": "Temperature unit",
                },
            },
            "required": ["location"],
        },
    },
    {
        "name": "calculate",
        "description": "Perform a mathematical calculation (supports +, -, *, /, **, %)",
        "input_schema": {
            "type": "object",
            "properties": {
                "expression": {
                    "type": "string",
                    "description": "The math expression to evaluate, e.g., '2 + 2 * 3'",
                }
            },
            "required": ["expression"],
        },
    },
]


def process_tool_call(tool_name: str, tool_input: dict) -> str:
    """Execute a tool and return the result."""
    if tool_name == "get_weather":
        result = get_weather(**tool_input)
    elif tool_name == "calculate":
        result = safe_calculate(**tool_input)
    else:
        result = {"error": f"Unknown tool: {tool_name}"}

    return json.dumps(result)


def main():
    client = anthropic.Anthropic(
        base_url="http://localhost:11434",
        api_key="ollama",
    )

    # Initial user message that might trigger tool use
    messages = [
        {
            "role": "user",
            "content": "What's the weather in Tokyo? Also, what's 15 * 7 + 23?",
        }
    ]

    print("User: What's the weather in Tokyo? Also, what's 15 * 7 + 23?")
    print("-" * 40)

    # First API call - model decides which tools to use
    response = client.messages.create(
        model="glm-4.7-flash",  # GLM-4.7-Flash has good tool calling support
        max_tokens=1024,
        tools=tools,
        messages=messages,
    )

    print(f"Initial response - Stop reason: {response.stop_reason}")

    # Process tool calls if any
    while response.stop_reason == "tool_use":
        # Find tool use blocks
        tool_use_blocks = [
            block for block in response.content if block.type == "tool_use"
        ]

        # Add assistant's response to messages
        messages.append({"role": "assistant", "content": response.content})

        # Process each tool call
        tool_results = []
        for tool_use in tool_use_blocks:
            print(f"\nTool called: {tool_use.name}")
            print(f"  Input: {tool_use.input}")

            result = process_tool_call(tool_use.name, tool_use.input)
            print(f"  Result: {result}")

            tool_results.append(
                {
                    "type": "tool_result",
                    "tool_use_id": tool_use.id,
                    "content": result,
                }
            )

        # Add tool results and get next response
        messages.append({"role": "user", "content": tool_results})

        response = client.messages.create(
            model="glm-4.7-flash",
            max_tokens=1024,
            tools=tools,
            messages=messages,
        )

    # Print final response
    print("\n" + "-" * 40)
    print("Final response:")
    for block in response.content:
        if hasattr(block, "text"):
            print(block.text)


if __name__ == "__main__":
    main()
