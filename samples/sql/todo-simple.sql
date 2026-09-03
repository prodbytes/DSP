CREATE TABLE todo_items (
    id     SERIAL PRIMARY KEY,
    title  TEXT NOT NULL,
    done   BOOLEAN NOT NULL DEFAULT FALSE
);

INSERT INTO todo_items (title) VALUES ('Buy milk');

SELECT * FROM todo_items;

DELETE FROM todo_items WHERE title = 'Buy milk';

DROP TABLE todo_items;