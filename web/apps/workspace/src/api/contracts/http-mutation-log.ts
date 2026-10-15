import { z } from '@vben/common-ui';

import { paginationQuerySchema } from './pagination';

const requestedByUserSchema = z.object({
  avatar: z.string().nullable(),
  organization_id: z.string().nullable(),
  created_at: z.string().datetime({ offset: true }),
  deleted_at: z.string().datetime({ offset: true }).nullable(),
  email: z.string().nullable(),
  email_verified_at: z.string().datetime({ offset: true }).nullable(),
  id: z.string().uuid(),
  name: z.string(),
  supabase_id: z.string().nullable(),
  updated_at: z.string().datetime({ offset: true }),
  username: z.string(),
});

export const httpMutationLogSchema = z.object({
  action: z.string(),
  app_url: z.string(),
  code: z.string().length(7),
  code_snippet: z.string().nullable(),
  git_sha_1: z.string(),
  id: z.string().uuid(),
  instance_id: z.string().uuid().nullable(),
  is_error: z.boolean(),
  logged_at: z.string().datetime({ offset: true }),
  payload: z.string().nullable(),
  requested_by: z.string().uuid().nullable(),
  requested_by_user: requestedByUserSchema.nullable(),
  response: z.string().nullable(),
  response_status: z.number().int().min(100).max(599),
  trace: z.array(z.record(z.string(), z.unknown())).nullable(),
  uri: z.string(),
});

export const httpMutationLogIndexQuerySchema = paginationQuerySchema.extend({
  action: z.string().min(1).max(255).optional(),
  code: z.string().length(7).optional(),
  from: z.string().datetime({ offset: true }).optional(),
  instance_id: z.string().uuid().optional(),
  is_error: z.union([z.literal(0), z.literal(1)]).optional(),
  range: z.enum(['2m', '5m', '15m', '1h', '1d']).optional(),
  requested_by: z.string().uuid().optional(),
  response_status: z.number().int().min(100).max(599).optional(),
  search: z.string().min(1).max(255).optional(),
  to: z.string().datetime({ offset: true }).optional(),
});

export const httpMutationLogSuggestionQuerySchema = z.object({
  kind: z.enum(['action', 'user']),
  limit: z.number().int().min(1).max(20),
  q: z.string().min(1).max(255).optional(),
});

export const httpMutationLogUserSuggestionSchema = requestedByUserSchema.pick({
  avatar: true,
  email: true,
  id: true,
  name: true,
  username: true,
});

export const httpMutationLogMarkdownSchema = z.object({
  markdown: z.string(),
});

export type HttpMutationLog = z.infer<typeof httpMutationLogSchema>;
export type HttpMutationLogIndexQuery = z.input<
  typeof httpMutationLogIndexQuerySchema
>;
export type HttpMutationLogSuggestionQuery = z.input<
  typeof httpMutationLogSuggestionQuerySchema
>;
export type HttpMutationLogUserSuggestion = z.infer<
  typeof httpMutationLogUserSuggestionSchema
>;
