import { describe, expect, it } from 'vitest';

import {
  getUserAvatarSource,
  getUserPlaceholderAvatar,
  getUserPlaceholderAvatarPool,
} from './avatar';

describe('user avatar helpers', () => {
  it('keeps placeholder selection stable for the same user', () => {
    expect(
      getUserPlaceholderAvatar({
        id: 'user-1',
        username: 'admin',
      }),
    ).toBe(
      getUserPlaceholderAvatar({
        id: 'user-1',
        username: 'admin',
      }),
    );
  });

  it('distributes different users across the available placeholders', () => {
    const selectedAvatars = new Set(
      Array.from({ length: 24 }, (_, index) =>
        getUserPlaceholderAvatar({
          id: `user-${index + 1}`,
          username: `user-${index + 1}`,
        }),
      ),
    );

    expect(selectedAvatars.size).toBeGreaterThan(1);
    expect(selectedAvatars.size).toBe(getUserPlaceholderAvatarPool().length);
  });

  it('preserves uint32 wraparound for long identities', () => {
    expect(
      getUserPlaceholderAvatar({
        id: 'user-with-a-long-identity-😀',
        username: 'admin',
      }),
    ).toBe(getUserPlaceholderAvatarPool()[1]);
  });

  it('prefers the persisted avatar when one exists', () => {
    expect(
      getUserAvatarSource({
        avatar: 'https://example.com/avatar.png',
        id: 'user-1',
        username: 'admin',
      }),
    ).toBe('https://example.com/avatar.png');
  });
});
