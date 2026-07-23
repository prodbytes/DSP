<script>
	import { videoImage } from '$lib/data';

	let { video } = $props();
</script>

<div class="card">
	<a href="/videos/{video.slug}">
		<img src={videoImage(video)} alt="Poster for {video.title}" loading="lazy" />
		<div class="card-body">
			<div><span class="star">★</span> {video.rating.toFixed(1)}</div>
			<div class="card-title">{video.title}</div>
			<div class="card-sub">{video.year} · {video.duration}</div>
		</div>
	</a>
</div>
