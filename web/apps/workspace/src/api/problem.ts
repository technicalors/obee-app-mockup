import type { ApiProblem, ValidationProblem } from './contracts';

import { apiProblemSchema, validationProblemSchema } from './contracts';

export class ApiProblemError extends Error {
  readonly problem: ApiProblem;

  constructor(problem: ApiProblem) {
    super(problem.detail);
    this.name = 'ApiProblemError';
    this.problem = problem;
  }
}

export class ValidationProblemError extends ApiProblemError {
  declare readonly problem: ValidationProblem;

  constructor(problem: ValidationProblem) {
    super(problem);
    this.name = 'ValidationProblemError';
    this.problem = problem;
  }
}

export function parseProblemPayload(
  payload: unknown,
): ApiProblemError | ValidationProblemError {
  const problem = apiProblemSchema.parse(payload) as ApiProblem;

  if (problem.status === 422) {
    return new ValidationProblemError(
      validationProblemSchema.parse(payload) as ValidationProblem,
    );
  }

  return new ApiProblemError(problem);
}
