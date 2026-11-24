# Brief template

Copy to `<project>/BRIEF.md`, fill every section, delete what doesn't apply.

```markdown
# Brief: <short title>

## Goal
<2-3 sentences: what to achieve and why it matters.>
Out of scope: <what not to do, even if tempting>.

## Context
- Repo: <absolute path on the worker's machine> · branch: <name> · base: <commit sha>
- Read first: <files/dirs, docs, prior DELIVERY.md>
- Decisions already made: <list>
- Hypotheses to verify (not facts): <list>

## Constraints
- Write only in: <paths/worktree>. Do not touch: <services, ports, other dirs, shared branches>.
- No push / merge / deploy / publish / messages to third parties unless stated here.
- Spending cap: <amount or "none allowed">. Time cap: <minutes/hours>.
- Commit each verified step locally with explicit paths.
- Load/follow: <skills, style guides, conventions>.

## Definition of done
- [ ] <check 1: exact command, expected result>
- [ ] <check 2>
- Evidence to include: command output, test names, screenshots, URLs.
- Anything not tested must be listed as untested.

## Stop points (wait for approval)
- <e.g. before choosing between design options: propose 2-3 with evidence, then stop>
- <e.g. before any paid API call>

## Deliverable
Write `DELIVERY.md` in <path> with:
1. Outcome in one line.
2. What changed (files, commits).
3. Checks run, with output.
4. Open issues, untested parts, follow-ups.

Reply in ≤ 8 lines pointing to DELIVERY.md.
Cite sources with URLs. If something isn't confirmed, say so. Don't invent APIs, versions or results.
```

## Reviewer brief (read-only, one round)

```
Review only. Do not edit, commit, push, comment, or start other agents.
Repo: <path> Base: <sha> Intent: <1-2 sentences> Out of scope: <...> Checks: <results>
See: git diff <base> [-- <paths>]; git status --short (read untracked files).
Read surrounding code. Find bugs, broken callers, mismatch with intent. Skip style unless it hides a bug.
Flag code, tests or guards the intent doesn't need.
blocker = intended case wrong. should = real bug callers will hit. nit = the rest.
Reply:
VERDICT: APPROVE or CHANGES
R1 [blocker|should|nit] <file>:<line> <claim>. Fix: <suggestion>
```

Later rounds: send the same brief, the ledger (`fixed:` / `disagree:` / `declined:` + evidence) and the diff since
last round; ask the reviewer to mark each old id `resolved` or `still open: <reason>` and look only at changed code.
