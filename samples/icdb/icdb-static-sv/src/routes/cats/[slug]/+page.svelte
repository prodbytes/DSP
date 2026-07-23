<script>
	import Comments from '$lib/components/Comments.svelte';

	let { data } = $props();

	const cat = $derived(data.cat);
	const filmography = $derived(data.filmography);
</script>

<svelte:head>
	<title>{cat.name} — ICDb</title>
	<meta name="description" content={cat.bio} />
</svelte:head>

<article>
	<div class="title-block">
		<h1>{cat.name}</h1>
		<div class="dim">{cat.knownFor}</div>
	</div>

	<div class="detail">
		<img class="portrait" src={cat.image} alt="Portrait of {cat.name}" />
		<div>
			<dl class="facts">
				<dt>Born</dt>
				<dd>{cat.born}</dd>
				<dt>Origin</dt>
				<dd>{cat.origin}</dd>
				<dt>Breed</dt>
				<dd>{cat.breed}</dd>
			</dl>

			<p>{cat.bio}</p>

			<h3>Awards</h3>
			<ul>
				{#each cat.awards as award (award)}
					<li>{award}</li>
				{/each}
			</ul>

			<h3>Videography</h3>
			<ul class="filmography">
				{#each filmography as video (video.slug)}
					<li>
						<a href="/videos/{video.slug}">{video.title}</a>
						<span class="dim">({video.year})</span>
						<span class="star">★</span>
						{video.rating.toFixed(1)}
					</li>
				{:else}
					<li class="dim">No credited appearances (yet).</li>
				{/each}
			</ul>
		</div>
	</div>
</article>

<Comments page={`/cats/${cat.slug}`} />

<style>
	.title-block {
		padding: 1.5rem 0 1rem;
	}

	.title-block h1 {
		margin: 0;
	}

	.detail {
		display: grid;
		grid-template-columns: 260px 1fr;
		gap: 1.5rem;
	}

	@media (max-width: 640px) {
		.detail {
			grid-template-columns: 1fr;
		}
	}

	.portrait {
		width: 100%;
		border-radius: 8px;
		border: 1px solid var(--icdb-border);
	}

	.facts {
		display: grid;
		grid-template-columns: auto 1fr;
		gap: 0.25rem 1rem;
		margin: 0 0 1rem;
	}

	.facts dt {
		color: var(--icdb-text-dim);
	}

	.facts dd {
		margin: 0;
	}

	.filmography {
		list-style: none;
		padding: 0;
		margin: 0;
	}

	.filmography li {
		padding: 0.35rem 0;
		border-bottom: 1px solid var(--icdb-border);
	}

	.filmography a {
		font-weight: 600;
	}
</style>
