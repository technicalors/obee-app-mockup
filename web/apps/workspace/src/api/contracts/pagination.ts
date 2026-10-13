import { z } from '@vben/common-ui';

export const paginationMetaSchema = z.object({
  has_next: z.boolean(),
  page: z.number(),
  per_page: z.number(),
  total: z.number(),
});

export const paginationQuerySchema = paginationMetaSchema.pick({
  page: true,
  per_page: true,
});

export const paginatedListSchema = <TSchema extends z.ZodType>(
  itemSchema: TSchema,
) =>
  z.object({
    items: z.array(itemSchema),
    pagination: paginationMetaSchema,
  });

export type PaginationMeta = z.infer<typeof paginationMetaSchema>;
export type PaginationQuery = z.input<typeof paginationQuerySchema>;
export type PaginatedList<T> = {
  items: T[];
  pagination: PaginationMeta;
};
