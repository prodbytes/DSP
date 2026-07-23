<script>
	import { cats, videos } from '$lib/data';
	import VideoCard from '$lib/components/VideoCard.svelte';
	import CatCard from '$lib/components/CatCard.svelte';

	const featured = videos.filter((v) => v.featured);
	const topRated = videos.slice(0, 5);
</script>

<svelte:head>
	<title>ICDb — Internet Cat Database</title>
	<meta
		name="description"
		content="Ratings, bios and filmographies for the internet's greatest cats and their videos."
	/>
</svelte:head>

<section class="hero">
	<h1>Internet Cat Database</h1>
	<p class="dim">
		The definitive source for feline cinema: ratings, bios and complete videographies of the
		internet's greatest cats. If it purrs and went viral, it's in here.
	</p>
</section>

<h2 class="section-title">Featured today</h2>
<div class="card-grid">
	{#each featured as video (video.slug)}
		<VideoCard {video} />
	{/each}
</div>

<h2 class="section-title">Top rated videos</h2>
<ol class="top-list">
	{#each topRated as video, i (video.slug)}
		<li>
			<span class="rank">{i + 1}</span>
			<a href="/videos/{video.slug}">{video.title}</a>
			<span class="dim">({video.year})</span>
			<span class="star">★</span>
			{video.rating.toFixed(1)}
		</li>
	{/each}
</ol>

<h2 class="section-title">Popular cats</h2>
<div class="card-grid">
	{#each cats as cat (cat.slug)}
		<CatCard {cat} />
	{/each}
</div>

<style>
	.hero {
		padding: 2.5rem 0 0.5rem;
		max-width: 640px;
	}

	.hero h1 {
		font-size: 2.2rem;
		margin: 0 0 0.5rem;
	}

	.top-list {
		list-style: none;
		padding: 0;
		margin: 0;
	}

	.top-list li {
		padding: 0.5rem 0;
		border-bottom: 1px solid var(--icdb-border);
	}

	.rank {
		display: inline-block;
		width: 1.5rem;
		font-weight: 700;
		color: var(--icdb-yellow);
	}
</style>
