import { error } from '@sveltejs/kit';
import { cats, getCat, videosForCat } from '$lib/data';

export function entries() {
	return cats.map((c) => ({ slug: c.slug }));
}

export function load({ params }) {
	const cat = getCat(params.slug);
	if (!cat) error(404, 'Cat not found');
	return { cat, filmography: videosForCat(params.slug) };
}
