#!/bin/zsh

DIFF=$(git -C . diff --staged --no-color)

PAYLOAD=$(echo "$DIFF" | jq -Rs '{
  "model": "llama3.1-8b",
  "stream": false,
  "temperature": 0,
  "max_completion_tokens": 100,
  "top_p": 1,
  "seed": 0,
  "messages": [
    {
      "role": "system",
      "content": "You are a commit message generator. Output ONLY the raw commit message. No reasoning, no explanations, no markdown, no code blocks, no backticks. Just the single line commit message in conventional commit format."
    },
    {
      "role": "user",
      "content": ("Generate a git commit message for these staged changes:\n\n" + .)
    }
  ]
}')

RESPONSE=$(echo "$PAYLOAD" | curl -s "https://api.cerebras.ai/v1/chat/completions" \
  --location \
  -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${CEREBRAS_API_KEY}" \
  -d @- 2>&1)

COMMIT_MSG=$(echo "$RESPONSE" | jq -r '.choices[0].message.content' | head -n 1)

if [ -z "$COMMIT_MSG" ] || [ "$COMMIT_MSG" = "null" ]; then
  echo "Error: Empty commit message"
  exit 1
fi

echo "$COMMIT_MSG" > /tmp/commit_msg
GIT_EDITOR=nvim git commit -e --no-verify -F /tmp/commit_msg
