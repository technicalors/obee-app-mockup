export interface LinkItem {
  date: string;
  domain: string;
  href: string;
  id: string;
  messageId: string;
  senderName?: string;
  timestamp: number;
  url: string;
}

export interface MessageTextSegment {
  href?: string;
  isUrl: boolean;
  text: string;
}

const URL_REGEX = /(https?:\/\/[^\s<]+|www\.[^\s<]+)/gi;

export function trimTrailingPunctuation(raw: string): {
  trailing: string;
  url: string;
} {
  let url = raw;
  let trailing = '';

  while (url.length > 0) {
    const lastChar = url.at(-1);
    if (!lastChar) break;

    // Standard trailing punctuation: . , : ; ! ? ' "
    if (['!', '"', "'", ',', '.', ':', ';', '?'].includes(lastChar)) {
      trailing = lastChar + trailing;
      url = url.slice(0, -1);
      continue;
    }

    // Closing brackets: ), ], }
    if (lastChar === ')') {
      const openCount = (url.match(/\(/g) || []).length;
      const closeCount = (url.match(/\)/g) || []).length;
      if (closeCount > openCount) {
        trailing = lastChar + trailing;
        url = url.slice(0, -1);
        continue;
      }
    } else if (lastChar === ']') {
      const openCount = (url.match(/\[/g) || []).length;
      const closeCount = (url.match(/\]/g) || []).length;
      if (closeCount > openCount) {
        trailing = lastChar + trailing;
        url = url.slice(0, -1);
        continue;
      }
    } else if (lastChar === '}') {
      const openCount = (url.match(/\{/g) || []).length;
      const closeCount = (url.match(/\}/g) || []).length;
      if (closeCount > openCount) {
        trailing = lastChar + trailing;
        url = url.slice(0, -1);
        continue;
      }
    }

    break;
  }

  return { trailing, url };
}

export function normalizeUrlHref(url: string): string {
  if (url.startsWith('www.')) {
    return `https://${url}`;
  }
  return url;
}

export function getDomainFromUrl(url: string): string {
  try {
    const parsed = new URL(normalizeUrlHref(url));
    return parsed.hostname.replace(/^www\./, '');
  } catch {
    return url;
  }
}

export function extractUrls(
  text: string,
): Array<{ href: string; url: string }> {
  if (!text) return [];
  const matches = text.match(URL_REGEX);
  if (!matches) return [];

  const results: Array<{ href: string; url: string }> = [];
  for (const m of matches) {
    const { url } = trimTrailingPunctuation(m);
    if (url) {
      results.push({
        href: normalizeUrlHref(url),
        url,
      });
    }
  }
  return results;
}

export function parseMessageSegments(text: string): MessageTextSegment[] {
  if (!text) return [];

  const segments: MessageTextSegment[] = [];
  const regex = new RegExp(URL_REGEX);
  let lastIndex = 0;
  let match: null | RegExpExecArray;

  while ((match = regex.exec(text)) !== null) {
    const matchIndex = match.index;
    const rawMatch = match[0];
    const { trailing, url } = trimTrailingPunctuation(rawMatch);

    if (matchIndex > lastIndex) {
      segments.push({
        isUrl: false,
        text: text.slice(lastIndex, matchIndex),
      });
    }

    if (url) {
      segments.push({
        href: normalizeUrlHref(url),
        isUrl: true,
        text: url,
      });
    }

    if (trailing) {
      segments.push({
        isUrl: false,
        text: trailing,
      });
    }

    lastIndex = matchIndex + rawMatch.length;
  }

  if (lastIndex < text.length) {
    segments.push({
      isUrl: false,
      text: text.slice(lastIndex),
    });
  }

  return segments;
}
