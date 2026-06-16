#!/usr/bin/env node
/**
 * feature_build.js — KPC Feature Build Workflow (TDD)
 *
 * Pipeline:
 *   Phase 1 — Analysis:       Reads codebase, writes design.md, pauses for human review
 *   Phase 2 — Specs:          Writes RSpec from design (all RED — no implementation yet),
 *                              pauses for human review
 *   Phase 3 — Implementation: Parallel task waves; runs specs after each wave until green
 *
 * Usage:
 *   node .claude/workflows/feature_build.js "<feature description>"
 *
 * Example:
 *   node .claude/workflows/feature_build.js "add golfer handicap tracking"
 *
 * Feature slug is the first three words of the description, snake_cased.
 * All artifacts land in tmp/claude_specs/<slug>/.
 */

import { query } from "@anthropic-ai/claude-agent-sdk";
import fs from "fs";
import path from "path";
import readline from "readline";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const CWD = path.resolve(__dirname, "../..");   // app root: two levels up from .claude/workflows/
const CLAUDE_MD_PATH = path.join(CWD, "CLAUDE.md");

// ─── Utilities ────────────────────────────────────────────────────────────────

function featureSlug(description) {
  return description
    .trim()
    .split(/\s+/)
    .slice(0, 3)
    .join("_")
    .toLowerCase()
    .replace(/[^a-z0-9_]/g, "");
}

function specsDir(slug) {
  return path.join(CWD, "tmp", "claude_specs", slug);
}

function log(msg) {
  console.log(`\n[workflow] ${msg}`);
}

function banner(title) {
  const bar = "═".repeat(64);
  console.log(`\n${bar}\n  ${title}\n${bar}\n`);
}

function readFile(p) {
  return fs.readFileSync(p, "utf8");
}

function writeFile(p, content) {
  fs.mkdirSync(path.dirname(p), { recursive: true });
  fs.writeFileSync(p, content, "utf8");
}

async function pause(message) {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  return new Promise((resolve) => {
    rl.question(`\n${message}\n\nPress Enter to continue... `, () => {
      rl.close();
      resolve();
    });
  });
}

/**
 * Run a sub-agent. Streams output when stream: true (sequential agents).
 * Buffered (stream: false) for parallel agents to avoid interleaving.
 */
async function runAgent({ prompt: agentPrompt, label, maxTurns = 40, stream = true }) {
  log(`Starting: ${label}`);

  let result = "";
  let errorSubtype = null;

  for await (const event of query({
    prompt: agentPrompt,
    options: {
      cwd: CWD,
      maxTurns,
      allowedTools: ["Read", "Edit", "Write", "Bash", "Glob", "Grep"],
      permissionMode: "acceptEdits",
    },
  })) {
    if (stream && event.type === "assistant") {
      for (const block of event.message.content) {
        if (block.type === "text") process.stdout.write(block.text);
      }
    }
    if (event.type === "result") {
      result = event.result ?? "";
      if (event.is_error) errorSubtype = event.subtype;
    }
  }

  if (stream) console.log("");

  if (errorSubtype) {
    log(`WARNING: agent "${label}" ended with error: ${errorSubtype}`);
  } else {
    log(`Done: ${label}`);
  }

  return result;
}

// ─── Phase 1 — Analysis & Design ─────────────────────────────────────────────

async function phase1(featureDescription, slug) {
  banner("PHASE 1 — Analysis & Design");

  const dir = specsDir(slug);
  fs.mkdirSync(dir, { recursive: true });

  const designPath = path.join(dir, "design.md");
  const claudeMd = readFile(CLAUDE_MD_PATH);

  const prompt = `\
You are a senior Rails developer analyzing a feature request for the KPC (Kitchen Pass Classic) \
golf trip management app.

Read the app's CLAUDE.md carefully before exploring anything else.

<claude_md>
${claudeMd}
</claude_md>

---

FEATURE REQUEST:
${featureDescription}

---

Explore the codebase, then write a design document to this exact path:
  ${designPath}

Before writing, read:
  - app/models/*.rb
  - app/controllers/*.rb (skim for patterns relevant to this feature)
  - config/routes.rb
  - db/schema.rb
  - Any spec files directly relevant to the area being extended

The design document must contain exactly these sections, in this order:

---

# Feature: [Feature Name]

## Description
Plain English. What the feature does, who uses it, and why.

## Models
For each model created or meaningfully changed:
- Model name (NEW or EXISTING)
- New fields: name, type, constraints (null: false, default:, etc.)
- New associations (belongs_to, has_many, through:, etc.)
- New validations
- New scopes or class/instance methods (name and behavior)

## Controllers
For each controller created or meaningfully changed:
- Controller name (NEW or EXISTING)
- Each new action: verb, path, what it does, what it renders or redirects to
- Access level: require_login / require_admin / require_site_admin / public

## Routes
Exact lines to add to config/routes.rb, matching the existing formatting style.

## Views
For each view file created or meaningfully changed:
- File path (relative to app root)
- What it displays and any notable form or logic

## Task List
One item per file. Tag each with its dependency tier:

  [migration]  — db/migrate files
  [model]      — app/models files
  [controller] — app/controllers files
  [route]      — config/routes.rb edit
  [view]       — app/views files

Format each item as:
  - [ ] [tier] Description — \`path/to/file\`

Ordering rule: all [migration] and [model] items must appear before [controller] and [route] \
items, which must appear before [view] items.

## Open Questions
Specific decisions needing human input before implementation. If none, write "None."

---

Write only the design document. Do not implement anything.`;

  await runAgent({ prompt, label: "analysis agent", maxTurns: 30 });

  if (!fs.existsSync(designPath)) {
    throw new Error(`Analysis agent did not create ${designPath}. Check output above.`);
  }

  log(`Design document written → ${designPath}`);

  await pause(
    `PHASE 1 COMPLETE\n` +
    `\nReview and edit the design document:\n` +
    `  ${designPath}\n` +
    `\nResolve Open Questions and adjust the Task List as needed.\n` +
    `Specs will be written directly from this document in Phase 2.`
  );
}

// ─── Phase 2 — Spec Writing (TDD: write tests before implementation) ──────────

async function phase2(slug) {
  banner("PHASE 2 — Spec Writing (Red Phase)");

  const dir = specsDir(slug);
  const designPath = path.join(dir, "design.md");

  if (!fs.existsSync(designPath)) {
    throw new Error(`Design document not found at ${designPath}. Run Phase 1 first.`);
  }

  const designDoc = readFile(designPath);
  const claudeMd = readFile(CLAUDE_MD_PATH);

  const specListPath = path.join(dir, "spec_files.json");

  const prompt = `\
You are writing RSpec specs for a feature that has NOT been implemented yet. \
This is TDD: specs come first. You are defining the intended behavior in executable form. \
The implementation will be written in Phase 3 to make these specs pass.

The app is KPC (Kitchen Pass Classic), a Rails golf trip management app.

<claude_md>
${claudeMd}
</claude_md>

<design_doc>
${designDoc}
</design_doc>

---

STEP 1 — Read existing specs for style reference:
Read 2–3 files from spec/models/ (e.g. round_spec.rb, trip_spec.rb, golfer_round_spec.rb) \
to internalize the exact test style before writing anything.

STEP 2 — Write the spec files:
Write RSpec specs for every model and controller described in the design document. \
Base your specs entirely on the design document — describe the intended behavior, \
not any existing code (the feature code does not exist yet).

Conventions (mandatory — match the existing test files exactly):
  - require 'rails_helper' at the top of every spec file
  - shoulda-matchers for associations and validations:
      it { should belong_to(:trip) }
      it { should validate_presence_of(:name) }
  - One describe block per public method or scope
  - Test: the happy path, key validations, key edge cases, any algorithm behavior
  - Place spec files at spec/models/<model>_spec.rb or spec/controllers/<controller>_spec.rb

Do NOT write spec files for migrations, routes, or views.

STEP 3 — Confirm specs are RED:
Run the new spec files:
  bundle exec rspec <spec_file_1> <spec_file_2> ... --format documentation

Most or all examples will fail with "uninitialized constant" or similar — that is correct \
and expected. The specs are green only after Phase 3 implementation.

Report: list each spec file written and its failure count.

STEP 4 — Write the spec file list:
Write a JSON file to ${specListPath}:
  { "spec_files": ["spec/models/foo_spec.rb", "spec/controllers/bar_spec.rb"] }

Begin now.`;

  await runAgent({ prompt, label: "spec writer (red phase)", maxTurns: 40 });

  if (!fs.existsSync(specListPath)) {
    log("WARNING: spec_files.json not found. Phase 3 will run the full spec suite instead.");
  } else {
    const { spec_files } = JSON.parse(readFile(specListPath));
    log(`Spec files written:\n${spec_files.map((f) => `  ${f}`).join("\n")}`);
  }

  await pause(
    `PHASE 2 COMPLETE\n` +
    `\nAll specs are currently RED — no implementation exists yet. That is correct.\n` +
    `\nReview the spec files and adjust any examples that don't match your intent.\n` +
    `Implementation in Phase 3 is complete when these specs are green.`
  );
}

// ─── Phase 3 — Implementation (Green Phase) ───────────────────────────────────

async function phase3(slug) {
  banner("PHASE 3 — Implementation (Green Phase)");

  const dir = specsDir(slug);
  const designPath = path.join(dir, "design.md");
  const tasksPath = path.join(dir, "tasks.json");
  const specListPath = path.join(dir, "spec_files.json");
  const manifestPath = path.join(dir, "phase3_files.json");

  if (!fs.existsSync(designPath)) {
    throw new Error(`Design document not found at ${designPath}.`);
  }

  const designDoc = readFile(designPath);
  const claudeMd = readFile(CLAUDE_MD_PATH);

  // Load spec file list (used to run targeted specs after each wave)
  let specFiles = [];
  let modelSpecFiles = [];
  let controllerSpecFiles = [];

  if (fs.existsSync(specListPath)) {
    specFiles = JSON.parse(readFile(specListPath)).spec_files ?? [];
    modelSpecFiles = specFiles.filter((f) => f.startsWith("spec/models/"));
    controllerSpecFiles = specFiles.filter((f) => f.startsWith("spec/controllers/"));
  }

  // ── Step 3a: generate task breakdown ────────────────────────────────────────

  log("Generating task breakdown from finalized design document...");

  const plannerPrompt = `\
You are a build planner for a Rails app. Read the design document and produce a JSON task \
breakdown.

<design_doc>
${designDoc}
</design_doc>

Parse the Task List section. Group tasks into three dependency waves:

  Wave 1 "migrations_and_models"   — all [migration] and [model] items (run in parallel)
  Wave 2 "controllers_and_routes"  — all [controller] and [route] items (run after wave 1)
  Wave 3 "views"                   — all [view] items (run after wave 2)

For each task:
  - "id":      short unique snake_case string
  - "label":   task description from the design doc
  - "type":    migration | model | controller | route | view
  - "file":    primary file this task creates or modifies (relative to app root)
  - "context": one sentence: what to write, naming key fields, methods, and associations

Write the result as JSON to:
  ${tasksPath}

Schema:
{
  "waves": [
    {
      "name": "migrations_and_models",
      "tasks": [{ "id": "", "label": "", "type": "", "file": "", "context": "" }]
    },
    { "name": "controllers_and_routes", "tasks": [...] },
    { "name": "views", "tasks": [...] }
  ]
}

Write only the JSON file. No other output.`;

  await runAgent({ prompt: plannerPrompt, label: "task planner", maxTurns: 10, stream: false });

  if (!fs.existsSync(tasksPath)) {
    throw new Error(`Task planner did not produce ${tasksPath}.`);
  }

  let taskSpec;
  try {
    taskSpec = JSON.parse(readFile(tasksPath));
  } catch (e) {
    throw new Error(`Failed to parse tasks.json: ${e.message}`);
  }

  log(`Task breakdown written → ${tasksPath}`);

  // ── Step 3b: execute waves, run specs after each ─────────────────────────────

  const allImplementedFiles = [];

  const waveSpecTargets = {
    migrations_and_models: modelSpecFiles,
    controllers_and_routes: controllerSpecFiles,
    views: [],
  };

  for (const wave of taskSpec.waves) {
    if (!wave.tasks || wave.tasks.length === 0) {
      log(`Skipping empty wave: ${wave.name}`);
      continue;
    }

    log(`Executing wave: ${wave.name} (${wave.tasks.length} task(s) in parallel)`);

    await Promise.all(
      wave.tasks.map((task) => {
        allImplementedFiles.push(task.file);
        return runImplementationTask({ task, designDoc, claudeMd, specFiles });
      })
    );

    log(`Wave complete: ${wave.name}`);

    // Run the specs relevant to this wave, if any exist
    const targetSpecs = waveSpecTargets[wave.name] ?? [];
    if (targetSpecs.length > 0) {
      await runSpecsAndFix({
        specFiles: targetSpecs,
        designDoc,
        claudeMd,
        waveLabel: wave.name,
      });
    }
  }

  // ── Step 3c: final full spec run ─────────────────────────────────────────────

  if (specFiles.length > 0) {
    log("Running full feature spec suite...");
    await runSpecsAndFix({
      specFiles,
      designDoc,
      claudeMd,
      waveLabel: "final",
    });
  }

  // Save manifest
  const uniqueFiles = [...new Set(allImplementedFiles)];
  writeFile(manifestPath, JSON.stringify({ files: uniqueFiles }, null, 2));
  log(`Implementation manifest written → ${manifestPath}`);
}

async function runImplementationTask({ task, designDoc, claudeMd, specFiles }) {
  // Tell the agent which specs define the behavior it must satisfy
  const specHint =
    specFiles.length > 0
      ? `\nThe following RSpec files define the behavior you must satisfy:\n${specFiles.map((f) => `  - ${f}`).join("\n")}\nRead them before implementing.`
      : "";

  const prompt = `\
You are implementing one task in a TDD Rails feature build for the KPC app. \
Specs for this feature already exist and are currently failing. \
Your implementation must make the relevant specs pass.

<claude_md>
${claudeMd}
</claude_md>

<design_doc>
${designDoc}
</design_doc>

---

YOUR TASK:
  Type:    ${task.type}
  File:    ${task.file}
  Label:   ${task.label}
  Context: ${task.context}
${specHint}

---

Rules:
1. Follow every convention in CLAUDE.md without exception:
   - No Devise
   - Logic in models, thin controllers
   - Views use inline <style> blocks — no separate CSS files
   - Background image: url(<%= asset_path 'course_1.jpg' %>)
   - Navigation buttons: button_to with method: :get
   - Admin actions require before_action :require_admin (or require_site_admin)
   - Trip.current is the single source of truth for the active trip
2. Read the design document to understand context.
3. If modifying an existing file (e.g. config/routes.rb, an existing model): read the \
full file first, then make the minimal necessary change.
4. Implement only this task. Do not touch files outside your assignment.
5. For migrations: look at existing filenames in db/migrate/ and use a timestamp that \
sorts after all existing ones (format: YYYYMMDDHHMMSS).
6. No comments, no README updates, no code beyond what the task requires.

Implement the task now.`;

  await runAgent({ prompt, label: `${task.type}: ${task.id}`, maxTurns: 20, stream: false });
}

/**
 * Run a targeted set of spec files. If failures occur, spawn one fix agent.
 * Prints a pass/fail summary.
 */
async function runSpecsAndFix({ specFiles, designDoc, claudeMd, waveLabel }) {
  const specList = specFiles.join(" ");
  const runCmd = `bundle exec rspec ${specList} --format documentation 2>&1`;

  const runnerPrompt = `\
You are verifying that specs pass after an implementation wave in a TDD Rails build.

Run this command from the app root (${CWD}):
  ${runCmd}

Read the output carefully.

If all specs pass: print "ALL SPECS PASSING [${waveLabel}]" and stop.

If any specs fail: you have ONE attempt to fix the failures.
  - Read each failing spec to understand what behavior is expected.
  - Read the implementation files being tested.
  - Fix the implementation (never edit the spec files).
  - Re-run the same command.
  - Print the final result: total examples, failures, and any remaining failure messages.

Context:
<design_doc>
${designDoc}
</design_doc>

<claude_md>
${claudeMd}
</claude_md>

Begin by running the specs.`;

  await runAgent({ prompt: runnerPrompt, label: `spec runner [${waveLabel}]`, maxTurns: 30 });
}

// ─── Entry Point ──────────────────────────────────────────────────────────────

async function main() {
  const featureDescription = process.argv.slice(2).join(" ").trim();

  if (!featureDescription) {
    console.error(
      "Error: no feature description provided.\n" +
      "Usage: node .claude/workflows/feature_build.js \"<feature description>\""
    );
    process.exit(1);
  }

  if (!fs.existsSync(CLAUDE_MD_PATH)) {
    console.error(`Error: CLAUDE.md not found at ${CLAUDE_MD_PATH}`);
    console.error(
      "Run this script from the app root, or check the CWD resolution at the top of the file."
    );
    process.exit(1);
  }

  const slug = featureSlug(featureDescription);

  banner("KPC FEATURE BUILD WORKFLOW — TDD");
  log(`Feature : "${featureDescription}"`);
  log(`Slug    : ${slug}`);
  log(`Specs   : tmp/claude_specs/${slug}/`);
  log(`App root: ${CWD}`);

  try {
    await phase1(featureDescription, slug);
    await phase2(slug);
    await phase3(slug);
  } catch (err) {
    console.error(`\n[workflow] Fatal error: ${err.message}`);
    process.exit(1);
  }

  banner("WORKFLOW COMPLETE");
  log("All phases finished.");
  log(`Artifacts in tmp/claude_specs/${slug}/:`);
  log("  design.md         — finalized feature design");
  log("  spec_files.json   — spec files written in Phase 2");
  log("  tasks.json        — implementation task breakdown");
  log("  phase3_files.json — implementation files written in Phase 3");
}

main();
