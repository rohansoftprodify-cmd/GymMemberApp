# Gym Member App (Flutter + Supabase)

Mobile app for gym members: sign in with credentials from your gym, view membership, attendance, and offers.

Backend (database, RLS, edge functions) lives in the companion **[gym_owner_app](https://github.com/your-org/gym_owner_app)** repository. Both apps use the **same Supabase project**.

## Setup

1. Install [Flutter](https://docs.flutter.dev/get-started/install) stable.
2. Apply Supabase migrations from `gym_owner_app` (including member account migrations).
3. Deploy the `create-gym-member` edge function from `gym_owner_app` (gym owner creates accounts).
4. Copy `config.example.json` to `config.json` locally (optional; `config.json` is gitignored) or pass keys via `--dart-define`.
5. From this project root:

```bash
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=<your-project-url> \
  --dart-define=SUPABASE_ANON_KEY=<your-anon-key>
```

## How members get access

1. Gym owner uses **Gym Owner App** → Gym Profile → **Members** → **Add member**.
2. Owner shares the email and password shown after creation.
3. Member signs in here with those credentials.

Each member is linked to **one gym only** via `gym_roles.role = member` and `members.user_id`. Row-level security prevents access to other gyms or other members’ data.

## Project layout

- `lib/src/core/` — Supabase, theme, member context (`get_my_member_context` RPC)
- `lib/src/features/` — splash, login, home, attendance

## Related repo

| Repo | Purpose |
|------|---------|
| `gym_owner_app` | Owner/staff dashboard, member provisioning, Supabase schema |
| `gym_member_app` (this repo) | Member-facing mobile app |
