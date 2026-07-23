<script>
	import { getCat, videoImage } from '$lib/data';

	let { data } = $props();

	const video = $derived(data.video);
	const cast = $derived(data.video.cast.map(getCat).filter(Boolean));
</script>

<svelte:head>
	<title>{video.title} ({video.year}) — ICDb</title>
	<meta name="description" content={video.plot} />
</svelte:head>

<article>
	<div class="title-block">
		<h1>{video.title}</h1>
		<div class="dim">{video.year} · {video.duration} · {video.channel}</div>
	</div>

	<div class="detail">
		<img class="poster" src={videoImage(video)} alt="Poster for {video.title}" />
		<div>
			<div class="rating">
				<span class="star">★</span>
				<strong>{video.rating.toFixed(1)}</strong><span class="dim">/10</span>
				<span class="dim">· {video.votes.toLocaleString('en-US')} votes · {video.views} views</span>
			</div>

			<div class="genres">
				{#each video.genres as genre (genre)}
					<span class="chip">{genre}</span>
				{/each}
			</div>

			<p>{video.plot}</p>

			{#if video.youtube}
				<a class="watch" href={video.youtube} rel="external noopener">▶ Watch on YouTube</a>
			{/if}

			<h3>Starring</h3>
			<ul class="cast">
				{#each cast as cat (cat.slug)}
					<li>
						<a href="/cats/{cat.slug}">
							<img src={cat.image} alt={cat.name} />
							<span>{cat.name}</span>
						</a>
						<span class="dim">— {cat.knownFor}</span>
					</li>
				{/each}
			</ul>
		</div>
	</div>
</article>

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

	.poster {
		width: 100%;
		border-radius: 8px;
		border: 1px solid var(--icdb-border);
	}

	.rating {
		font-size: 1.15rem;
		margin-bottom: 0.75rem;
	}

	.genres {
		margin-bottom: 0.5rem;
	}

	.watch {
		display: inline-block;
		background: var(--icdb-yellow);
		color: var(--icdb-black);
		font-weight: 700;
		padding: 0.45rem 1rem;
		border-radius: 999px;
		margin: 0.25rem 0 0.75rem;
	}

	.watch:hover {
		text-decoration: none;
		filter: brightness(1.1);
	}

	.cast {
		list-style: none;
		padding: 0;
		margin: 0;
	}

	.cast li {
		display: flex;
		align-items: center;
		gap: 0.6rem;
		padding: 0.4rem 0;
	}

	.cast img {
		width: 40px;
		height: 40px;
		border-radius: 50%;
		object-fit: cover;
	}

	.cast a {
		display: flex;
		align-items: center;
		gap: 0.6rem;
		font-weight: 600;
	}
</style>
