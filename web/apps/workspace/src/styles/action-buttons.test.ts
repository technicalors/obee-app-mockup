import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { describe, expect, it } from 'vitest';

const buttonStyles = readFileSync(
  resolve(process.cwd(), 'apps/workspace/src/styles/action-buttons.css'),
  'utf8',
);

describe('workspace action button layout', () => {
  it('keeps button colors and sizes on the app theme', () => {
    expect(buttonStyles).not.toMatch(/background|border-radius|height: \d+px/);
  });

  it('keeps icons, groups, and mobile layout consistent', () => {
    expect(buttonStyles).toContain('.ant-btn > .iconify');
    expect(buttonStyles).toContain('.workspace-action-group');
    expect(buttonStyles).toContain('@media (width <= 640px)');
  });
});
