<script>
	import attribution from '$lib/attribution.json';
	import { getCat } from '$lib/data';

	const credits = Object.entries(attribution);

	/** @param {string} html */
	function stripTags(html) {
		return html.replace(/<[^>]*>/g, '').trim();
	}
</script>

<svelte:head>
	<title>About — ICDb</title>
</svelte:head>

<h2 class="section-title">About ICDb</h2>
<p>
	The Internet Cat Database is a parody of a well-known movie database, built as a static-site
	sample with <a href="https://svelte.dev/docs/kit">SvelteKit</a> and
	<code>@sveltejs/adapter-static</code>. Every cat and video lives in its own JSON file under
	<code>src/lib/data/</code>; the whole site is prerendered to plain HTML at build time.
</p>
<p class="dim">
	All ratings, vote counts and awards are fictional (except the Guinness records — those are real,
	because cats are extraordinary). No affiliation with IMDb, YouTube, or the cats' humans.
</p>

<h2 class="section-title">Photo credits</h2>
<p class="dim">
	Portraits are served locally and were sourced from Wikimedia Commons under free licenses. Some
	cats without freely-licensed portraits are represented by lookalike stand-ins.
</p>
<ul class="credits">
	{#each credits as [slug, credit] (slug)}
		<li>
			<strong>{getCat(slug)?.name ?? slug}</strong>:
			<a href={credit.page_url} rel="external noopener">{credit.file.replace('File:', '')}</a>
			<span class="dim">— {stripTags(credit.artist)} · {credit.license}</span>
		</li>
	{/each}
</ul>

<style>
	.credits {
		list-style: none;
		padding: 0;
	}

	.credits li {
		padding: 0.35rem 0;
		border-bottom: 1px solid var(--icdb-border);
	}

	.credits a {
		color: var(--icdb-link);
	}
</style>
