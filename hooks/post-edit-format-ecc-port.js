#!/usr/bin/env node
'use strict';
/**
 * PostToolUse Hook: auto-format JS/TS files after edits.
 *
 * Ported from ECC `scripts/hooks/post-edit-format.js` (MIT).
 * Detects Biome (priority) or Prettier by config file, prefers the local
 * node_modules/.bin binary over npx, and fails silently when no formatter
 * is configured or installed.
 */
const { execFileSync, spawnSync } = require('child_process');
const fs = require('fs');
const os = require('os');
const path = require('path');

// Shell metacharacters that cmd.exe interprets as command separators.
const UNSAFE_PATH_CHARS = /[&|<>^%!;`()$]/;

const BIOME_CONFIGS = ['biome.json', 'biome.jsonc'];
const PRETTIER_CONFIGS = [
  '.prettierrc', '.prettierrc.json', '.prettierrc.js', '.prettierrc.cjs',
  '.prettierrc.mjs', '.prettierrc.yml', '.prettierrc.yaml',
  'prettier.config.js', 'prettier.config.cjs', 'prettier.config.mjs',
];
const ROOT_MARKERS = ['package.json', ...BIOME_CONFIGS, ...PRETTIER_CONFIGS];

/** Walk up from startDir to the nearest project root. */
function findProjectRoot(startDir) {
  const homeDir = os.homedir();
  const rootDir = path.parse(startDir).root;
  let dir = startDir;
  while (dir !== rootDir) {
    if (dir === homeDir) break; // don't treat global dotfiles as project markers
    for (const marker of ROOT_MARKERS) {
      if (fs.existsSync(path.join(dir, marker))) return dir;
    }
    dir = path.dirname(dir);
  }
  return startDir;
}

/** Detect the configured formatter. Biome wins over Prettier. */
function detectFormatter(projectRoot) {
  for (const cfg of BIOME_CONFIGS) {
    if (fs.existsSync(path.join(projectRoot, cfg))) return 'biome';
  }
  try {
    const pkgPath = path.join(projectRoot, 'package.json');
    if (fs.existsSync(pkgPath)) {
      const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
      if ('prettier' in pkg) return 'prettier';
    }
  } catch {
    // malformed package.json — fall through to file-based detection
  }
  for (const cfg of PRETTIER_CONFIGS) {
    if (fs.existsSync(path.join(projectRoot, cfg))) return 'prettier';
  }
  return null;
}

/** Prefer the local node_modules/.bin binary over npx (saves ~200-500ms). */
function resolveFormatterBin(projectRoot, formatter) {
  const pkg = formatter === 'biome'
    ? { binName: 'biome', pkgName: '@biomejs/biome' }
    : { binName: 'prettier', pkgName: 'prettier' };
  const isWin = process.platform === 'win32';
  const localBin = path.join(
    projectRoot, 'node_modules', '.bin',
    isWin ? `${pkg.binName}.cmd` : pkg.binName
  );
  if (fs.existsSync(localBin)) return { bin: localBin, args: [] };
  return { bin: isWin ? 'npx.cmd' : 'npx', args: [pkg.pkgName] };
}

/**
 * @param {string} rawInput - raw JSON from stdin
 * @returns {string} the original input (pass-through)
 */
function run(rawInput) {
  try {
    const input = JSON.parse(rawInput);
    const filePath = input?.tool_input?.file_path;
    if (!filePath || !/\.(ts|tsx|js|jsx)$/.test(filePath)) return rawInput;

    const resolvedFilePath = path.resolve(filePath);
    const projectRoot = findProjectRoot(path.dirname(resolvedFilePath));
    const formatter = detectFormatter(projectRoot);
    if (!formatter) return rawInput;

    const resolved = resolveFormatterBin(projectRoot, formatter);
    // Biome: `check --write` = format + lint in one pass.
    // Prettier: `--write` = format only.
    const tail = formatter === 'biome'
      ? ['check', '--write', resolvedFilePath]
      : ['--write', resolvedFilePath];
    const args = [...resolved.args, ...tail];

    if (process.platform === 'win32' && resolved.bin.endsWith('.cmd')) {
      if (UNSAFE_PATH_CHARS.test(resolvedFilePath)) {
        throw new Error('File path contains unsafe shell characters');
      }
      const result = spawnSync(resolved.bin, args, {
        cwd: projectRoot, shell: true, stdio: 'pipe', timeout: 15000,
      });
      if (result.error) throw result.error;
      if (typeof result.status === 'number' && result.status !== 0) {
        throw new Error(result.stderr?.toString() || `Formatter exited ${result.status}`);
      }
    } else {
      execFileSync(resolved.bin, args, {
        cwd: projectRoot, stdio: ['pipe', 'pipe', 'pipe'], timeout: 15000,
      });
    }
  } catch {
    // Formatter missing, file gone, or failed — non-blocking
  }
  return rawInput;
}

if (require.main === module) {
  let data = '';
  process.stdin.setEncoding('utf8');
  process.stdin.on('data', chunk => { data += chunk; });
  process.stdin.on('end', () => {
    process.stdout.write(run(data), () => process.exit(0));
  });
}

module.exports = { run };
