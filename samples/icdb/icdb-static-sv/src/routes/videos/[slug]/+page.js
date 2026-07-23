import { error } from '@sveltejs/kit';
import { videos, getVideo } from '$lib/data';

export function entries() {
	return videos.map((v) => ({ slug: v.slug }));
}

export function load({ params }) {
	const video = getVideo(params.slug);
	if (!video) error(404, 'Video not found');
	return { video };
}
