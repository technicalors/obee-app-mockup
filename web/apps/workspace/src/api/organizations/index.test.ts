import { beforeEach, describe, expect, it, vi } from 'vitest';

import { organizationsResource } from './index';

const requestClient = vi.hoisted(() => ({
  put: vi.fn(),
  request: vi.fn(),
}));

vi.mock('#/api/request', () => ({ requestClient }));

const organization = {
  created_at: '2026-06-11T00:00:00.000000Z',
  id: '82b148c1-7f8b-52c1-9be5-97b8c44f495c',
  name: 'Updated Office',
  parent_id: null,
  tax_identification_number: null,
  type: 'Công ty',
  updated_at: '2026-10-05T00:00:00.000000Z',
};

describe('organizationsResource.update', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('sends PUT to the organization endpoint and returns the updated organization', async () => {
    const payload = {
      name: organization.name,
      parent_id: null,
      tax_identification_number: null,
      type: organization.type,
    };
    requestClient.put.mockResolvedValue(organization);

    await expect(
      organizationsResource.update(organization.id, payload),
    ).resolves.toEqual(organization);

    expect(requestClient.put).toHaveBeenCalledExactlyOnceWith(
      `/organizations/${organization.id}`,
      payload,
    );
    expect(requestClient.request).not.toHaveBeenCalled();
  });

  it('rejects invalid update payloads before sending a request', async () => {
    await expect(
      organizationsResource.update(organization.id, { name: '' }),
    ).rejects.toThrow('at least 1 character');

    expect(requestClient.request).not.toHaveBeenCalled();
    expect(requestClient.put).not.toHaveBeenCalled();
  });

  it('rejects incomplete update responses', async () => {
    requestClient.put.mockResolvedValue({ id: organization.id });

    await expect(
      organizationsResource.update(organization.id, {
        name: organization.name,
      }),
    ).rejects.toThrow('Required');

    expect(requestClient.put).toHaveBeenCalledExactlyOnceWith(
      `/organizations/${organization.id}`,
      { name: organization.name },
    );
  });
});
