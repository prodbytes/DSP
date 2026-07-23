<script>
	import { cats } from '$lib/data';
	import CatCard from '$lib/components/CatCard.svelte';
</script>

<svelte:head>
	<title>All cats — ICDb</title>
</svelte:head>

<h2 class="section-title">All cats</h2>
<p class="dim">The stars. The legends. The reason the internet exists.</p>

<div class="card-grid">
	{#each cats as cat (cat.slug)}
		<CatCard {cat} />
	{/each}
</div>
