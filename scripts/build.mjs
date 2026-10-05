// Build the static site into dist/: the hand-written pages under public/, plus the
// jQuery build from node_modules (so the version is pinned by package-lock.json and
// nothing is fetched from a CDN at runtime).
import { cpSync, mkdirSync, rmSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, join } from 'node:path';

const require = createRequire(import.meta.url);
const jqueryDist = dirname(require.resolve('jquery'));

rmSync('dist', { recursive: true, force: true });
cpSync('public', 'dist', { recursive: true });
mkdirSync('dist/vendor', { recursive: true });
cpSync(join(jqueryDist, 'jquery.min.js'), 'dist/vendor/jquery.min.js');
console.log('built dist/');
