import type { User } from '#/api';

const UINT32_MODULUS = 4_294_967_296;

const placeholderAvatarUrls = [
  new URL(
    '../../../../../../mobile/assets/avatars/avatar-1.svg',
    import.meta.url,
  ).href,
  new URL(
    '../../../../../../mobile/assets/avatars/avatar-2.svg',
    import.meta.url,
  ).href,
  new URL(
    '../../../../../../mobile/assets/avatars/avatar-3.svg',
    import.meta.url,
  ).href,
  new URL(
    '../../../../../../mobile/assets/avatars/avatar-4.svg',
    import.meta.url,
  ).href,
  new URL(
    '../../../../../../mobile/assets/avatars/avatar-5.svg',
    import.meta.url,
  ).href,
  new URL(
    '../../../../../../mobile/assets/avatars/avatar-6.svg',
    import.meta.url,
  ).href,
  new URL(
    '../../../../../../mobile/assets/avatars/avatar-7.svg',
    import.meta.url,
  ).href,
  new URL(
    '../../../../../../mobile/assets/avatars/avatar-8.svg',
    import.meta.url,
  ).href,
] as const;

function hashUserIdentity(identity: string): number {
  let hash = 0;

  for (const character of identity) {
    const codePoint = character.codePointAt(0);

    if (codePoint === undefined) {
      throw new TypeError('User identity contains an invalid character.');
    }

    hash = (hash * 31 + codePoint) % UINT32_MODULUS;
  }

  return hash;
}

export function getUserPlaceholderAvatar(user: Pick<User, 'id' | 'username'>) {
  const hash = hashUserIdentity(user.id === '' ? user.username : user.id);

  return placeholderAvatarUrls[hash % placeholderAvatarUrls.length];
}

export function getUserAvatarSource(
  user: Pick<User, 'avatar' | 'id' | 'username'>,
) {
  return user.avatar ?? getUserPlaceholderAvatar(user);
}

export function getUserPlaceholderAvatarPool() {
  return placeholderAvatarUrls;
}
