import { DATABASE_URL } from '$app/env/private';
import { createDb } from '@ouramp/db';

export const db = createDb(DATABASE_URL);
