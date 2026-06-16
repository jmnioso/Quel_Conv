-- ============================================================
-- EventGeek — Script SQL complet pour Supabase
-- À exécuter dans Supabase → SQL Editor
-- ============================================================

-- ─────────────────────────────────────────────
-- 1. TABLE : events (événements publiés)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS events (
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
-- 2. TABLE : proposals (propositions en attente)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS proposals (
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
-- 3. TABLE : admins (administrateurs autorisés)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS admins (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email      TEXT UNIQUE NOT NULL,
  name       TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);



-- RLS : lecture publique pour les événements validés
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can read validated events"
  ON events FOR SELECT
  USING (status = 'validated');

CREATE POLICY "Admins can do everything on events"
  ON events FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM admins WHERE email = auth.email()
    )
  );



-- RLS : tout le monde peut soumettre, seuls les admins peuvent lire/gérer
ALTER TABLE proposals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can submit a proposal"
  ON proposals FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Admins can manage proposals"
  ON proposals FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM admins WHERE email = auth.email()
    )
  );



-- RLS : un admin peut se lire lui-même + tous si déjà admin
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can read admins table"
  ON admins FOR SELECT
  USING (auth.email() = email OR EXISTS (
    SELECT 1 FROM admins a2 WHERE a2.email = auth.email()
  ));

CREATE POLICY "Admins can insert new admins"
  ON admins FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM admins WHERE email = auth.email())
  );

CREATE POLICY "Admins can delete admins"
  ON admins FOR DELETE
  USING (
    EXISTS (SELECT 1 FROM admins WHERE email = auth.email())
  );


-- ─────────────────────────────────────────────
-- 4. PREMIER ADMINISTRATEUR
-- ⚠️  Remplacez l'email et le nom ci-dessous !
-- ─────────────────────────────────────────────
INSERT INTO admins (email, name)
VALUES ('votre@email.fr', 'Votre Nom')
ON CONFLICT (email) DO NOTHING;


-- ─────────────────────────────────────────────
-- 5. DONNÉES DE TEST (optionnel)
-- Supprimez ce bloc si vous ne voulez pas de données de test
-- ─────────────────────────────────────────────
INSERT INTO events (title, category, description, date_start, date_end, location_name, location_city, price, website, status)
VALUES
  (
    'Comic Con Paris 2025',
    'geek',
    'Le plus grand événement geek et pop culture de France. Rencontrez vos acteurs préférés, assistez à des panels exclusifs et découvrez les nouveautés de l''année.',
    '2025-10-23',
    '2025-10-26',
    'Paris Expo Porte de Versailles',
    'Paris',
    'À partir de 18€',
    'https://www.comicconparis.com',
    'validated'
  ),
  (
    'Japan Expo Sud',
    'cosplay',
    'Le rendez-vous incontournable de la culture japonaise dans le Sud de la France. Manga, anime, cosplay, jeux vidéo et gastronomie japonaise.',
    '2025-11-14',
    '2025-11-16',
    'Parc Chanot',
    'Marseille',
    '12€ / jour',
    'https://www.japan-expo-sud.com',
    'validated'
  ),
  (
    'Marché Médiéval de Provins',
    'medieval',
    'Plongez dans l''ambiance du Moyen-Âge avec combats de chevaliers, artisans d''époque, jongleurs et saltimbanques dans la cité médiévale de Provins.',
    '2025-09-06',
    '2025-09-07',
    'Cité Médiévale',
    'Provins',
    'Gratuit',
    NULL,
    'validated'
  )
ON CONFLICT DO NOTHING;
