#!/usr/bin/env node
// SessionStart hook: recommend Claude Code automations (claude-code-setup plugin)
// once per project. Prints a trigger instruction the first time Claude Code opens
// in a given directory; stays silent afterwards (marker file) and never breaks
// session start on error.
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const home = process.env.USERPROFILE || process.env.HOME;
const markerDir = path.join(home, '.claude', 'automation-recommended');
const cwd = process.cwd();

function main() {
  // Skip when launched from the user's home directory itself
  if (path.resolve(cwd) === path.resolve(home)) return;

  fs.mkdirSync(markerDir, { recursive: true }); // so the `touch` below always works

  const hash = crypto.createHash('sha1').update(cwd).digest('hex').slice(0, 12);
  const name = path.basename(cwd).replace(/[^\w.-]/g, '_') || 'project';
  const marker = path.join(markerDir, `${name}-${hash}.marker`);

  if (fs.existsSync(marker)) return;

  process.stdout.write(
    'First session detected in this project. Run the claude-automation-recommender ' +
    'skill (installed via the claude-code-setup plugin) to analyze this codebase and ' +
    'present the top 1-2 automation recommendations per relevant category (hooks, ' +
    'skills, MCP servers, subagents, plugins). Present the report concisely. ' +
    'After presenting (or if the user declines, or the project is too small to matter), ' +
    'create the marker file so this runs only once per project, with: ' +
    `touch "${marker.replace(/"/g, '\\"')}"\n`
  );
}

try { main(); } catch (e) { /* never break session start */ }
