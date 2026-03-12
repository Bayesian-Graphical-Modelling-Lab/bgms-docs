# bgms-docs Efficient Build Plan (LLM-assisted + Human-reviewed)

## 1. Goal

Build high-quality bgms documentation quickly by combining:

- LLM-generated first drafts for structure and content.
- Deterministic extraction from package documentation (roxygen, inline docs, function signatures).
- Human review by you and a teammate before publication.

Primary success criteria:

- Fast first complete draft of all pages.
- Clear traceability for where text came from.
- Low hallucination risk.
- Consistent style and terminology.
- Process remains simple and understandable for novice contributors.

### Novice-friendly operating rule

Keep process language plain and steps short:

- If a step cannot be explained in 1-2 sentences, split it into smaller steps.
- Prefer checklists over free-form instructions.
- Record decisions in one place (`dev/task-list.md`) so newcomers do not need to infer context.
- Treat this plan as a practical playbook, not a theoretical framework.

---

## 2. Working Model

Use a two-lane process:

- Lane A: Skeleton and page architecture (Quarto files, section design, navigation).
- Lane B: Content population from sources (reference docs, algorithm design notes, examples).

Then merge both lanes into a staged review workflow.

---

## 3. Roles and Responsibilities

- Maarten (Editor Lead)
  - Own scope, priorities, and final quality bar.
  - Own all technical sign-off against bgms source/docs.
  - Approve page-level readiness.
- Emily (Reviewer Lead)
  - Own clarity/readability review and audience fit.
  - Provide readability sign-off for each reviewed page.
- LLMs (Drafting and Transformation)
  - Propose structure and produce initial text.
  - Summarize and transform source material.
  - Never treated as source of truth.

Rule: no content is considered final until reviewed by one human and spot-checked by another.

---

## 4. Branch and File Workflow

Recommended git workflow:

- `main`: stable docs.
- `docs/cycle-<nn>`: short-lived cycle branch containing scaffold, generated content, and review commits.
- Optional `docs/cycle-<nn>-<section>` only when parallel work is needed.

Commit discipline:

- One commit type per step:
  - scaffold only
  - generated content import only
  - human edits only
- Commit messages should include source and intent.

Rationale:

- Keep traceability with commit prefixes while reducing branch management overhead for a small team.

Example:

- `docs(scaffold): add manual chapter templates and section placeholders`
- `docs(gen): populate reference pages from roxygen extracts`
- `docs(review): correct NUTS warmup description after source check`

---

## 5. Source-of-Truth Hierarchy

When conflicts occur, resolve by this order:

1. bgms code behavior (actual implementation)
2. roxygen/man generated docs
3. design docs/algorithm notes
4. existing website text
5. LLM-generated narrative text

Never let LLM text override implementation facts.

---

## 6. End-to-End Process

### Phase 0: Preparation (one-time)

1. Freeze navigation and page inventory for this iteration.
  - Use `_quarto.yml` sidebar as canonical page inventory unless explicitly overridden.
2. Define audience per section:
   - Guide: users and applied analysts.
   - Reference: exact API behavior.
   - Manual: technical internals and algorithms.
3. Create acceptance checklist template per page (see Section 10).

Deliverable:

- Confirmed page map and ownership table.

### Phase 1: Skeleton generation (Quarto subfiles)

1. Use LLM to draft section skeletons only:
   - title
   - 3-6 section headings
   - placeholder callouts (`TODO: source`) for uncertain parts.
2. Keep placeholders explicit, do not let LLM invent details.
3. Render site and fix structure-level issues (links, nav, heading hierarchy).

Deliverable:

- All target `.qmd` files exist with consistent structure.

### Phase 2: Deterministic content ingestion

1. Reference pages:
   - Pull function signatures, arguments, return values, examples from roxygen/man.
  - Prefer deterministic extraction tooling (`.Rd` parsing, `tools::Rd2txt()` where useful).
   - Insert with minimal paraphrasing first.
2. Guide/manual pages:
   - Ingest algorithm design notes and implementation comments.
   - Convert into plain-language explanations plus pseudo-steps.
3. Mark each major block with provenance during drafting (inline markers and/or per-page provenance tracker).

Deliverable:

- Complete but unpolished content with provenance trail.

### Phase 3: LLM refinement (controlled)

1. Ask LLMs to improve clarity, not facts.
2. Prompt constraints:
   - preserve function names and parameter semantics
   - do not alter numeric defaults unless explicitly sourced
   - do not add undocumented features
3. Request concise rewrites and diff-style changes.

Deliverable:

- Cleaner prose while preserving factual alignment.

### Phase 3.5: Contradiction check (LLM adversarial pass)

1. Run an LLM pass that compares page draft text against quoted source excerpts.
2. Require mismatch-only output with severity labels (`high`, `medium`, `low`).
3. Resolve all `high` mismatches before human review begins.

Deliverable:

- Mismatch list attached to the page review note.

### Phase 4: Human technical review

1. You review high-risk pages first:
   - model classes
  - MCMC/NUTS/warmup
   - core function reference (`bgm`, `bgmCompare`)
2. Teammate reviews for correctness and readability.
3. Log decisions in page-level review notes (what changed and why).

Deliverable:

- Technically validated pages with recorded review outcomes.

### Phase 5: Consistency and style pass

1. Standardize terminology across sections.
2. Normalize heading patterns and cross-links.
3. Enforce `STYLE_GUIDE.md` conventions explicitly.
4. Ensure examples compile conceptually and match API signatures.

Deliverable:

- Cohesive style and navigable user experience.

### Phase 6: Pre-release QA and publish

1. Run automation-first QA bundle (script/CI):
   - full render
   - link check
   - search index sanity check
  - unresolved marker check (`TODO:` and malformed `SOURCE:` markers when inline provenance is used)
  - code example execution check for all pages with runnable R code (every cycle and pre-release)
2. Run a short human smoke check (visual layout, navigation behavior, obvious UX regressions).
3. Confirm zero unresolved factual issues.
4. Final sign-off by both humans.
5. Merge and deploy.

Deliverable:

- Publish-ready docs release.

### Phase gates (entry/exit criteria)

- Phase 1 exit:
  - no broken links
  - heading depth <= 3
  - navigation entries present
- Phase 2 exit:
  - each major claim has a provenance marker
- Phase 4 exit:
  - each high-risk page has two approvals:
    - technical sign-off by Maarten
    - readability sign-off by Emily
- Phase 6 exit:
  - clean render
  - zero unresolved `TODO:` / `SOURCE:` markers
  - zero unresolved factual issues

---

## 7. Efficient Review Cadence

Use short review cycles instead of one big review:

- Cycle length: 2-3 days.
- Each cycle targets 3-6 pages max.
- End each cycle with:
  - rendered preview
  - open issues list
  - accepted pages list

Weekly meeting template (30-45 min):

1. Pages completed since last check.
2. Blocking factual uncertainties.
3. Pages queued for next cycle.
4. Quality regressions detected.

---

## 8. Prompting Strategy for LLMs

Use specialized prompts by task:

- Skeleton prompt:
  - "Create only headings and section intent, no factual claims without source placeholders."
- Extraction prompt:
  - "Transform this roxygen/man content into Quarto reference format without adding fields."
- Translation prompt:
  - "Translate algorithm notes to user-facing explanation while preserving exact semantics and assumptions."
- Review prompt:
  - "Find contradictions between this page and provided source excerpts. Return only concrete mismatches."

Prompt hygiene:

- Always provide source text snippets.
- Ask for uncertainty flags.
- Ask for output in markdown compatible with target `.qmd` format.

---

## 9. Hallucination and Drift Controls

Mandatory controls:

- Every nontrivial claim must map to a source file or documented behavior.
- Use strict provenance markers during drafting:
  - `SOURCE: R/<file>.R#<function>`
  - `SOURCE: man/<topic>.Rd`
  - `SOURCE: design/<note>.md#<section>`
- Keep machine-readable provenance artifacts (inline markers and/or per-page tracker) for maintenance.
- Add accountability links for selected high-impact claims so reviewers and technical experts can jump straight to where behavior is defined.
  - Hard release gate for high-risk claims (defaults, priors, convergence, sampling behavior, core API semantics).
  - Best effort for low-risk narrative/context text.
  - Emergency waiver allowed only for urgent release fixes; waiver must be logged in `dev/task-list.md` with owner and follow-up due date.
- For algorithm pages, verify equations/steps against code or design note before approval.
- No unsourced defaults, priors, or computational claims.

If uncertainty remains:

- Keep explicit `TODO` note and defer publication for that block.

Pre-release guard:

- Fail release if unresolved `TODO:` markers remain or any published claim lacks a provenance record.

---

## 10. Page Acceptance Checklist (Definition of Done)

A page is done only if all are true:

- Structure matches section template.
- Facts verified against source hierarchy.
- No unresolved TODOs.
- Cross-links resolve.
- Terminology consistent with related pages.
- Reviewer notes resolved.
- Automation QA checks pass for the page/cycle.
- Rendered page visually sane on desktop and mobile.
- Code examples execute without error on every page that contains runnable code.
- Basic accessibility checks pass (alt text, contrast, keyboard navigation for interactive elements).

---

## 11. Minimal Metrics to Track

Track these simple metrics per cycle:

- Pages scaffolded
- Pages populated
- Pages reviewed (technical)
- Pages approved
- Open factual issues
- Average scaffolded -> approved cycle time
- Number of factual issues older than one cycle

Goal is directional visibility, not reporting overhead.

---

## 12. Risk-based Review Depth

Classify pages and set review intensity accordingly:

- High risk:
  - algorithm internals
  - defaults, priors, convergence behavior
  - core sampling behavior (NUTS/warmup)
- Medium risk:
  - method interpretation and workflow guidance
- Low risk:
  - intro/context and orientation pages

Rule:

- Triage review order and required depth by risk class when time is constrained.

---

## 13. Recommended Execution Order (for speed)

1. Build all skeletons first.
2. Complete reference pages next (high determinism).
3. Populate guide pages (user task flow).
4. Finish manual/algorithm internals (highest review depth).
5. Final cross-section consistency pass.

This order gives early visible progress and reduces risk.

---

## 14. What to Ask Other LLMs to Review

When you ask other LLMs to review this plan, request feedback on:

- Risk: where hallucination risk is still high.
- Throughput: bottlenecks in review cadence.
- QA: missing validation gates.
- Collaboration: handoff clarity between two human reviewers.

Ask them to respond with:

- "Keep"
- "Change"
- "Add"

for each section to make decisions fast.

---

## 15. Ownership and Status Tracker (template)

Use one mandatory living tracker file for coordination: `dev/task-list.md`.
If any other note conflicts with tracker status, `dev/task-list.md` is the source of truth.

| Page | Drafter | Reviewer | Risk | Status | Blocking issue |
|---|---|---|---|---|---|
| guide/getting-started.qmd | Name | Name | Medium | Drafting | - |

Statuses:

- `Scaffolded`
- `Populated`
- `Contradiction-checked`
- `Reviewed`
- `Approved`

---

## 16. Version Synchronization Strategy

To keep docs aligned with package evolution:

1. Trigger deterministic extraction when bgms version or API signatures change.
2. Maintain a lightweight "changed functions -> affected pages" mapping.
3. Re-open approved pages impacted by package changes before release.
