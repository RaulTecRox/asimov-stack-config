#!/usr/bin/env node
'use strict';
/**
 * PostToolUse Hook: TypeScript typecheck after editing .ts/.tsx files.
 *
 * Ported from ECC `scripts/hooks/post-edit-typecheck.js` (MIT).
 * Walks up to nearest tsconfig.json and runs tsc --noEmit, reporting
 * only errors relevant to the edited file. Fails silently if no tsconfig.
 */
const { execFileSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const MAX_STDIN = 16 * 1024 * 1024;

function findTsconfigDir(filePath) {
  let dir = path.dirname(path.resolve(filePath));
  const root = path.parse(dir).root;
  let depth = 0;
  while (dir !== root && depth < 20) {
    if (fs.existsSync(path.join(dir, 'tsconfig.json'))) return dir;
    dir = path.dirname(dir);
    depth++;
  }
  return null;
}

function run(rawInput) {
  try {
    const input = JSON.parse(rawInput);
    const filePath = input?.tool_input?.file_path;
    if (!filePath || !/\.(ts|tsx)$/.test(filePath)) return rawInput;

    const resolvedPath = path.resolve(filePath);
    if (!fs.existsSync(resolvedPath)) return rawInput;

    const tsconfigDir = findTsconfigDir(resolvedPath);
    if (!tsconfigDir) return rawInput;

    try {
      const npxBin = process.platform === 'win32' ? 'npx.cmd' : 'npx';
      execFileSync(npxBin, ['tsc', '--noEmit', '--pretty', 'false'], {
        cwd: tsconfigDir,
        encoding: 'utf8',
        stdio: ['pipe', 'pipe', 'pipe'],
        timeout: 30000,
      });
    } catch (err) {
      // tsc exits non-zero on errors — filter to edited file
      const output = (err.stdout || '') + (err.stderr || '');
      const relPath = path.relative(tsconfigDir, resolvedPath);
      const candidates = new Set([filePath, resolvedPath, relPath]);
      const relevant = output
        .split('\n')
        .filter(line => [...candidates].some(c => line.includes(c)))
        .slice(0, 10);

      if (relevant.length > 0) {
        console.error('[Hook] TypeScript errors in ' + path.basename(filePath) + ':');
        relevant.forEach(line => console.error(line));
      }
    }
  } catch {
    // Invalid input — pass through
  }
  return rawInput;
}

if (require.main === module) {
  let data = '';
  let bytes = 0;
  let oversized = false;
  process.stdin.setEncoding('utf8');
  process.stdin.on('data', chunk => {
    if (oversized) return;
    bytes += Buffer.byteLength(chunk, 'utf8');
    if (bytes > MAX_STDIN) { data = ''; oversized = true; return; }
    data += chunk;
  });
  process.stdin.on('end', () => {
    if (oversized) return process.exit(0);
    process.stdout.write(run(data), () => process.exit(0));
  });
}

module.exports = { run };