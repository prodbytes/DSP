<script>
	let { cat } = $props();
</script>

<div class="card">
	<a href="/cats/{cat.slug}">
		<img src={cat.image} alt="Portrait of {cat.name}" loading="lazy" />
		<div class="card-body">
			<div class="card-title">{cat.name}</div>
			<div class="card-sub">{cat.knownFor}</div>
		</div>
	</a>
</div>
