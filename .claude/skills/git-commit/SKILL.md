---
name: git-commit
description: >
  Craft git commit messages following Conventional Commits v1.0.0 and immediately run the commit.
  Use this skill whenever the user types /commit, asks to commit changes, write a commit message,
  stage and commit, prepare a commit, or says anything like "commit this", "let's commit",
  "write the commit message", or "push these changes". Also trigger when the user asks Claude
  to finalize or wrap up a set of changes.
commands:
  - commit
---

# Git Commit Workflow

## Commit Message Structure

Follow [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/):

```
<type>[optional scope]: <subject>

<body>

[optional footer(s)]
```

### Subject line

- Format: `<type>[optional scope]: <subject>`
- Use one of the standard types (see below)
- `<subject>`: imperative mood, lowercase, no trailing period, max ~72 chars
- Be precise — name the thing that changed, not just what category it falls into
- **Bad:** `fix: bug fix` — **Good:** `fix(auth): reject expired tokens on session restore`

### Body

- Required for all commits (unless the subject is fully self-explanatory for a trivial change)
- Start one blank line after the subject
- Use a short bullet list (`-`) — 2–5 bullets is ideal
- Each bullet: one clear, specific point about *what* changed and *why* if non-obvious
- No filler, no repetition of the subject line

### Footer

- Add `BREAKING CHANGE: <description>` if the commit introduces a breaking API change
- Add `Refs: #<issue>` or similar if relevant issue/ticket references exist
- Omit entirely if nothing applies

---

## Commit Types

| Type | When to use |
|------|-------------|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `refactor` | Code restructuring without behavior change |
| `perf` | Performance improvement |
| `style` | Formatting, whitespace, no logic change |
| `test` | Adding or fixing tests |
| `docs` | Documentation only |
| `build` | Build system, dependencies, tooling |
| `ci` | CI/CD configuration |
| `chore` | Maintenance tasks that don't fit elsewhere |
| `revert` | Reverts a previous commit |

Use `!` after type/scope to flag a breaking change: `feat(api)!: remove deprecated endpoint`

---

## Rules

1. **Write from the codebase's perspective** — describe what the code now does, not what you did
2. **No AI self-references** — never mention Claude, AI, or "generated" anywhere in the message
3. **No vague subjects** — avoid words like "update", "changes", "improvements", "misc" without specifics
4. **Scope is optional** but useful when the change is confined to a clear module, layer, or feature area (e.g., `fix(parser):`, `feat(auth):`)
5. **One concern per commit** — if changes span multiple unrelated concerns, suggest splitting

---

## Workflow

1. Review the staged diff (`git diff --staged`); if nothing is staged, check `git status` and stage relevant files
2. If changes span multiple unrelated concerns, **stop and suggest splitting** into separate commits — briefly explain the proposed split and ask for confirmation before proceeding
3. Identify the primary type and optional scope
4. Write the subject line — precise and under ~72 chars
5. Write the body bullets — what changed, why if non-obvious
6. Add footer only if needed
7. **Run the commit immediately** — no confirmation needed:
   ```bash
   git commit -F - <<'EOF'
   <subject>

   <body>
   EOF
   ```

---

## Examples

**Simple fix:**
```
fix(networking): handle nil response in retry handler

- Guard against nil HTTPURLResponse before inspecting status code
- Prevents crash when URLSession returns transport-level errors
```

**New feature with scope:**
```
feat(bookmarks): add tag filtering to collection view

- Introduce TagFilterBar component above the collection grid
- Filter state managed in BookmarkListViewModel, persisted in UserDefaults
- Animated insertion/removal of items on filter change
```

**Breaking change:**
```
feat(design-system)!: replace SemanticColor with TokenKey registry

BREAKING CHANGE: SemanticColor enum removed; callers must migrate to TokenKey-based lookups via DesignSystemRegistry.

- Remove SemanticColor and all associated typealiases
- Add TokenKey: Hashable protocol with typed token resolution
- Update all internal call sites to new registry API
```

**Refactor without behavior change:**
```
refactor(auth): extract token validation into dedicated service

- Move token expiry logic out of SessionManager into TokenValidator
- Simplifies SessionManager and makes validation independently testable
```
