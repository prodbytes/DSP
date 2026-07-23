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
./scripts/build.sh        # npm install + build + output verification
./scripts/run.sh [port]   # serve ./build with Python http.server (default port 8000)
```

or manually:

```sh
npm install
npm run build     # static output in ./build
npm run preview   # serve the build locally
```

## Comments

The videos page (`/videos`) ends with a comments form and list backed by the
[icdb-comms-sam](../icdb-comms-sam) API. The API base URL is baked in at build
time via `VITE_COMMENTS_API`:

```sh
VITE_COMMENTS_API=https://xxxx.execute-api.us-east-1.amazonaws.com ./scripts/build.sh
```

Deploy `icdb-comms-sam` first (its deploy script prints the URL). Builds
without `VITE_COMMENTS_API` show "Comments are not configured for this build."

## Image credits

Cat portraits come from Wikimedia Commons under CC licenses; see the About page
(`/about`) or `src/lib/attribution.json` for per-image attribution. Only Grumpy Cat
and Lil Bub have freely licensed photos of the actual cat; the others (Henri, Maru,
Happy Cat, Nyan Cat, Colonel Meow, Keyboard Cat) use lookalike stand-in photos.
