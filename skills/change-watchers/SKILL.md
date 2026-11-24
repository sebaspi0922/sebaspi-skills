---
name: change-watchers
description: Use when a site, portal, feed or account page must be checked on a schedule and the user wants a message only when something changed. Builds a zero-token script watcher (API first, state file, silent baseline) instead of a browser or LLM run per tick.
license: MIT
---

# Change watchers (alert only on news, zero tokens)

## When to use
The user wants something checked on a schedule (a school LMS, a portal, a feed, an account page) and a message
ONLY when something changed, without filling the agent's context. For price targets use a price-monitor skill instead.

## Procedure
1. **Find a machine API first, not the browser.** Official REST/mobile-app API > RSS/JSON endpoint > HTML scrape >
   browser automation. A browser or LLM run per tick costs tokens and breaks on UI changes.
2. **Use a revocable app token, not the account password.** Sign in once through your password manager / credential
   vault, obtain the site's own app token from that session (per-site recipes in `references/`), and keep it in a
   secrets file (chmod 600) or env var. Keep secret values out of tool output and logs.
3. **Write a small script** (stdlib only, run with `python3 -I`):
   - load the token from the secrets file; call the API;
   - keep a state file (e.g. `state/<name>.json`) with a set of seen keys; key = `id:due_timestamp` so a moved deadline counts as news;
   - first run = baseline: record everything, print nothing;
   - print ONLY new items (name, source, due date in the user's timezone, link); empty stdout when nothing changed;
   - on API error print one warning only when the error text differs from the last stored one (no daily spam when a token expires).
4. **Test three runs before scheduling:** baseline (silent) → clear the seen set to simulate news (prints) → run again (silent).
5. **Schedule it as a plain script job** (cron, systemd timer, or your agent's no-LLM scheduled script mode) that
   forwards stdout only when non-empty. Use the user's timezone and avoid their quiet hours. No LLM ever runs.
   Only hand the output to an agent when the news needs reasoning or summarizing.
6. Tell the user what runs when, that silence means no news, and how to revoke the token.
7. **Give the script a read-only mode** (e.g. `--pending`: list what is due/overdue without touching the state file)
   so other jobs (a morning brief) can reuse it. Never run the stateful default from another job: it would swallow the next alert.

## "Tell me when X is released" (launches, availability)
- First answer the current status with sources (what exists today, dates, caveats for the user's setup), then set
  up the watcher in the same turn.
- Sources that need no login: a community status JSON if one exists (e.g. AreWeAntiCheatYet `games.json` for Linux
  games), a text hash of the official landing/waitlist page plus the store links it exposes (App Store / Play /
  TestFlight), GitHub releases filtered by keywords, and a specialist RSS filtered by title. Alert on: status
  change, new store link, new matching release/headline. Daily is usually enough.
- Keep already-seen headlines/releases in the state across runs (RSS rotates items out; without that they re-alert).
- Test step 4 by editing the state file (fake old status, drop one seen item) instead of waiting for real news.
- **Trailers/videos of a brand or studio:** the channel's YouTube RSS
  `https://www.youtube.com/feeds/videos.xml?channel_id=<id>` works from servers without login or yt-dlp (no bot
  wall). Key = videoId; alert only when the title matches the subject terms AND keywords (e.g. `<title>` +
  `trailer|teaser`, excluding `podcast|clip`), so promos and clips stay quiet.
- **"Tell me right when it drops"** means minutes, not daily: e.g. `*/10 6-21 * * *` in the user's timezone
  (respects quiet hours). If your scheduler has a run count/expiry, make it cover the event date; a small repeat
  count silently expires the watcher early.
- If nothing in the current feed matches the filter, simulate the alert by running the script with a widened
  pattern on a copy of the state, then restore the state and confirm the real run is silent.
- Before answering with rumors, check the official feed live: press and search snippets lag and mix rumored dates
  with confirmed ones; label each date as confirmed or rumor.

## Pitfalls
- Don't open the site in a browser on each tick or give the job to the agent "to check": that is exactly the cost the user asked to avoid.
- An API parameter listed in the docs can still be rejected by a given server (`invalidparameter`); retry with only the required params before debugging further.
- Browser sessions can expire between steps; sign in right before obtaining the token, in the same flow.

## References
- `references/moodle.md`: Moodle mobile-app token via the SSO launch endpoint and the timeline API call.
