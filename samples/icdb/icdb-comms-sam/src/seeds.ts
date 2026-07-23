// Initial comments for the pages of the icdb-static-sv web module, inserted
// by POST /init when the comments table is empty. Page values must match the
// `page` prop the site passes to its Comments component.
export interface SeedComment {
  page: string;
  name: string;
  comment: string;
}

export const SEED_COMMENTS: SeedComment[] = [
  { page: '/videos', name: 'Purrfessor Whiskers', comment: 'Finest filmography on the internet. Every single one a classic.' },
  { page: '/videos', name: 'Chairman Meow', comment: 'I demand a sequel to every video on this list.' },

  { page: '/cats/colonel-meow', name: 'Sir Pounce', comment: 'That glare could stop a laser pointer mid-flight. Legend.' },
  { page: '/cats/grumpy-cat', name: 'Meowly Cyrus', comment: 'She said no to fame and became famous anyway. Icon.' },
  { page: '/cats/happy-cat', name: 'Kitty Purry', comment: 'The original smile that launched a thousand memes.' },
  { page: '/cats/henri', name: 'Jean-Clawed', comment: 'Enfin, un chat qui comprend l’ennui existentiel.' },
  { page: '/cats/keyboard-cat', name: 'Cat Benatar', comment: 'Still the tightest keyboard solo ever recorded. Respect.' },
  { page: '/cats/lil-bub', name: 'Purrfessor Whiskers', comment: 'Scientifically proven to be the goodest bub. I did the study.' },
  { page: '/cats/maru', name: 'Boxy Brown', comment: 'No box too small, no dream too big. My hero.' },
  { page: '/cats/nyan-cat', name: 'Chairman Meow', comment: 'Half cat, half pastry, all rainbow. Revolutionary.' },

  { page: '/videos/colonel-meow-angriest-cat', name: 'Sir Pounce', comment: 'The angriest cat delivers the calmest masterpiece. 10/10.' },
  { page: '/videos/henri-2-paw-de-deux', name: 'Jean-Clawed', comment: 'The Citizen Kane of cat cinema. The ennui is palpable.' },
  { page: '/videos/henri-3-le-vet', name: 'Meowly Cyrus', comment: 'A harrowing tale of betrayal and thermometers.' },
  { page: '/videos/i-am-maru', name: 'Boxy Brown', comment: 'I laughed, I cried, I bought more boxes.' },
  { page: '/videos/i-can-has-cheezburger', name: 'Kitty Purry', comment: 'The meme that started it all. Absolute cinema.' },
  { page: '/videos/keyboard-cat-the-original', name: 'Cat Benatar', comment: 'Play him off? This performance plays US off.' },
  { page: '/videos/lil-bub-and-friendz', name: 'Purrfessor Whiskers', comment: 'A documentary that redefined the genre. Bub forever.' },
  { page: '/videos/many-too-small-boxes-and-maru', name: 'Boxy Brown', comment: 'The suspense of each box entry is unbearable. Bravo.' },
  { page: '/videos/nyan-cat-original', name: 'Chairman Meow', comment: 'Ten hours version is better, but this is where history began.' },
  { page: '/videos/the-original-grumpy-cat', name: 'Meowly Cyrus', comment: 'One frown to rule them all.' },
];
