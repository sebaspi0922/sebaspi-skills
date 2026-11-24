---
name: minecraft-content-manager
description: Use to install, update, remove or audit Minecraft mods, resourcepacks, shaders or datapacks in one specific instance (any launcher, or alternative runtimes like Horizon), Modrinth first with CurseForge fallback, full compatibility and dependency checks, hash verification, staging, backups and an audit manifest.
license: MIT
---

# Minecraft Content Manager

Use this skill when the user asks to install, update, remove or audit Minecraft content in a specific instance. The
goal is changes that are compatible, verifiable, reversible and easy to audit; downloading files and copying them
without checks is not enough.

## Scope and operating rules

- Operate only on the instance the user named by absolute path, unambiguous name or launcher identifier. If several match, stop and ask.
- To move content between instances, identify source and target separately; keep the source read-only. Don't assume both use the same engine, version or loader (see "Alternative runtimes and transfers").
- If the user names a launcher, look inside that launcher's instance roots and validate its instance metadata. Don't substitute the official launcher's path or another launcher's.
- Never pick an instance because it was used last, has a big `mods` folder or partially matches the name.
- Don't run the game, close processes or kill Minecraft or the launcher to unlock files. If the instance is in use, say so and wait for the user to close it.
- Don't overwrite or delete existing files by default. Identical hash = already installed; a different file is a conflict and needs user confirmation, even inside a requested update (show what gets replaced).
- Don't install a loader, Java, a launcher, a full modpack or content for another version as a side effect.
- Source preference: Modrinth first, CurseForge as fallback. Respect an official source the user names; this preference proves neither compatibility nor safety.
- No random sites, unverified mirrors, short links, scraped download pages or executable installers.
- Never execute any downloaded JAR, ZIP, script or binary. Inspection is static.
- Never print or store API keys, cookies, tokens or private headers. For CurseForge, only use a key already in `CURSEFORGE_API_KEY` and never put it in commands, manifests or replies.
- Search by public names, authors or IDs and compare published hashes locally. Don't send local files, hashes or inventories to an external service without specific authorization.
- Don't write outside the instance, a controlled temporary staging dir, an authorized backup or this skill's manifest directory.

## What must be clear

Before downloading or writing, pin down:

1. Exact instance: absolute path, instance ID or unique name.
2. Content: exact name, URL, slug or Modrinth/CurseForge ID.
3. Type: mod, resourcepack, shaderpack, datapack, defaultconfig, config or other.
4. Version: a specific one or latest-compatible.
5. Options: include optional dependencies, replace conflicts, install for a specific world, or plan only.

"Add Sodium" allows searching candidates, but not choosing between ambiguous projects, installing an incompatible version or replacing a file without authorization. If the type changes the destination, ask. For a datapack, the target world is mandatory.

## Resolving the instance safely

Read-only phase first:

1. Given a path, normalize it with `realpath`, check it is a directory and whether any component is a symlink. Don't follow a symlink that escapes the instance without warning.
2. Given a launcher name/ID, inspect that launcher's known instance roots and their metadata files (e.g. `instance.json`, `instance.cfg`/`mmc-pack.json` for Prism/MultiMC). Use wildcards for account/instance components; never hardcode a machine's UUID.
3. Read the metadata with `jq` or Python. For each candidate record id, name, Minecraft version, loader type and loader version when present.
4. In generic searches exclude `~/.minecraft`, Flatpak copies, other clients' folders, backups and caches unless the user names them.
5. If there is not exactly one candidate, stop and show only the names and paths needed for the user to choose. Never create a new instance.

The target folder is the one holding the instance metadata and dirs such as `mods`, `resourcepacks`, `shaderpacks` and `saves`, not the launcher root. Keep the absolute path in the operational plan, but don't hardcode it in shareable references.

## Detecting Minecraft and the loader

Read the metadata and check it doesn't change between plan and install. Launcher paths and schemas are local hints to verify, not a universal contract.

Identify the target runtime first. The loader-matching and JAR-metadata rules here apply to Java Edition mods. For Horizon or another alternative engine, check its own version and API (see "Alternative runtimes and transfers"); don't invent a Fabric loader or require Java implicitly.

Don't derive the version from a file name, a date, a `.fabric` folder or the last log. If fields are missing, inspect the launcher's version metadata non-destructively; if Minecraft and the applicable loader/API still can't be confirmed, abort and ask.

Normalize values only for comparison and keep the original strings in the report. Java mods need matching Minecraft version and loader; native mods need compatible game and API. For resourcepacks, shaders and datapacks the loader may be irrelevant, but version and package structure are still mandatory checks.

Also check client_side, server_side, Java version if published, approval status, beta/alpha channel, dependencies and incompatibilities. On a client instance, don't auto-accept a project marked client-incompatible.

## Sources and version choice

### Modrinth first

Use the official Modrinth API, not HTML scraping when the API has the data. If the user gave a page, extract its ID or slug. When searching, combine exact name, project_type, Minecraft version and loader.

Pick the most recent stable compatible version that has a downloadable primary file, not simply the newest version overall. For same-name projects compare slug, author, icon, description and type; if still ambiguous, ask.

Record project_id, version_id, version number, date, status, primary file, name, URL, size, SHA-1 and SHA-512 and dependencies.

Dependency types: `required` is installed; `optional` is reported, not installed without authorization; `incompatible` blocks; `embedded` is not downloaded separately. If a dependency has a version_id, use it after checking compatibility; otherwise resolve a compatible version and pin its ID in the plan.

### CurseForge as fallback

Only the official API with an already configured `CURSEFORGE_API_KEY`. Minecraft Java is gameId 432; query the API's classes/categories, don't invent classIds for shaders, resourcepacks or datapacks.

Search with gameId, searchFilter, gameVersion, modLoaderType and classId as applicable. Read the project and its files, pick a compatible stable file and use only the `downloadUrl` returned by the API. If there is none, report the block instead of scraping or building a URL.

Validate gameVersions, loader, dependency relations, size, name and published hashes. Respect 429 and `Retry-After`. If the HTTP client can't send the key without exposing it in the process list, use a 0600 temp file removed during cleanup; never log it.

## Dependency graph and conflicts

Build and validate the whole graph before copying any file:

1. Every node pinned as source, project, version, file, expected hash and destination.
2. Walk transitive dependencies with a visited set to avoid cycles.
3. Auto-install only required, compatible dependencies.
4. Present skipped optionals; include them only if the user authorizes.
5. If a required dependency is missing, two incompatible versions of one project appear, or an incompatible relation exists, abort with no partial install.
6. If a compatible dependency already exists, verify its identity and hash before treating it as satisfied.
7. If a new file differs from an existing one, keep the original and stage the new one. Replace only if the user confirmed a plan that includes it. Never rename a JAR to hide the problem.

The plan shows root items, required dependencies, skipped optionals, incompatibilities and conflicts. IDs and hashes go in the local manifest; credentials never.

## Correct destinations

- mod: `INSTANCE/mods/`. One JAR compatible with the detected Minecraft and loader.
- native mod of an alternative runtime: its own package format and folder per its docs; not the Java JAR destination.
- resourcepack: `INSTANCE/resourcepacks/`. Usually kept as ZIP; validate `pack.mcmeta`.
- shaderpack: `INSTANCE/shaderpacks/`. Usually kept as ZIP; validate shader structure. Nothing in it is executed.
- datapack: `INSTANCE/saves/WORLD/datapacks/`. The world must come from the user. Never at the instance root.
- defaultconfig: `INSTANCE/defaultconfigs/`. Only on explicit request, after listing the files to add.
- config: `INSTANCE/config/`. Never merge foreign configs automatically; they need an explicit source and file set.
- kubejs, scripts, others: only the path documented by the project, with inventory and confirmation before merging.

A modpack is not a mod. Don't unpack it into an instance and don't install its configs, worlds, shaders or resourcepacks as side effects. Modpack import is a separate flow.

For ZIPs, accept `pack.mcmeta` and `data` at the effective root or a documented structure. Don't repack or "fix" content blindly. If a resource needs repacking, show the structure and ask.

## Phased workflow

### Phase 0: read-only plan
- Check processes and locks to confirm the launcher and game aren't running the instance; never close them.
- Do this before downloading and again before writing. An isolated process view or a failed lock query doesn't prove the game is closed. Distinguish the game and launcher window from helper servers used for queries.
- Read metadata, version, loader, destination and hashes of existing files.
- Query Modrinth and, if needed, CurseForge. Resolve dependencies and compatibility.
- Prepare a table: source, project, version, file, hash, destination, action, reason.

Stop on ambiguity, incompatibility, missing datapack world, untrusted URL, unpublished hash, unauthorized replacement or unresolved required dependency. Present the full plan and wait for confirmation before downloading or writing to the instance, unless your own rules say otherwise. Never hide the plan.

### Phase 1: isolated staging
- `umask 077` and a 0700 temp dir outside the instance.
- Download over HTTPS with timeout, `--fail` and few retries. Log only public URL, status and size.
- Download every graph node before touching the instance. If one fails, delete staging; no partial install.
- Reject HTML, absurd sizes, absolute names, `..` components, symlinks and paths escaping staging.
- Never unzip directly into the instance.

### Phase 2: static verification
- For downloads, compute the algorithms the source publishes and require every available hash to match; an extra local hash is for the manifest, it doesn't prove provenance. Without a trustworthy hash, mark the file unverifiable and ask before writing. For user-provided local files see "User's local files".
- Validate JAR/ZIP with `unzip -t` or Python `zipfile`; reject renamed HTML responses.
- Statically inspect `fabric.mod.json`, `quilt.mod.json`, `META-INF/mods.toml`, `META-INF/neoforge.mods.toml` and `MANIFEST.MF` when present.
- For resourcepacks and datapacks validate `pack.mcmeta` and its format range against the target's real format; datapacks need `data/`; shaders need a structure and loader the runtime supports. A valid ZIP or matching version name doesn't prove functional compatibility.
- Reject ZIP entries with traversal, absolute paths or dangerous symlinks.

### Phase 3: backup when needed
Before replacing a different file, copy the original outside the instance to e.g. `~/.local/state/minecraft-content-manager/backups/<instance-key>/<timestamp>/`, keeping relative path, permissions, mtime, size and hash. Follow a local backup policy first if one exists.

New files don't require copying the whole instance. Don't archive all of `saves` to install a datapack. Never delete backups automatically. If a required backup fails, abort the replacement.

### Phase 4: atomic copy
- Re-validate launcher metadata and that the instance is still idle right before writing.
- Create only the needed destination dirs; stop if a destination is a symlink.
- Copy from staging with the published name; don't rename to hide conflicts.
- Write a temp file in the same destination first, set normal non-executable permissions, check its hash, then atomic `mv`.
- Install multiple files in deterministic order. If rollback can't be guaranteed after a later failure, dry-run or abort before starting.
- Don't follow symlinks leaving the instance or allow relative paths controlled by downloaded names.

### Phase 5: validation and close-out
- Each installed file matches its staging hash.
- Re-read metadata and confirm it didn't change.
- Check location, content, sane permissions and mod count.
- Save a secret-free manifest outside the instance, e.g. `~/.local/state/minecraft-content-manager/manifests/`.
- Remove staging, temp files and temp credential files, even after errors.
- Don't launch the game automatically; a launch test is a separate action.
- Distinguish downloaded, validated, installed, activated and tested in-game. Copying a pack doesn't activate it; don't change `options.txt` or other preferences as a side effect. If installation is pending, keep a plan marked pending and don't present it as an install manifest.

## Manifest and audit

The manifest must answer: which project and version was installed, from which source, which hash was verified, at which relative path, which dependency pulled it in, which optionals were skipped and which backup restores it.

Use an identifier derived from the real path, not a fixed machine UUID. No tokens. When auditing, compare the manifest with current hashes and classify files as managed, manual, modified, missing or unknown. Never delete manual files automatically.

To remove content, require an unambiguous project/file, show what will be removed and wait for confirmation, check whether the manifest manages it, back it up and delete atomically. Don't remove shared dependencies without checking who uses them.

## Required final reply

Compactly report:
- instance absolute path and confirmed metadata: Minecraft, runtime and loader/API as applicable;
- source for each item and why CurseForge fallback was used, if it was;
- installed, already present, skipped optionals and conflicts;
- required dependencies resolved;
- backups and manifest created;
- compatibility warnings and pending actions, such as closing the game or choosing a world.

Never include API keys, cookies, private headers or full config contents.

## Abort without changes

Abort, clean staging and keep originals if: the instance is ambiguous; Minecraft or the applicable loader/API can't be confirmed; the source is untrusted; no compatible version exists; a required dependency fails; a hash mismatches; a file fails validation; the destination is a symlink; the game is open; there is an unauthorized conflict; the backup fails; or a partial operation can't be safely reverted.

On abort, return the reason, the files left untouched and the exact missing data needed to continue.

## API reference

Verify each API's current contract when you use it; this is an operational summary, not a guarantee.

### Modrinth (primary)
Allowed base: `https://api.modrinth.com/v2`. HTTPS only, and only file URLs returned by the API.

1. Search: `GET /search` with URL-encoded `query` and `facets`. Filter `project_type` and, for mods, the loader.
2. Project: `GET /project/{id}`. Check `project_type`, `slug`, `title`, author, `client_side`, `server_side`.
3. Versions: `GET /project/{id}/version` with properly encoded `game_versions=["MC"]` and `loaders=["LOADER"]`.
4. Pick the most recent approved, stable, compatible version and only its `primary` file. Keep `filename`, `url`, `size`, `hashes.sha1`, `hashes.sha512`.
5. Dependencies as above; pin `version_id` when given; walk transitives and detect cycles.

Don't assume any JAR is a Fabric mod: project, file and static metadata must agree with the instance loader. Compute SHA-512 and SHA-1 locally and accept only on a match with a published hash; if published hashes contradict or don't match, abort. 404 = unavailable; 429 = respect `Retry-After`; 5xx and timeouts allow few retries. A missing hash or URL is never fixed by disabling verification: report it and ask.

### CurseForge (fallback)
Allowed base: `https://api.curseforge.com/v1`. Minecraft Java: `gameId` 432. Key only from an existing `CURSEFORGE_API_KEY`; never in manifests, logs or visible process args.

1. Query categories/classes and pick the one for the requested type; mod, resourcepack, shader and datapack don't share a `classId`.
2. `GET /mods/search` with `gameId`, `searchFilter`, `gameVersion`, `modLoaderType`, `classId` as applicable.
3. Read the project and `GET /mods/{modId}/files` filtered by Minecraft version and loader.
4. Pick the stable compatible file and use only the API's `downloadUrl`. If missing, don't scrape or build a URL: report the block.
5. Resolve required dependencies transitively; report optionals and incompatibilities. Respect limits and `Retry-After`.

A CurseForge tag doesn't replace checking against the instance.

## Validation by type and filesystem rules

- Mod JAR: valid ZIP, metadata consistent with Fabric, Quilt, Forge or NeoForge, compatible Minecraft.
- Resourcepack: valid ZIP, `pack.mcmeta` at the effective root, not an HTML response.
- Shaderpack: valid ZIP, shader structure documented by the project, nothing executed.
- Datapack: ZIP or dir with `pack.mcmeta` and `data/`, only under the named world.
- Config/defaultconfig: only on explicit request; list files and detect overwrites before merging.
- The final path must be inside the real instance without crossing external symlinks. Reject absolute names, `..`, ZIP traversal and dangerous symlinks.
- Compare hashes before and after copying. Use temp files on the destination filesystem for atomic replace.
- Never make anything downloaded executable; don't change launcher files or game options as a side effect.
- Use relative paths and derived keys in manifests and backups, never fixed UUIDs.

## Alternative runtimes and transfers between instances

### Source and target
- Record real path, identity and metadata of each. Exact name and metadata decide selection, not last-access date.
- The game's assets/libraries folder may not be the folder where the client keeps `options.txt`, `resourcepacks/`, `saves/` and mods. Confirm via the runtime's options or docs.
- An API, a CLI and a config file can use different schemas: don't copy field names between interfaces unchecked.
- The source stays untouched. If the target needs a newer version of the same project, use a published compatible one and explain the difference. Don't update the source as a side effect.

### User's local files
- If the user says which instance or files to copy, that source is authorized. Validate structure, compatibility and hash before and after, without executing.
- Without a published hash, record `source=local-user` and `verification=local-integrity`; don't claim author authenticity.
- If the project can be identified from public data, query its versions by name or slug and compare hashes locally. Don't send the hash to a service to identify it without authorization.
- A file found in a cache or an unnamed folder is not an authorized source.

### Resourcepacks across versions
- Get the resource/data format from the target's real version (e.g. the Java client's `version.json`). Don't use a fixed table or infer it from the ZIP name.
- Interpret `pack_format`, `supported_formats`, `min_format`, `max_format` and `overlays` per that version; modern formats can have major/minor.
- Don't edit ranges to silence warnings. Repacking needs explicit scope and keeping the original.
- Separate vanilla content from what needs OptiFine, EMF/ETF, OptiGUI, Continuity, Sodium or other mods. A partial pack can be installed if it adds something useful and you explain what's missing.

### Horizon
Horizon has its own engine and mod system. Verify the current contract in its official sources (https://github.com/horizon-rust/horizon) and catalog (https://playhorizon.dev/mods), and use the installed version's docs or code if they differ.
- Check launcher, client and implemented Minecraft versions separately. Another launcher's instance metadata doesn't determine Horizon's capabilities.
- Prefer its MCP or CLI tools to query versions, settings and content. If the catalog fails to read a new capability, log it as a launcher incompatibility, not missing content. Don't update the launcher as a side effect.
- Fabric/Forge/NeoForge JARs don't run their code on Horizon. An importer may carry over some data and assets; "Partly" or "untested" is not full support.
- For a native mod verify the `.hmod` package, its manifest, API version, side, game version, capabilities and dependencies. It goes in the path documented for that version (usually `horizon-mods/` next to `options.txt`), not `mods/`.
- Distinguish runtime-native shaders from Iris/OptiFine packs. For skins, check what the client really shows; don't promise a visible change if support is incomplete.

### Target open or pending state
If the target is open, finish useful read-only queries and wait for the user to close the game; never close or launch it.
Record separately: source file, chosen project and version, reason for an update, verified integrity, verified provenance, partial features and activation status.
