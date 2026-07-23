# ICDb — Internet Cat Database

A parody of IMDb built as a fully static site with [SvelteKit](https://svelte.dev/docs/kit)
and `@sveltejs/adapter-static`. Instead of movies it catalogs legendary YouTube cat
videos; instead of actors, the internet's most famous cats (Henri le Chat Noir, Maru,
Happy Cat, Grumpy Cat, Lil Bub, Nyan Cat, Keyboard Cat and Colonel Meow).

## Content model

Every piece of content is a separate file:

- `src/lib/data/cats/*.json` — one file per cat (bio, breed, awards, portrait path)
- `src/lib/data/videos/*.json` — one file per video (rating, plot, cast of cat slugs)
- `src/lib/data/index.js` — loads all files with `import.meta.glob` and links cats ↔ videos
- `static/images/cats/*.jpg` — portraits downloaded from Wikimedia Commons
- `src/lib/attribution.json` — image sources and licenses (rendered on the About page)

Adding a cat or video = dropping a new JSON file in the right folder. Pages for
dynamic routes (`/cats/[slug]`, `/videos/[slug]`) are prerendered from `entries()`.

## Build

```sh
./build.sh        # npm install + build + output verification
./run.sh [port]   # serve ./build with Python http.server (default port 8000)
```

or manually:

```sh
npm install
npm run build     # static output in ./build
npm run preview   # serve the build locally
```

## Image credits

Cat portraits come from Wikimedia Commons under CC licenses; see the About page
(`/about`) or `src/lib/attribution.json` for per-image attribution. Cats without a
freely licensed photo (Henri, Happy Cat, Colonel Meow, Keyboard Cat) use lookalike
stand-in photos.
