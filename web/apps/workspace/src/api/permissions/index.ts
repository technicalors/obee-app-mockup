import type { Permission } from '#/api/contracts';

import { permissionSchema } from '#/api/contracts';
import { createCollectionResourceApi } from '#/api/resource';

export const permissionsResource = createCollectionResourceApi<Permission>(
  '/permissions',
  permissionSchema,
);
