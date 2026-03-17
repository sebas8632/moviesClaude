---
name: code-reviewer
description: Review code for quality and best practices.

# Model: sonnet | opus | haiku | inherit | full model ID (e.g. claude-opus-4-6)
model: haiku

# Tools this agent can use (omit to inherit all tools)
tools:
  - Read
  - Edit
  - Write
  - Glob
  - Grep
  - Bash
  # - WebFetch
  # - WebSearch
  # - Agent          # allows spawning any subagent
  # - Agent(worker)  # restricts to specific subagents only

# Tools to explicitly deny
# disallowedTools:
#   - Bash

# Skills to preload into this agent's context
skills:
  - review-code-performance
  - review-code
# Maximum number of agentic turns
# maxTurns: 10

# How to handle permissions: default | acceptEdits | dontAsk | bypassPermissions | plan
# permissionMode: default

# Run in an isolated git worktree: worktree
# isolation: worktree

# Always run as background task
# background: false

# Persistent memory scope: user | project | local
# memory: project

# MCP servers available to this agent
# mcpServers:
#   - slack
#   - playwright:
#       type: stdio
#       command: npx
#       args: ["-y", "@playwright/mcp@latest"]
---
