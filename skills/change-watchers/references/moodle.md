# Moodle (school portals)

Paths below assume Moodle is served under `/moodle/`; adjust to the site's base path.

## Check the mobile API is on
POST `login/token.php` with dummy `username`/`password` and `service=moodle_mobile_app`:
- `invalidlogin` → service enabled. `servicenotavailable` → disabled; fall back to scraping.

## App token from the user's signed-in session (SSO launch)
1. In an automated browser, open `/moodle/login/index.php` and sign in with the user's credentials via a password manager/vault (never type or log the password yourself).
2. In the same browser session, read the session cookies (e.g. CDP `Network.getCookies`) and request
   `/moodle/admin/tool/mobile/launch.php?service=moodle_mobile_app&passport=<any>&urlscheme=moodlemobile`
   with an HTTP client that does not follow redirects.
3. The redirect `Location` is `moodlemobile://token=<base64>`; decoded = `signature:::token[:::privatetoken]`,
   token = 32 hex chars. Store it as `MOODLE_<SITE>_TOKEN` in the secrets file (chmod 600) and report only success/failure.
- Revoke: Moodle profile → Preferences → Security keys (or log out of the mobile app).

## Calls (`/moodle/webservice/rest/server.php`, POST `wstoken`, `wsfunction`, `moodlewsrestformat=json`)
- Pending/overdue work: `core_calendar_get_action_events_by_timesort` with only `timesortfrom=<now-60d>`
  (`limittonum` was rejected by at least one server). Fields: `id`, `activityname`/`name`, `course.fullname`, `timesort`, `url`.
- `core_calendar_get_calendar_upcoming_view` can be empty while the timeline still has overdue items; use the timeline call.
