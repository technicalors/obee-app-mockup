import type { Company } from '#/api/contracts';

import { companySchema } from '#/api/contracts';
import { createCollectionResourceApi } from '#/api/resource';

export const companiesResource = createCollectionResourceApi<Company>(
  '/companies',
  companySchema,
);
