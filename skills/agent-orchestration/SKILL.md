---
name: agent-orchestration
description: Use when coordinating several coding agents (Claude Code, Codex, subagents, parallel threads). Decide delegate vs do, brief, parallelize, verify.
license: MIT
---

# Agent orchestration

You are the coordinator. Your job is to split work, pick the right worker, keep workers from colliding,
and verify what comes back. You own the result: a worker's report is a claim, not evidence.

## 1. Delegate or do it yourself

Do it directly when:
- It takes 1-3 tool calls, or you already hold all the context.
- Steps are tightly serial (B needs A's exact output) and short.
- Writing the brief would take longer than doing the work.

Delegate when:
- Work splits into independent units (per file, endpoint, source, record) that don't need sibling output.
- It would blow your context (large reading, long logs, many files).
- It runs long (tens of minutes to hours) and you need to stay responsive.
- You want an independent opinion (review, second attempt, other model family).

Before fanning out, try one worker at lower cost on one slice. Many cheap workers only win on high-volume
routine work or work that doesn't fit one context. Never launch redundant workers by accident.

## 2. Pick the worker and model

Choose per stage, not per project. Set model and effort explicitly on every worker; an omitted value usually
inherits the most expensive session default.

Three questions per stage:
1. **Will something later catch errors?** (tests, build, vote, reviewer) → go cheaper. Nobody checks it → go stronger.
2. **Is the output objectively checkable?** Facts, tests, schemas → start small. Taste, design, architecture → start strong.
3. **How much context?** Small curated context → small model is viable. Long accumulated reading → split or go bigger.

| Stage | Tier |
|---|---|
| Single command, grep, link/license check, formatting, short log triage | small · low |
| Bounded code search with citations, CI triage, schema extraction, checklist QA | small · medium |
| Mechanical edit covered by a test | small · medium |
| Broad exploration ("how is X wired?"), well-specified implementation with tests | mid · medium |
| Reading sources with citations, drafting from verified facts | mid · medium |
| Drawing conclusions, conflicting sources, adversarial verification, rubric judge | mid · high |
| Architecture, plans, hard debugging, design judgment, final synthesis, final review | large · high |
| Security, auth, permissions, concurrency, data loss | large · high, even with tests |
| Something that already failed at large · high | top-tier model, one instance, reason written down |

Rules:
- Save on stages that need no intelligence, never on judgment. Nothing mechanical on the top model; nothing judgment-heavy on the small one.
- A large model at low effort often beats a small one at high effort on both quality and speed. Pick the model first, then the minimum effort that works.
- Maximum effort levels buy little for a lot of latency. Use them only with a written reason.
- Public leaderboards don't transfer to tool-heavy agent work. Before switching the model of a recurring flow, run 2-3 real tasks against the current one.
- Prefer flat-rate subscriptions over metered API credits. Get explicit approval before spending metered money, with an estimated cost.
- Before saying a model "doesn't exist" or "isn't available", check the provider's live model list that day. Yesterday's answer may already be stale.
- Smoke-test every new worker/provider combination with a trivial prompt ("reply only: ok") before handing it real work.

Escalation:
- Empty, truncated, refusal or safety-blocked answer → go straight to a stronger model.
- Failed check → more effort on the same model first, then a bigger model.
- Low confidence → ask the worker for a `confidence` field and permission to abstain instead of guessing.
- Looping → stop, rewrite the brief with a budget, and only then escalate. If almost everything escalates, the plan is wrong.

Measure cost per finished task, not per token.

## 3. Write a self-contained brief

Workers know nothing you didn't tell them: no chat history, no memory, no preferences. Write the brief to a file
in a durable project folder (not a temp dir that gets pruned) so a relaunch or phase 2 keeps its context.
Template: `references/brief-template.md`.

A brief must contain:
- **Goal and why**, in 2-3 sentences, plus what is out of scope.
- **Context**: repo path, branch, base commit, files to read first, relevant decisions already made.
- **Hypotheses as hypotheses**: if you believe something, say "verify this", not "this is true". Workers will happily build on your wrong premise.
- **Constraints**: what not to touch (services, ports, other dirs, shared branches), no push/merge/deploy unless stated, spending cap, tools allowed.
- **Paths rewritten for the worker's machine** if it runs elsewhere.
- **Definition of done**: exact checks to run and the evidence to include (command output, test names, screenshots).
- **Stop points**: where it must stop and wait for approval (see §5).
- **Deliverable**: one handoff file (`DELIVERY.md`) and a short reply format.
- "Cite sources with URLs. If something isn't confirmed, say so. Don't invent APIs, versions or results."

For weaker models: curated context only (exact files, commands, URLs, output format), never "explore the repo",
and always "run the check and quote its output".

If the fleet drifts, patch the shared brief once and re-steer; re-dispatched workers inherit the fix.

## 4. Parallelize without conflicts

- **One owner per file set.** Each worker gets an exclusive cluster of files; edits outside it are discarded at integration. Inside a single file, assign line ranges.
- **One worktree and branch per writing worker.** Read-only workers can share a checkout; writers never do.
- **Commit per verified step, locally.** Committed state is the only safe handoff; a worker that dies loses exactly its uncommitted tail. No push, rebase or PR from workers unless the brief says so.
- When workers must share an index, commit with explicit paths (`git commit -- <paths>`); a bare commit sweeps a sibling's staged hunks.
- Never use `git stash` in multi-worktree work: the stash ref is shared across worktrees and another worker can pop your edits.
- Don't edit files a running reviewer is reading.
- Keep fleets modest (roughly a dozen concurrent). Very large fleets on one credential hit rate limits and token-refresh failures that kill the whole wave. Queue the rest in waves.
- One test runner per machine, behind a lock. Many parallel runners are slower and kill each other's processes.
- Do the deterministic part (fetching, parsing, manifests, merging) in a script; hand workers only the step that needs judgment.

Integration per round:
1. Freeze a base commit. Rebase clean branches mechanically.
2. Give each conflicting branch its own rebase worker ("base behaviour wins, re-applied in the new structure").
3. Merge onto one integration branch and run the **full** suite on the combined tree. Collisions show up only here.
4. Confirm `git rev-list --count <integration>..<branch>` is 0 for every branch. Workers keep committing after you take their tip.
5. Re-run failing tests on a clean base checkout; identical failures are pre-existing, not yours.
6. The next round branches from the integrated commit.

## 5. Human approval stop points

Stop and get an explicit yes before:
- Spending metered money, or anything beyond the stated cap.
- Pushing, merging, deploying, publishing, or sending anything to a third party (client, user, social account).
- Destructive or irreversible actions: deleting data, force-pushing, migrations, rotating credentials.
- Creating long-lived agents, scheduled jobs or services.
- Touching protected config, permissions or credentials.
- Picking among options that are matters of taste or business judgment.

Put a review gate before every expensive step (final render, deploy, bulk send, paid run): the worker stops and
hands over a review packet of at most 300 words: what it did and recommends, the evidence (paths to previews,
frame sheets, test output), the risks, and go or stop. Cheap previews first, the expensive step only after a yes.

For deadline work: start first whatever is slow and doesn't depend on decisions; for the rest, have workers
propose options with evidence and stop until approved. Login codes and one-time tokens expire: request them
only when the human is ready, and never write tokens into chat or logs.

## 6. Verify independently

Treat every worker report as unverified.
- `completed` is not done. A few log lines or zero commits on its branch means it didn't finish; a "stalled" worker may have finished its write, so check the filesystem first.
- A launched job is not a running job. Check its first status/activity after launch; creating a thread or process can succeed while the provider fails to start.
- Check external effects yourself: curl the URL, hit the endpoints, run the tests, look at the screenshot, grep public files for secrets, `gh pr view` for real PR state.
- Count outputs: manifest lines vs expected units; every output file exists and was written **this run** (use a unique run dir).
- Don't trust a summary field for content; structured output goes to files.
- When a worker cites a blocker ("bug #123 breaks X", "repo doesn't exist"), check the latest release or the link yourself before acting on it.
- Treat reviewer claims the same way: A/B against the base before "restoring" anything.
- Multiple research workers get **cross-checked against each other**, not concatenated. Verify primary sources while they run.
- **Two-agent QA** (cheap, between "verify it yourself" and a full panel): one fresh-context worker reads only the
  original request and the deliverable and writes `qa-checklist.md` with checkable PASS/FAIL items ("all 12 links
  return 200", not "links work"). A different worker, which never saw how the list was written, runs it and attaches
  evidence to each item (quoted line, count, screenshot). Skim the list before it runs. A small model is enough.
- Report anything you couldn't test as untested. Report honest numbers ("16% so far, here's the path to 30%").

## 7. Adversarial and multi-model review

- **Independent attempts:** same question to 2-4 workers with *different* framings; same framing collapses to one answer. Ask for located, falsifiable claims (`file:line` + claim), not "auth has problems".
- **Refuters:** a second batch tries to break each claim with counter-evidence and returns `id|survives|evidence`. Give them the sources, not the attempts' reasoning. Surface survivors only; stop when a round adds none, cap at 3 rounds.
- Use the same mechanic on your own heuristics before applying them at scale.
- **Nobody approves their own work.** The reviewer is always a different worker, profile or model than the author;
  if your task board supports it, enforce it there.
- **Panel review:** one strong model from each of 2-3 different providers, read-only, scored out of 10. If a named member is unavailable, report it instead of silently substituting.
- Don't wait idle: check each result against the code as it lands and decide fixes while others run.

## 8. Loops with an external verifier

When iterating until a reviewer or judge is satisfied:
- **You write the harness, outside the author's workspace**, and lock it (read-only + checksum; re-verify the checksum each round). Threshold and round cap live in the harness, not in the brief, so the author can't lower the bar.
- **Blind judges:** don't tell them the threshold, the goal, that there are rounds, or past scores. Rubric + "grade honestly". Fresh evaluation each round. A judge that fails to answer = the round doesn't pass.
- **Budget:** default 3 rounds; first round full, later rounds only changed code and open findings. Extend (up to ~5) only for security, data loss or concurrency while a real finding stays open. Still not approved
  after round 3: escalate to the coordinator or the human with the ledger instead of opening round 4 by habit. Stop early if a round returns only nits.
- Severity: `blocker` = intended case is wrong; `should` = real bug callers will hit; `nit` = everything else, whatever label it came with. Re-grade every finding yourself.
- Fix with the smallest change: prefer deleting or narrowing over new locks, caches, helpers or options. Add one focused test that fails without the fix. If review grew the diff, cut first.
- Disagree with evidence (`file:line`, test output). Decline out-of-scope items in one line and list them as follow-ups. Never agree just to end the loop.
- In visual or animation loops, fix in a fixed order: structure (shots, cuts, length) → timing → easing → look
  (type, colour, scale, position) → detail (grain, blur, edges). Each step moves the ones after it, so polishing look
  before the cuts are settled is wasted work.
- Keep a ledger: id, severity, outcome (fixed / disagreed / declined), usage if reported. Never guess usage.
- Exit: approval on the current diff with no open blocker/should, **or** stuck (disputed after two replies) **or** budget exhausted. Budget end is not approval: show both sides in 2-3 lines and let the human decide.
- If the cap is reached without passing: ship nothing automatically; present the best version, the score table per round, cost, and what every judge asked for in common, with options and their cost.

## 9. Budgets, timeouts, long runs

- Set a time and spend cap per worker in the brief, and a wall-clock timeout on the process.
- Long work goes to the background with a completion notification; keep the main conversation free and send short progress notes.
- Right after launching, set up a watcher (notify on exit, or a poll every 20-60 s that exits on completed/failed). When it fires, verify the deliverable and report without waiting to be asked.
- Read the whole log, not just the tail: many CLIs print the answer before a footer of session metadata.
- One `PROGRESS.md` per worker, one timestamped line per step. Send new instructions through the normal channel
  **and** append them to that file: a message can sit unread while the worker is inside a long command. No new line
  for a long while means stalled; replace a hung worker with a fresh one scoped to the remaining fix.
- A timeout, error or no reply is never approval or success.
- Usage limits **pause, never degrade**. Near a quota: stop launching new workers, then tell running ones to commit progress, write a `PROGRESS.md` with the exact next step, and stop. Resume after the reset with the same model, effort and brief. Don't downgrade or cut scope to make it fit; order work so the critical part finishes first.
- Parent restart: write a `HANDOFF.md` (why it stopped, which workers are dead, per-branch scorecard, exact re-dispatch text) after snapshotting every dirty worktree into a `wip:` commit.
- Moving work between runners: commit its WIP to a branch and continue from there; don't throw it away.
- Before saying "we're waiting on you", confirm the deliverable exists (commits, files, artifacts). If the job never started, relaunch elsewhere with a short brief pointing to the original.
- Cross-machine work: verify access from the **worker's** host, not just the coordinator's. Don't copy keys around to build lateral access.

## 10. Reporting

- Lead with the outcome. Short bullets: what changed, what was verified (and how), what's left, what needs a decision.
- Batch several finished jobs into one report: done-and-ready-for-review vs. waiting on the human.
- State cost/usage only if measured.
- If the work ends in a PR, put review results (rounds, scores per reviewer) in the PR description, not a comment.
- Never fill gaps with plausible output. A blocker reported honestly beats an invented result.

## Plan format

Propose multi-agent plans as a table before launching:

```
Stage        | N | Model | Effort | Why (≤6 words)
explore      | 1 | small | medium | bounded search
plan         | 1 | large | high   | architecture
implement    | 4 | mid   | medium | closed spec + tests
QA           | 1 | small | medium | checkable
final review | 1 | large | high   | last gate
Stops: before push; before any metered spend.
Escalation: check fails → more effort → bigger model; empty/refusal → large.
```
