#!/usr/bin/env bash
# Detect the technology stack of the current project directory

detect_stack() {
  local stacks=()
  local dir="${PROJECT_DIR:-$(pwd)}"

  # Node / JS ecosystem
  if [[ -f "$dir/package.json" ]]; then
    stacks+=("Node")
    # Check for specific frameworks
    if grep -q '"react"' "$dir/package.json" 2>/dev/null; then
      stacks+=("React")
    fi
    if [[ -f "$dir/next.config.js" || -f "$dir/next.config.ts" || -f "$dir/next.config.mjs" ]]; then
      stacks+=("Next.js")
    fi
    if grep -q '"express"' "$dir/package.json" 2>/dev/null; then
      stacks+=("Express")
    fi
    if grep -q '"vite"' "$dir/package.json" 2>/dev/null; then
      stacks+=("Vite")
    fi
  fi

  # Python
  if [[ -f "$dir/requirements.txt" || -f "$dir/pyproject.toml" || -f "$dir/setup.py" ]]; then
    stacks+=("Python")
    if grep -qE "fastapi|flask|django" "$dir/requirements.txt" "$dir/pyproject.toml" 2>/dev/null; then
      if grep -qi "fastapi" "$dir/requirements.txt" "$dir/pyproject.toml" 2>/dev/null; then
        stacks+=("FastAPI")
      elif grep -qi "django" "$dir/requirements.txt" "$dir/pyproject.toml" 2>/dev/null; then
        stacks+=("Django")
      elif grep -qi "flask" "$dir/requirements.txt" "$dir/pyproject.toml" 2>/dev/null; then
        stacks+=("Flask")
      fi
    fi
  fi

  # Go
  if [[ -f "$dir/go.mod" ]]; then
    stacks+=("Go")
  fi

  # Docker
  if [[ -f "$dir/Dockerfile" || -f "$dir/docker-compose.yml" || -f "$dir/docker-compose.yaml" ]]; then
    stacks+=("Docker")
  fi

  # Ruby / Rails
  if [[ -f "$dir/Gemfile" || -f "$dir/.ruby-version" ]]; then
    stacks+=("Ruby")
    if grep -q "rails" "$dir/Gemfile" 2>/dev/null; then
      stacks+=("Rails")
    fi
  fi

  # Rust
  if [[ -f "$dir/Cargo.toml" ]]; then
    stacks+=("Rust")
  fi

  # Java / JVM
  if [[ -f "$dir/pom.xml" || -f "$dir/build.gradle" || -f "$dir/build.gradle.kts" ]]; then
    stacks+=("JVM")
  fi

  # Output space-separated
  echo "${stacks[*]:-}"
}
