import { defineConfig } from '@vben/eslint-config';

export default defineConfig([
  {
    files: [
      'apps/workspace/src/**/*.ts',
      'apps/workspace/src/**/*.tsx',
      'apps/workspace/src/**/*.vue',
    ],
    languageOptions: {
      parserOptions: {
        project: './apps/workspace/tsconfig.json',
        tsconfigRootDir: import.meta.dirname,
      },
    },
  },
  {
    files: ['apps/workspace/vite.config.ts'],
    languageOptions: {
      parserOptions: {
        project: './apps/workspace/tsconfig.node.json',
        tsconfigRootDir: import.meta.dirname,
      },
    },
  },
]);
