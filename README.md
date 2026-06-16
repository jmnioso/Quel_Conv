# EventGeek — Guide de déploiement

## Fichiers inclus

```
eventgeek/
├── index.html       → Page principale (liste des événements)
├── proposer.html    → Formulaire de proposition
├── admin.html       → Interface d'administration
├── config.js        → Configuration Supabase
└── sql/
    └── setup.sql    → Script SQL complet à exécuter dans Supabase
```

---

## Étape 1 — Configurer Supabase

1. Créez un compte sur [supabase.com](https://supabase.com) si ce n'est pas déjà fait
2. Créez un nouveau projet
3. Allez dans **Settings → API** et notez :
   - **Project URL** (ex: `https://xxxx.supabase.co`)
   - **anon public key** (commence par `eyJ...`)

---

## Étape 2 — Exécuter le SQL

1. Dans Supabase, allez dans **SQL Editor**
2. Copiez-collez le contenu de `sql/setup.sql`
3. **Avant d'exécuter**, modifiez la ligne du premier admin :
   ```sql
   INSERT INTO admins (email, name)
   VALUES ('votre@email.fr', 'Votre Nom')
   ```
4. Cliquez sur **Run**

---

## Étape 3 — Configurer config.js

Ouvrez `config.js` et remplacez les valeurs :

```javascript
const SUPABASE_URL = 'https://VOTRE_PROJECT_ID.supabase.co';
const SUPABASE_ANON_KEY = 'VOTRE_CLE_ANON';
```

---

## Étape 4 — Activer l'authentification email (Magic Link)

1. Dans Supabase, allez dans **Authentication → Providers**
2. Vérifiez que **Email** est activé
3. Dans **Authentication → URL Configuration**, ajoutez votre URL GitHub Pages :
   `https://votre-pseudo.github.io/nom-du-repo/admin.html`

---

## Étape 5 — Déployer sur GitHub Pages

1. Créez un repository sur GitHub (ex: `quel_evenement`)
2. Uploadez tous les fichiers (sauf le dossier `sql/`, ou gardez-le pour référence)
3. Allez dans **Settings → Pages**
4. Source : branche `main`, dossier `/ (root)`
5. Sauvegardez → votre site sera accessible sur :
   `https://votre-pseudo.github.io/quel_evenement/`

---

## Utilisation

### Ajouter un admin
- Connectez-vous sur `/admin.html`
- Onglet **Administrateurs** → saisissez l'email et le nom → Ajouter
- La personne pourra se connecter avec un lien magique envoyé par email

### Valider une proposition
- Onglet **Propositions** → cliquez sur **✅ Valider**
- L'événement est automatiquement copié dans la table `events` et visible sur `index.html`

### Voir les événements passés
- Sur `index.html`, cliquez sur **🕓 Voir aussi les événements passés**

---

## Architecture

| Composant | Rôle |
|-----------|------|
| GitHub Pages | Hébergement statique (gratuit) |
| Supabase PostgreSQL | Base de données |
| Supabase Auth | Connexion admin par Magic Link |
| Supabase RLS | Sécurité : chaque rôle voit ce qu'il doit voir |

---

## Tables SQL

| Table | Description |
|-------|-------------|
| `events` | Événements validés et visibles publiquement |
| `proposals` | Propositions soumises par les visiteurs |
| `admins` | Liste des emails autorisés à administrer |
