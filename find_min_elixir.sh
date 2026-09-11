#!/bin/bash

# Using official Elixir Docker tags which are much simpler and stable
VERSIONS=(
  "1.14-alpine"
  "1.15-alpine"
  "1.16-alpine"
  "1.17-alpine"
  "1.18-alpine"
  "1.19-alpine"
  "1.20-alpine"
)

# Clear old build artifacts locally before starting
rm -rf _build deps mix.lock

for v in "${VERSIONS[@]}"; do
  echo "Testing Elixir $v..."

  # Run compilation in an ephemeral Docker container using the official 'elixir' image
  docker run --rm -v "$(pwd)":/app -w /app elixir:$v sh -c "
    mix local.hex --force > /dev/null 2>&1 &&
    mix local.rebar --force > /dev/null 2>&1 &&
    mix deps.get > /dev/null 2>&1 &&
    mix compile --warnings-as-errors
  "

  # If the exit code is 0, the code compiled successfully
  if [ $? -eq 0 ]; then
    echo "========================================="
    echo "✅ SUCCESS! Minimum compatible version is: $v"
    echo "========================================="
    exit 0
  else
    echo "❌ Compilation failed on $v."
    # Clean up the volume so the next version starts fresh
    rm -rf _build deps mix.lock
  fi
done

echo "Codebase did not compile on any tested version."
exit 1
