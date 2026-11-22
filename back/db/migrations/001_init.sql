BEGIN;

-- USERS --
CREATE TABLE users (
    id                  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username            VARCHAR(50) NOT NULL,
                        CHECK char_length(username) > 3 AND char_length(username) <= 50,
    email               VARCHAR(100) NOT NULL
                        CHECK char_length(email) > 3 AND char_length(email) <= 100,
    password_hash       VARCHAR(255) NOT NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX users_username_lower_idx ON users (LOWER(username));
CREATE UNIQUE INDEX users_email_lower_idx    ON users (LOWER(email));

-- Artists --
CREATE TABLE artists (
    id                  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    mbid                UUID UNIQUE,
    picture_url         VARCHAR(255),
    picture_attribution VARCHAR(255),
    name                VARCHAR(100) NOT NULL
                        CHECK char_length(name) > 0 AND char_length(name) <= 100,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- records and songs--
CREATE TABLE records (
  id                    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  mbid                  UUID UNIQUE,
  artist_id             BIGINT NOT NULL REFERENCES artists(id) ON DELETE RESTRICT,
  title                 VARCHAR(100) NOT NULL CHECK char_length(title) > 0 AND char_length(title) <= 100,
  release_year          SMALLINT CHECK (release_year BETWEEN 1900 AND 2100),
  cover_url             VARCHAR(255),
  record_type           TEXT NOT NULL DEFAULT 'album'
                        CHECK (record_type IN ('album', 'ep', 'single', 'broadcast', 'other')),
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX records_artist_id_idx ON records (artist_id);

CREATE TABLE songs (
  id                    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  mbid                  UUID UNIQUE,
  album_id              BIGINT NOT NULL REFERENCES albums(id) ON DELETE CASCADE,
  title                 TEXT NOT NULL,
  disc_number           SMALLINT NOT NULL DEFAULT 1 CHECK (disc_number > 0),
  track_number          SMALLINT NOT NULL CHECK (track_number > 0),
  duration_seconds      INT CHECK (duration_seconds > 0),
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (album_id, disc_number, track_number)   -- no two "track 3"s on disc 1
);

-- genres --
CREATE TABLE genres (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
)

CREATE TABLE record_genres (
    record_id BIGINT NOT NULL REFERENCES records(id) ON DELETE CASCADE,
    genre_id  BIGINT NOT NULL REFERENCES genres(id) ON DELETE CASCADE,
    PRIMARY KEY (record_id, genre_id)
);

CREATE INDEX record_genres_genre_id_idx ON record_genres (genre_id);

-- ── Ratings (score: 1–10 = 0.5★–5★) ───────────────────
CREATE TABLE album_ratings (
  id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id    BIGINT NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
  album_id   BIGINT NOT NULL REFERENCES albums(id) ON DELETE CASCADE,
  score      SMALLINT NOT NULL CHECK (score BETWEEN 1 AND 10),
  review     TEXT CHECK (char_length(review) <= 10000),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, album_id)
);
CREATE INDEX album_ratings_album_id_idx ON album_ratings (album_id);

CREATE TABLE song_ratings (
  id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id    BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  song_id    BIGINT NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
  score      SMALLINT NOT NULL CHECK (score BETWEEN 1 AND 10),
  review     TEXT CHECK (char_length(review) <= 10000),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, song_id)
);
CREATE INDEX song_ratings_song_id_idx ON song_ratings (song_id);

COMMIT;