<script>
	let { page } = $props();

	// Base URL of the icdb-comms-sam API, injected at build time, e.g.
	// VITE_COMMENTS_API=https://xxxx.execute-api.us-east-1.amazonaws.com ./scripts/build.sh
	const api = import.meta.env.VITE_COMMENTS_API ?? '';

	/** @type {{ id: string, page: string, name: string, comment: string, created_at: string }[]} */
	let comments = $state([]);
	let status = $state('loading');
	let name = $state('');
	let comment = $state('');
	let submitting = $state(false);
	let error = $state('');

	// Re-runs on client-side navigation, when `page` changes.
	$effect(() => {
		loadComments(page);
	});

	/** @param {string} forPage */
	async function loadComments(forPage) {
		status = 'loading';
		comments = [];
		if (!api) {
			status = 'disabled';
			return;
		}
		try {
			const res = await fetch(`${api}/comments?page=${encodeURIComponent(forPage)}`);
			if (!res.ok) throw new Error(`HTTP ${res.status}`);
			comments = await res.json();
			status = 'ready';
		} catch {
			status = 'error';
		}
	}

	/** @param {SubmitEvent} event */
	async function submit(event) {
		event.preventDefault();
		error = '';
		submitting = true;
		try {
			const res = await fetch(`${api}/comments`, {
				method: 'POST',
				headers: { 'content-type': 'application/json' },
				body: JSON.stringify({ page, name, comment })
			});
			if (!res.ok) throw new Error(`HTTP ${res.status}`);
			comments = [await res.json(), ...comments];
			name = '';
			comment = '';
		} catch {
			error = 'Could not post your comment. Please try again.';
		} finally {
			submitting = false;
		}
	}
</script>

<section class="comments">
	<h2 class="section-title">Comments</h2>

	{#if status === 'disabled'}
		<p class="dim">Comments are not configured for this build.</p>
	{:else if status === 'loading'}
		<p class="dim">Loading comments…</p>
	{:else if status === 'error'}
		<p class="dim">Comments are unavailable right now.</p>
	{:else}
		{#if comments.length === 0}
			<p class="dim">No comments yet. Be the first!</p>
		{/if}
		<ul class="comment-list">
			{#each comments as c (c.id)}
				<li class="comment">
					<div class="comment-meta">
						<strong>{c.name}</strong>
						<span class="dim">{c.created_at.slice(0, 16)}</span>
					</div>
					<p>{c.comment}</p>
				</li>
			{/each}
		</ul>

		<form onsubmit={submit}>
			<input
				type="text"
				placeholder="Your name"
				required
				maxlength="80"
				bind:value={name}
			/>
			<textarea
				placeholder="Your comment"
				required
				rows="3"
				maxlength="2000"
				bind:value={comment}
			></textarea>
			{#if error}
				<p class="form-error">{error}</p>
			{/if}
			<button type="submit" disabled={submitting}>
				{submitting ? 'Posting…' : 'Post comment'}
			</button>
		</form>
	{/if}
</section>

<style>
	.comments {
		margin-top: 3rem;
	}

	.comment-list {
		list-style: none;
		padding: 0;
		margin: 0 0 1.5rem;
	}

	.comment {
		background: var(--icdb-card);
		border: 1px solid var(--icdb-border);
		border-radius: 6px;
		padding: 0.75rem 1rem;
		margin-bottom: 0.75rem;
	}

	.comment p {
		margin: 0.25rem 0 0;
	}

	.comment-meta {
		display: flex;
		gap: 0.75rem;
		align-items: baseline;
	}

	form {
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
		max-width: 32rem;
	}

	input,
	textarea {
		background: var(--icdb-card);
		border: 1px solid var(--icdb-border);
		border-radius: 4px;
		color: var(--icdb-text);
		padding: 0.6rem 0.75rem;
		font: inherit;
	}

	input:focus,
	textarea:focus {
		outline: 2px solid var(--icdb-yellow);
		outline-offset: -1px;
	}

	button {
		align-self: flex-start;
		background: var(--icdb-yellow);
		color: var(--icdb-black);
		border: none;
		border-radius: 4px;
		padding: 0.6rem 1.25rem;
		font: inherit;
		font-weight: 600;
		cursor: pointer;
	}

	button:disabled {
		opacity: 0.6;
		cursor: default;
	}

	.form-error {
		color: #f66;
		margin: 0;
	}
</style>
