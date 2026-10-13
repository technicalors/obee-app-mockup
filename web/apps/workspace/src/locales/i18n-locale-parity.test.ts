import { SUPPORT_LANGUAGES } from '@vben/constants';

import { describe, expect, it } from 'vitest';

type Locale = (typeof SUPPORT_LANGUAGES)[number]['value'];
type JsonObject = Record<string, unknown>;
type LocaleInventory = Map<Locale, Map<string, string[]>>;

const appLocaleModules = import.meta.glob('./langs/**/*.json', {
  eager: true,
  import: 'default',
});

const sharedLocaleModules = import.meta.glob(
  '../../../../packages/locales/src/langs/**/*.json',
  {
    eager: true,
    import: 'default',
  },
);

const supportedLocales = SUPPORT_LANGUAGES.map(
  (language) => language.value,
).toSorted(compareStrings);

function compareStrings(left: string, right: string) {
  return left.localeCompare(right);
}

function isJsonObject(value: unknown): value is JsonObject {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function readLocaleModule(path: string, value: unknown) {
  if (!isJsonObject(value)) {
    throw new Error(`${path} must contain a JSON object.`);
  }

  return value;
}

function getLocaleNamespace(path: string) {
  const [, localePath] = path.split('/langs/');

  if (!localePath) {
    throw new Error(`${path} must live under a langs directory.`);
  }

  const [locale, ...namespaceParts] = localePath.split('/');

  if (!locale || namespaceParts.length === 0) {
    throw new Error(`${path} must include a locale and namespace.`);
  }

  const namespace = namespaceParts.join('/');

  if (!namespace.endsWith('.json')) {
    throw new Error(`${path} must be a JSON locale module.`);
  }

  return {
    locale: locale as Locale,
    namespace: namespace.slice(0, -'.json'.length),
  };
}

function flattenLeafKeys(value: unknown, prefix = ''): string[] {
  if (!isJsonObject(value)) {
    return [prefix];
  }

  return Object.entries(value).flatMap(([key, nestedValue]) =>
    flattenLeafKeys(nestedValue, prefix ? `${prefix}.${key}` : key),
  );
}

function createLocaleInventory(modules: Record<string, unknown>) {
  const inventory: LocaleInventory = new Map(
    supportedLocales.map((locale) => [locale, new Map()]),
  );

  for (const [path, value] of Object.entries(modules)) {
    const { locale, namespace } = getLocaleNamespace(path);
    const localeNamespaces = inventory.get(locale);

    if (localeNamespaces) {
      localeNamespaces.set(
        namespace,
        [...new Set(flattenLeafKeys(readLocaleModule(path, value)))].toSorted(
          compareStrings,
        ),
      );
    }
  }

  return inventory;
}

function sortedDifference(left: string[], right: string[]) {
  const rightValues = new Set(right);

  return left
    .filter((value) => !rightValues.has(value))
    .toSorted(compareStrings);
}

function namespacesFor(inventory: LocaleInventory, locale: Locale) {
  const namespaces = inventory.get(locale);

  if (!namespaces) {
    throw new Error(`${locale} must be registered in the locale inventory.`);
  }

  return [...namespaces.keys()].toSorted(compareStrings);
}

function keysFor(
  inventory: LocaleInventory,
  locale: Locale,
  namespace: string,
) {
  const namespaces = inventory.get(locale);

  if (!namespaces) {
    throw new Error(`${locale} must be registered in the locale inventory.`);
  }

  return namespaces.get(namespace) ?? [];
}

function expectLocaleParity(
  layerName: string,
  modules: Record<string, unknown>,
) {
  const inventory = createLocaleInventory(modules);
  const sourceLocale = supportedLocales[0];

  if (!sourceLocale) {
    throw new Error('At least one supported language is required.');
  }

  const sourceNamespaces = namespacesFor(inventory, sourceLocale);

  supportedLocales.forEach((locale) => {
    const namespaces = namespacesFor(inventory, locale);

    expect(
      sortedDifference(sourceNamespaces, namespaces),
      `${layerName}/${locale} missing locale files`,
    ).toEqual([]);
    expect(
      sortedDifference(namespaces, sourceNamespaces),
      `${layerName}/${locale} extra locale files`,
    ).toEqual([]);
  });

  sourceNamespaces.forEach((namespace) => {
    const sourceKeys = keysFor(inventory, sourceLocale, namespace);

    supportedLocales.forEach((locale) => {
      const keys = keysFor(inventory, locale, namespace);

      expect(
        sortedDifference(sourceKeys, keys),
        `${layerName}/${locale}/${namespace}.json missing keys`,
      ).toEqual([]);
      expect(
        sortedDifference(keys, sourceKeys),
        `${layerName}/${locale}/${namespace}.json extra keys`,
      ).toEqual([]);
    });
  });
}

describe('i18n locale parity', () => {
  it('keeps app locale files and keys aligned across supported languages', () => {
    expect.hasAssertions();
    expectLocaleParity('app', appLocaleModules);
  });

  it('keeps shared locale files and keys aligned across supported languages', () => {
    expect.hasAssertions();
    expectLocaleParity('shared', sharedLocaleModules);
  });
});
