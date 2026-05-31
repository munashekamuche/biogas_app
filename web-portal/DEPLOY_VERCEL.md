# Deploy web portal on Vercel

Deploy **only** the React app in `web-portal/` — not the Flutter mobile project.

## Option A — Root Directory (recommended)

1. [Vercel](https://vercel.com) → your project → **Settings** → **General**
2. **Root Directory** → Edit → select **`web-portal`** → Save
3. Framework should auto-detect **Vite**
4. **Build Command:** `npm run build`
5. **Output Directory:** `dist`
6. Redeploy

## Option B — Deploy whole repo

If you keep the repository root as the project root, the root `vercel.json` runs the build inside `web-portal/` and publishes `web-portal/dist`.

## Environment variables (required)

In Vercel → **Settings** → **Environment Variables**, add (from `web-portal/.env.example`):

| Name | Example |
|------|---------|
| `VITE_FIREBASE_API_KEY` | your API key |
| `VITE_FIREBASE_AUTH_DOMAIN` | `bgasapp.firebaseapp.com` |
| `VITE_FIREBASE_PROJECT_ID` | `bgasapp` |
| `VITE_FIREBASE_STORAGE_BUCKET` | `bgasapp.firebasestorage.app` |
| `VITE_FIREBASE_MESSAGING_SENDER_ID` | `1002124420686` |
| `VITE_FIREBASE_APP_ID` | your Web app ID from Firebase Console |

Apply to **Production**, **Preview**, and **Development**, then **Redeploy**.

## Firebase Auth (after deploy)

Firebase Console → **Authentication** → **Settings** → **Authorized domains** → add your Vercel URL (e.g. `your-app.vercel.app`).

## Test accounts

See `docs/TEST_ACCOUNTS.md` — office and admin sign in at `/login`.
