import { defineEnvVars } from '@sveltejs/kit/env';

export const variables = defineEnvVars({
	DATABASE_URL: {
		description: 'Postgres URL for the app database (unset during the build)',
		schema: (v) => v ?? ''
	},
	RIVET_HEALTH_URL: {
		description: "Rivet engine's health endpoint",
		schema: (v) => v || 'http://rivet-engine:6421'
	}
});
