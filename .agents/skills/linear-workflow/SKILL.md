---
name: linear-workflow
description: ALWAYS check for linked Linear issue and follow conventions before starting work. Use when on a feature branch, when beginning any coding task, or when in plan mode.
---

# Linear Workflow

**MANDATORY:** Linear is the source of truth for planning, implementation status, blockers, and verification, not GitHub. Check for a linked Linear issue before starting work, and keep it current throughout the task. Linear–GitHub integration depends on correct branch names and issue updates.

## When to Use (invoke this skill FIRST)

- **Every** coding task, fix, or implementation—before any other actions
- **Plan mode**—when creating, writing, or drafting a plan (e.g. `.plan.md`). Do not skip Linear updates because you are "only planning."
- When switching to a new branch
- When the user asks you to implement, fix, change something, or create a plan

**Do not skip.** If you will edit code or create plans, invoke this skill and complete the workflow before touching files.

## Instructions

1. **Check branch** via `git branch --show-current`. Branch naming varies by tool:
   - **Linear-style**: `sam/ROUI-123-feature-name`, `ROUI-456-fix` (includes Linear ID directly)
   - **Issue-style**: `123-add-feature`, `issue92-fix` (GitHub issue number; Linear is linked elsewhere)

2. **Find the Linear issue**: Linear is always the source of truth—there will always be a Linear ticket linked somewhere. If the branch has a Linear ID (e.g. `ROUI-123`), use it directly. If the branch has an issue number (e.g. `123`), check the GitHub issue: Linear's integration leaves a comment in Markdown format `[linear-id](link)`, e.g. `[ROUI-123](https://linear.app/...)`. Parse that to get the Linear ID. Otherwise use `list_issues` with a `query` matching the branch/task.

3. **Confirm issue exists** via Linear MCP `get_issue` or `list_issues`. Once found, use that Linear issue for all updates.

4. **Set In Progress** via `save_issue` with `state: "In Progress"` before making code changes or creating plans.

5. **During planning**: Add comments via `save_comment`—when drafting a plan, summarize the approach or key decisions on the Linear issue.

6. **During implementation**: Include the full plan via `save_comment`—when implementing from a `.plan.md` file, paste the **entire plan content** as a Linear comment so reviewers have full context.

7. **Add comments as you work** via `save_comment`—implementations, decisions, blockers.

8. **Keep Linear current continuously**. If scope, status, blockers, implementation details, or verification results change, update the issue before continuing.

9. **Handle newly discovered issues explicitly**. If the current branch introduced the regression, create a Linear sub-issue under the current issue and note that split on the parent issue before continuing. If you discover a separate issue that is not a regression from the current branch, create a separate Linear issue rather than a sub-issue and note that split on the parent issue before continuing.

10. **Apply labels, assignee, and metadata when an agent creates the issue**. Use the `Agent` label in MCP calls for any issue created by an agent, even when the underlying problem was reported by the user during the session. In Linear UI this may appear under the `Source` group. Assign the issue to **Sam Clemente** by default. Also add the other relevant inferred metadata from the current context when it is clear, including product or platform labels (e.g. iOS, watchOS, Widgets), project association, priority, and any area labels that match the affected surface.

11. **If work is tracked in a split issue, comment there**. Put the plan, implementation progress, blockers, verification notes, and completion summary on the sub-issue or separate issue itself. Use the parent issue only for the split note and high-level coordination.

12. **Do not mark Done**—let Linear–GitHub integration set Done when the PR is merged.

If no Linear issue exists (e.g. branch is `main` or doesn’t match patterns), proceed without Linear updates—but **always check first**. For any feature work, the branch will always link to a Linear ticket somewhere.

## Reference

- [AGENTS.md](../../../AGENTS.md) — repository guidelines (structure, build, style, testing)
- [.agents/README.md](../../README.md) — agent context and architecture
