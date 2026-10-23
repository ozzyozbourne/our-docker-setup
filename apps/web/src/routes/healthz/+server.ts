import { json } from '@sveltejs/kit';
import { RIVET_HEALTH_URL } from '$app/env/private';
import { db } from '#lib/server/db.ts';

// Liveness plus a check that Postgres and the Rivet engine answer.
export async function GET() {
	const checks: Record<string, string> = {};

	try {
		await db`select 1`;
		checks.postgres = 'ok';
	} catch (e) {
		checks.postgres = (e as Error).message;
	}

	try {
		const res = await fetch(`${RIVET_HEALTH_URL}/health`);
		checks.rivet = res.ok ? 'ok' : `HTTP ${res.status}`;
	} catch (e) {
		checks.rivet = (e as Error).message;
	}

	const ok = Object.values(checks).every((v) => v === 'ok');
	return json({ ok, checks }, { status: ok ? 200 : 503 });
}
