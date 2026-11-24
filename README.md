# sebaspi-skills

Agent Skills (folder + `SKILL.md`) built and refined in real daily use with coding/automation agents.
They follow the open [Agent Skills](https://agentskills.io) format and work with Claude Code, Codex and other compatible agents.

## Skills

| Skill | What it does |
|---|---|
| [no-ai-look-ui](skills/no-ai-look-ui) | Make web UIs that don't look AI-generated: principles, a table of "AI tells" with fixes, concrete defaults, review mode and checklist. |
| [compatible-video-copy](skills/compatible-video-copy) | Safe ffmpeg recipe for an H.264/AAC MP4 that plays everywhere: original untouched, timecode stripped, audio tracks handled, ffprobe-verified. |
| [lovable-vercel-workflow](skills/lovable-vercel-workflow) | Working on Lovable + GitHub + Vercel sites: right tool for code/data/images, deploy unblocking, known pitfalls, curl verification. |
| [minecraft-content-manager](skills/minecraft-content-manager) | Install/update/remove/audit mods, packs, shaders and datapacks in one instance: Modrinth first, dependency graph, hashes, staging, backups, manifest. |
| [change-watchers](skills/change-watchers) | Zero-token scheduled watchers that message only on real news (API first, silent baseline, state file), plus a Moodle recipe. |

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
