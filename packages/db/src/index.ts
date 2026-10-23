import postgres from 'postgres';

// One shared pool per process. Drizzle tables and migrations land here in M3.
export function createDb(url: string) {
	return postgres(url, { max: 10 });
}
