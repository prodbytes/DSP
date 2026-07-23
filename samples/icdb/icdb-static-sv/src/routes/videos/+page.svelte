<script>
	import { videos } from '$lib/data';
	import VideoCard from '$lib/components/VideoCard.svelte';
</script>

<svelte:head>
	<title>All videos — ICDb</title>
</svelte:head>

<h2 class="section-title">All videos</h2>
<p class="dim">Ranked by ICDb rating, as voted by absolutely nobody.</p>

<div class="card-grid">
	{#each videos as video (video.slug)}
		<VideoCard {video} />
	{/each}
</div>
