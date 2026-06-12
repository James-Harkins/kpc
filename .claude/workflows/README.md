# KPC Feature Build Workflow

A TDD pipeline for implementing new features in the KPC Rails app.
Specs are written before implementation, so the implementation is complete when the specs are green.

## Invocation

```bash
node .claude/workflows/feature_build.js "<feature description>"
```

Run from the app root. The feature description can be as long as you like — the first three
words become the slug used for file paths.

**Examples:**

```bash
node .claude/workflows/feature_build.js "add golfer handicap tracking"
node .claude/workflows/feature_build.js "export trip roster to CSV"
node .claude/workflows/feature_build.js "email reminders for unpaid balances"
```

## Artifacts

Everything lands in `.claude/specs/<slug>/`:

| File | Created by | Purpose |
|---|---|---|
| `design.md` | Phase 1 | Feature design document — edit this before Phase 2 |
| `spec_files.json` | Phase 2 | List of spec files written |
| `tasks.json` | Phase 3 | Implementation task breakdown by wave |
| `phase3_files.json` | Phase 3 | Manifest of implementation files written |

---

## Pipeline

### Phase 1 — Analysis & Design

A single agent reads the relevant parts of the codebase and writes a structured design
document to `.claude/specs/<slug>/design.md`.

**The design doc contains:**
- Plain English description of the feature
- Models affected or created (fields, associations, validations, methods)
- Controllers affected or created (actions, access levels)
- Routes to add
- Views affected or created
- Ordered task list tagged by dependency tier ([migration], [model], [controller], [route], [view])
- Open questions requiring human input

**The workflow pauses here.** Open the design doc, resolve any open questions, and adjust
the task list before continuing. Phase 2 spec writing is driven entirely by this document.

---

### Phase 2 — Spec Writing (Red Phase)

A single agent reads the finalized design doc and writes RSpec specs that describe the
intended behavior. No implementation exists yet — **all specs will be RED** at this stage.
That is correct and expected.

Spec files are placed at:
- `spec/models/<model>_spec.rb` for new or extended models
- `spec/controllers/<controller>_spec.rb` for new or extended controllers

**The workflow pauses here.** Review the spec files. Edit any examples that don't match
your intent. These specs are the contract that Phase 3 must satisfy.

---

### Phase 3 — Implementation (Green Phase)

A planning agent reads the design doc and breaks the task list into three dependency waves,
written to `tasks.json`:

| Wave | Tasks | Runs in parallel |
|---|---|---|
| Wave 1 | All [migration] and [model] tasks | Yes |
| Wave 2 | All [controller] and [route] tasks | Yes (after wave 1) |
| Wave 3 | All [view] tasks | Yes (after wave 2) |

After each wave, the relevant specs are run automatically:
- After wave 1: model specs run; failures trigger one fix attempt
- After wave 2: controller specs run; failures trigger one fix attempt
- After wave 3: full feature spec suite runs; failures trigger one fix attempt

The workflow completes when all specs pass (or reports remaining failures if the fix
attempt was insufficient).

---

## Requirements

```bash
npm install @anthropic-ai/claude-agent-sdk   # if not already installed
```

Node.js 18+ required (uses ES modules and top-level await).

## Notes

- The workflow reads `CLAUDE.md` at the app root and injects it into every agent prompt.
  Keep `CLAUDE.md` up to date — it is the primary source of app conventions.
- Parallel implementation agents in Phase 3 do not stream output to avoid interleaving.
  Progress is logged per agent when each finishes.
- The one-fix-attempt limit on failing specs is intentional. If specs are still failing
  after the fix attempt, review the failures manually and run the spec file directly:
  `bundle exec rspec spec/models/<foo>_spec.rb --format documentation`
- Never edit spec files in Phase 3. If specs need to change, go back to Phase 2.
