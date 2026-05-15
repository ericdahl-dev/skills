import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const skills = defineCollection({
  loader: glob({ pattern: '**/SKILL.md', base: './skills' }),
  schema: z.object({
    name: z.string(),
    description: z.string(),
    upstream: z.string().url().optional(),
    license: z.string().optional(),
    metadata: z.record(z.any()).optional(),
  }),
});

export const collections = { skills };
