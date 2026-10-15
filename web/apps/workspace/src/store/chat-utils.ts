export function normalizeMatrixLocalpart(userIdOrUsername: string): string {
  const localpart =
    userIdOrUsername.replace(/^@/, '').split(':')[0]?.trim().toLowerCase() ??
    '';
  const sanitized = localpart.replaceAll(/[^a-z0-9._=-]/g, '');
  if (sanitized) return sanitized;

  let hash = 0;
  for (const char of userIdOrUsername) {
    hash = Math.trunc(hash * 31 + (char.codePointAt(0) ?? 0));
  }
  return `user_${Math.abs(hash)}`;
}

export function getDirectChatAlias(
  userA: string,
  userB: string,
  serverName = 'obee.local',
): { alias: string; roomAliasName: string } {
  const lpA = normalizeMatrixLocalpart(userA);
  const lpB = normalizeMatrixLocalpart(userB);
  const sorted = [lpA, lpB].toSorted();
  const first = sorted[0] ?? lpA;
  const second = sorted[1] ?? lpB;
  const roomAliasName = `dm_${first}_${second}`;
  return {
    alias: `#${roomAliasName}:${serverName}`,
    roomAliasName,
  };
}

export function stripReplyFallback(body: string): string {
  if (!body || !body.startsWith('>')) return body;
  const lines = body.split('\n');
  let i = 0;
  while (
    i < lines.length &&
    (lines[i]?.startsWith('>') || lines[i]?.trim() === '')
  ) {
    i++;
  }
  return lines.slice(i).join('\n').trim() || body;
}
