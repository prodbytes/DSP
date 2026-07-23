/**
 * Loads every cat and video from its own JSON file under
 * src/lib/data/cats/ and src/lib/data/videos/.
 * Adding a new entry = dropping a new .json file in the folder.
 */
const catModules = import.meta.glob('./cats/*.json', { eager: true });
const videoModules = import.meta.glob('./videos/*.json', { eager: true });

/** @type {Array<any>} */
export const cats = Object.values(catModules)
	.map((m) => /** @type {any} */ (m).default)
	.sort((a, b) => a.name.localeCompare(b.name));

/** @type {Array<any>} */
export const videos = Object.values(videoModules)
	.map((m) => /** @type {any} */ (m).default)
	.sort((a, b) => b.rating - a.rating);

const catIndex = new Map(cats.map((c) => [c.slug, c]));

/** @param {string} slug */
export function getCat(slug) {
	return catIndex.get(slug);
}

/** @param {string} slug */
export function getVideo(slug) {
	return videos.find((v) => v.slug === slug);
}

/** Videos a given cat appears in. @param {string} catSlug */
export function videosForCat(catSlug) {
	return videos.filter((v) => v.cast.includes(catSlug));
}

/** Poster image for a video: the first cast member's portrait. @param {any} video */
export function videoImage(video) {
	const star = catIndex.get(video.cast[0]);
	return star ? star.image : '/images/cats/happy-cat.jpg';
}
