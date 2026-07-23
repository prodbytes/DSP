<script>
	import '../app.css';
	import favicon from '$lib/assets/favicon.svg';

	let { children } = $props();
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
</svelte:head>

<header>
	<div class="container header-inner">
		<a href="/" class="logo" aria-label="ICDB home">ICDb</a>
		<nav>
			<a href="/videos">Videos</a>
			<a href="/cats">Cats</a>
			<a href="/about">About</a>
		</nav>
	</div>
</header>

<main class="container">
	{@render children()}
</main>

<footer>
	<div class="container">
		<p class="dim">
			ICDb — the Internet Cat Database. A parody site for demo purposes; not affiliated with any
			movie database, any video platform, or (regrettably) any of these magnificent cats.
		</p>
		<p class="dim">Photo credits on the <a href="/about">about page</a>.</p>
	</div>
</footer>

<style>
	header {
		background: var(--icdb-black);
		border-bottom: 1px solid var(--icdb-border);
		position: sticky;
		top: 0;
		z-index: 10;
	}

	.header-inner {
		display: flex;
		align-items: center;
		gap: 1.5rem;
		height: 56px;
	}

	.logo {
		background: var(--icdb-yellow);
		color: var(--icdb-black);
		font-weight: 800;
		font-size: 1.15rem;
		padding: 0.1rem 0.5rem;
		border-radius: 4px;
		letter-spacing: -0.5px;
	}

	.logo:hover {
		text-decoration: none;
	}

	nav {
		display: flex;
		gap: 1.25rem;
	}

	nav a {
		font-weight: 600;
		font-size: 0.95rem;
	}

	main {
		min-height: 70vh;
		padding-bottom: 3rem;
	}

	footer {
		background: var(--icdb-black);
		border-top: 1px solid var(--icdb-border);
		padding: 1.5rem 0;
		font-size: 0.85rem;
	}

	footer a {
		color: var(--icdb-link);
	}
</style>
