# sebaspi-skills

Agent Skills (folder + `SKILL.md`) built and refined in real daily use with coding/automation agents.
They follow the open [Agent Skills](https://agentskills.io) format and work with Claude Code, Codex and other compatible agents.

## Skills

| Skill | What it does |
|---|---|
| [learning-videos](skills/learning-videos) | Short videos to learn or review any topic: testable goals, verified facts, script with retrieval pauses, Manim/HTML/slides renderer choice, voice and captions, plus a checker script (codec, loudness, silences, black frames, contact sheet). |
| [socratic-coding-tutor](skills/socratic-coding-tutor) | Teach programming while the learner writes the code: one small step at a time, predict-then-run, review their exact attempt, never hand over the finished app. |
| [local-voice-enhance](skills/local-voice-enhance) | Local "Podcast Enhance" for phone/camera voice: DeepFilterNet + EQ + compression + matched loudness, originals untouched, sync and mix-balance checks. |
| [no-ai-look-ui](skills/no-ai-look-ui) | Make web UIs that don't look AI-generated: principles, a table of "AI tells" with fixes, concrete defaults, review mode and checklist. |
| [minecraft-content-manager](skills/minecraft-content-manager) | Install/update/remove/audit mods, packs, shaders and datapacks in one instance: Modrinth first, dependency graph, hashes, staging, backups, manifest. |

## Install

With the skills CLI:

```bash
npx skills add sebaspi0922/sebaspi-skills
```

Or manually (git clone + symlinks):

```bash
git clone https://github.com/sebaspi0922/sebaspi-skills.git ~/sebaspi-skills
mkdir -p ~/.claude/skills
for d in ~/sebaspi-skills/skills/*/; do ln -sfn "$d" ~/.claude/skills/"$(basename "$d")"; done
```

Update later with `git -C ~/sebaspi-skills pull`.

## License

MIT, see [LICENSE](LICENSE). `no-ai-look-ui` includes ideas adapted from [unslop](https://github.com/heydamir/unslop) (CC BY 4.0, © heydamir), credited in the skill.
