# .agents Directory

This directory follows the [.agents Protocol](https://dotagentsprotocol.com/) — an open standard for AI agent configuration. It provides structured, version-controlled context for AI agents working in this repository.

## Contents

| File / Directory | Purpose |
|------------------|---------|
| `agents.md` | Main agent instructions (AGENTS.md compatible). Points to repository guidelines. |
| `memories/` | Persistent project context (architecture decisions, key patterns). |
| `skills/` | Workflow skills. Currently: `linear-workflow` (Linear issue tracking). |

## For Agents

- **Primary instructions**: Read [agents.md](agents.md) first. It references [AGENTS.md](../AGENTS.md) in the repository root for full development guidelines.
- **Architecture context**: See [memories/architecture.md](memories/architecture.md) for data models, services, and data flow.
- **Linear workflow**: See [skills/linear-workflow/SKILL.md](skills/linear-workflow/SKILL.md) when working on feature branches or plans.
- **Human docs**: See [README.md](../README.md) for project overview, features, and setup.

## For Tools That Read Root Only

Some tools (e.g., Cursor) read [AGENTS.md](../AGENTS.md) at the repository root. That file contains the full agent guidelines. This `.agents/` directory supplements it with modular structure and architecture memories.
