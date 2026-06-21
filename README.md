# Samie & Faizah — Nikkah RSVP

A single-page wedding RSVP site for the nikah of **Samie Belal & Faizah Muhib**, Saturday, August 22, 2026 · 6PM, at The Mirage Banquet Center, Clinton Township, Michigan.

The site is one self-contained `index.html` — fonts, the watercolor background, and the title art are all embedded, so it has no external asset dependencies and renders identically anywhere. RSVPs are written to a Supabase table.

## Project structure

```
.
├── index.html            # the entire site (fonts + images embedded)
├── supabase/
│   └── schema.sql        # table + row-level-security policy
├── .gitignore
└── README.md
```

## Setup

### 1. Supabase
1. Create a free project at https://supabase.com.
2. In the project, open **SQL Editor → New query**, paste the contents of [`supabase/schema.sql`](supabase/schema.sql), and **Run**. This creates the `rsvps` table and a policy that lets guests submit but not read each other's responses.
3. Go to **Settings → API** and copy your **Project URL** and **anon public** key.

### 2. Add your keys
Open `index.html`, find this block near the top of the `<script>`, and paste your two values:

```js
const SUPABASE_URL = 'https://YOUR-PROJECT-REF.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR-ANON-PUBLIC-KEY';
```

> The anon key is designed to be public and is safe to ship in client-side code — it's protected by the row-level-security policy above.

### 3. Preview locally
Just open `index.html` in a browser, or serve the folder:

```bash
python3 -m http.server 8000
# then visit http://localhost:8000
```

## Viewing responses

Open your Supabase project → **Table Editor → `rsvps`**. That's your spreadsheet view (name, attending, party size, guest names, phone, timestamp). Use **Export → CSV** to open it in Excel.

## Deploy

Any static host works. Easiest options:

- **Vercel** — `npm i -g vercel` then `vercel` in this folder, or import the repo at vercel.com.
- **Netlify** — drag the folder onto app.netlify.com, or connect the repo.
- **GitHub Pages** — Settings → Pages → deploy from the `main` branch.

## Notes

- Form collects: name, additional guests (add-as-many), accept/decline, and phone (required when attending).
- Party size is computed automatically (responder + guests).
- Includes a `prefers-reduced-motion` fallback for the entry animations.
