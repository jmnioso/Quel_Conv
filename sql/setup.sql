-- ============================================================
-- EventGeek — Script SQL complet pour Supabase
-- À exécuter dans Supabase → SQL Editor
-- ============================================================

-- ─────────────────────────────────────────────
-- 1. NETTOYAGE (si re-exécution)
-- ─────────────────────────────────────────────
DROP TABLE IF EXISTS proposals CASCADE;
DROP TABLE IF EXISTS events CASCADE;
DROP TABLE IF EXISTS admins CASCADE;


-- ─────────────────────────────────────────────
-- 2. TABLE : events (événements publiés)
-- ─────────────────────────────────────────────
CREATE TABLE events (
  id               UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title            TEXT NOT NULL,
  category         TEXT NOT NULL CHECK (category IN ('cosplay','medieval','geek','foire','autre')),
  description      TEXT,
  date_start       DATE NOT NULL,
  date_end         DATE,
  location_name    TEXT NOT NULL,
  location_city    TEXT NOT NULL,
  location_address TEXT,
  location_url     TEXT,
  website          TEXT,
  organizer        TEXT,
  price            TEXT,
  status           TEXT DEFAULT 'validated',
  created_at       TIMESTAMPTZ DEFAULT NOW()
);


-- ─────────────────────────────────────────────
-- 3. TABLE : proposals (propositions en attente)
-- ─────────────────────────────────────────────
CREATE TABLE proposals (
  id               UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title            TEXT NOT NULL,
  category         TEXT NOT NULL,
  description      TEXT,
  date_start       DATE NOT NULL,
  date_end         DATE,
  location_name    TEXT NOT NULL,
  location_city    TEXT NOT NULL,
  location_address TEXT,
  location_url     TEXT,
  website          TEXT,
  organizer        TEXT,
  price            TEXT,
  submitter_name   TEXT NOT NULL,
  submitter_email  TEXT,
  status           TEXT DEFAULT 'pending',
  created_at       TIMESTAMPTZ DEFAULT NOW()
);


-- ─────────────────────────────────────────────
-- 4. TABLE : admins (administrateurs autorisés)
-- ─────────────────────────────────────────────
CREATE TABLE admins (
  id            UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  email         TEXT        UNIQUE NOT NULL,
  name          TEXT,
  password_hash TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);


-- ─────────────────────────────────────────────
-- 5. SÉCURITÉ RLS — events
-- ─────────────────────────────────────────────
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read events"
  ON events FOR SELECT
  USING (status = 'validated');

CREATE POLICY "Admins manage events"
  ON events FOR ALL
  USING (EXISTS (SELECT 1 FROM admins WHERE email = auth.email()));


-- ─────────────────────────────────────────────
-- 6. SÉCURITÉ RLS — proposals
-- ─────────────────────────────────────────────
ALTER TABLE proposals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can submit"
  ON proposals FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Admins manage proposals"
  ON proposals FOR ALL
  USING (EXISTS (SELECT 1 FROM admins WHERE email = auth.email()));


-- ─────────────────────────────────────────────
-- 7. SÉCURITÉ RLS — admins
-- ─────────────────────────────────────────────
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
 
-- Autoriser la lecture uniquement pour vérifier les credentials
-- (la page admin fait un SELECT email + password_hash)
CREATE POLICY "admins_select" ON admins
  FOR SELECT
  USING (true);


-- ─────────────────────────────────────────────────────────────
-- INSERTION du premier administrateur
-- Remplacez les valeurs avant d'exécuter
-- ─────────────────────────────────────────────────────────────
 
INSERT INTO admins (email, name, password_hash)
VALUES (
  'jmni.oso@gmail.com',                                          -- ← votre email
  'Jmni.oso',                                               -- ← votre nom
  encode(sha256('Mando68'::bytea), 'hex')            -- ← votre mot de passe
);
 
-- ─────────────────────────────────────────────────────────────
-- AJOUTER un autre administrateur (même format)
-- ─────────────────────────────────────────────────────────────
 
-- INSERT INTO admins (email, name, password_hash)
-- VALUES (
--   'autre@email.fr',
--   'Autre Admin',
--   encode(sha256('sonmotdepasse'::bytea), 'hex')
-- );
 
-- ─────────────────────────────────────────────────────────────
-- MODIFIER le mot de passe d'un admin existant
-- ─────────────────────────────────────────────────────────────
 
-- UPDATE admins
-- SET password_hash = encode(sha256('nouveaumotdepasse'::bytea), 'hex')
-- WHERE email = 'votre@email.fr';

-- ─────────────────────────────────────────────
-- 9. DONNÉES DE TEST (événements à venir)
-- ─────────────────────────────────────────────
INSERT INTO events (title, category, description, date_start, date_end, location_name, location_city, price, website, status)
VALUES
  (
    'Comic Con Paris 2026',
    'geek',
    'Le plus grand événement geek et pop culture de France. Rencontrez vos acteurs préférés, assistez à des panels exclusifs et découvrez les nouveautés de l''année.',
    '2026-10-22',
    '2026-10-25',
    'Paris Expo Porte de Versailles',
    'Paris',
    'À partir de 18€',
    'https://www.comicconparis.com',
    'validated'
  ),
  (
    'Japan Expo Sud 2026',
    'cosplay',
    'Le rendez-vous incontournable de la culture japonaise dans le Sud de la France. Manga, anime, cosplay, jeux vidéo et gastronomie japonaise.',
    '2026-11-13',
    '2026-11-15',
    'Parc Chanot',
    'Marseille',
    '12€ / jour',
    'https://www.japan-expo-sud.com',
    'validated'
  ),
  (
    'Japan Expo Paris 2026',
    'cosplay',
    'La référence de la culture japonaise en France : manga, anime, jeux vidéo, cosplay et bien plus encore.',
    '2026-07-02',
    '2026-07-05',
    'Paris-Nord Villepinte',
    'Paris',
    'À partir de 14€',
    'https://www.japan-expo.com',
    'validated'
  ),
  (
    'Marché Médiéval de Provins',
    'medieval',
    'Plongez dans l''ambiance du Moyen-Âge avec combats de chevaliers, artisans d''époque, jongleurs et saltimbanques dans la cité médiévale de Provins.',
    '2026-09-05',
    '2026-09-06',
    'Cité Médiévale',
    'Provins',
    'Gratuit',
    NULL,
    'validated'
  ),
  (
    'Les Médiévales de Carcassonne',
    'medieval',
    'Spectacles équestres, tournois de chevaliers et animations historiques dans la cité de Carcassonne.',
    '2026-08-14',
    '2026-08-16',
    'Cité de Carcassonne',
    'Carcassonne',
    '8€ / jour',
    NULL,
    'validated'
  ),
  (
    'Paris Games Week 2026',
    'geek',
    'Le salon européen du jeu vidéo : centaines de jeux en avant-première, tournois esport et animations.',
    '2026-10-28',
    '2026-11-01',
    'Paris Expo Porte de Versailles',
    'Paris',
    'À partir de 14€',
    'https://www.paris-games-week.com',
    'validated'
  ),
  (
    'Festival du Cosplay de Lyon',
    'cosplay',
    'Concours de cosplay, ateliers de confection de costumes, défilés et expositions dans la capitale des Gaules.',
    '2026-07-18',
    '2026-07-19',
    'Halle Tony Garnier',
    'Lyon',
    '10€ / jour',
    NULL,
    'validated'
  );
