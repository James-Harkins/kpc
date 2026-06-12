# CLAUDE.md — Kitchen Pass Classic (KPC)

## What This App Is

A golf trip management app for an annual golf outing. Golfers register for trips, select which rounds and nights they're attending, and costs are calculated accordingly. "Kitchen Pass" = permission slip from the family to go.

Admins manage trips, courses, expenses, and financials. There's a two-day end-of-trip tournament where golfers split into teams and compete in 2v2 (and occasionally 1v1 or 2v1) matchups — the app handles team generation, pairing, score entry, and result tracking.

---

## Tech Stack

- Rails 5.2.8, Ruby 2.7.4
- PostgreSQL (`kpc_development` / `kpc_test`)
- Bootstrap 5, jQuery, Turbolinks — no heavy JS framework
- `bcrypt` / `has_secure_password` — no Devise
- `figaro` for env vars (`config/application.yml`, gitignored)
- `rack-attack` for rate limiting
- Action Mailer via Resend (`RESEND_API_KEY`)
- `letter_opener` for email preview in development
- Dockerized; deployed on Fly.io

---

## Dev Workflow

```bash
rails server        # or bin/rails s
rails console       # bin/rails c
bundle exec rspec   # run tests
```

No asset watcher needed — standard Sprockets pipeline.

---

## Environment Variables

All set via Figaro in `config/application.yml` (not checked in).

| Variable | Purpose |
|---|---|
| `CURRENT_TRIP_NUMBER` | Roman numeral (e.g. `XXV`) — drives `Trip.current` |
| `SITE_ADMIN_EMAIL` | Unlocks site-admin-only actions (create trip, edit courses, broadcast) |
| `REGISTER_TOKEN` | Required token on the registration form — invite-only signup |
| `TREASURER_EMAIL` | Used for financial settlement calculations |
| `TREASURER_NAME` | Displayed in payment instructions |
| `TREASURER_VENMO` | Displayed in payment instructions |
| `TREASURER_PAYPAL` | Displayed in payment instructions |
| `RESEND_API_KEY` | Transactional email delivery |

---

## Auth & Roles

- Session-based auth via `session[:golfer_id]`
- `current_user` returns the logged-in `Golfer`
- Two roles: `default` (0) and `admin` (1) — `enum role: [:default, :admin]`
- Three access levels in `ApplicationController`:
  - `require_login` — any logged-in golfer
  - `require_admin` — any admin
  - `require_site_admin` — only the golfer whose email matches `SITE_ADMIN_EMAIL`
- Registration is invite-only: requires `REGISTER_TOKEN` param to match the env var

---

## Key Models

### `Golfer`
Core user. Has `role` (default/admin), `nickname`, `t_shirt_size`. Auth via `has_secure_password`. Password min 8 chars. Password reset tokens are SHA-256 hashed with 2-hour expiry.

### `Trip`
One per year. `number` is a Roman numeral string (e.g. `"XXV"`). `Trip.current` looks up by `CURRENT_TRIP_NUMBER`. Has a `completed` boolean. `start_date` is a datetime.

### `Round`
Belongs to a `Trip` and optionally a `Course`. Has `date`, `cost`, `tee_time`, `is_tournament_round`. Tournament rounds are excluded from ranking score calculations.

Scopes: `Round.tournament` / `Round.non_tournament`

### `Night`
Belongs to a `Trip`. Represents one night at the house.

### `GolferTrip`
Join between `Golfer` and `Trip`. Tracks `cost`, `balance`, `is_paid`, `is_full_trip`. A "full trip" gets the first night comped.

### `GolferRound`
Join between `Golfer` and `Round`. Has a nullable `score` integer (total strokes — used for tournament ranking).

### `GolferNight`
Join between `Golfer` and `Night`.

### `Course`
`name` + `address`. Shared across trips.

### `Expense`
Belongs to `Trip` and `Golfer` (the admin who paid it). Used to calculate cost splits among committee members.

### `TripFinancialSummary`
Snapshot record created once a trip is finalized. Stores totals for display on the previous trips page.

### `TournamentAssignment`
Belongs to `Trip`, `Golfer`, and `Round`. Stores `team` ("A" or "B"), `matchup_group` (integer), `match_type` ("2v2", "1v1", "2v1"). Unique per (trip, golfer, round).

Contains the full team-generation algorithm: serpentine assignment within groups of 4 (A gets positions 0+3, B gets 1+2), with tail handling for all N mod 4 cases.

### `TournamentMatchupResult`
Belongs to `Round`. Stores `matchup_group` and `result` ("A", "B", or "tie"). Unique per (round, matchup_group). `team_points(trip)` aggregates wins (1pt) and ties (0.5pt) across all rounds.

---

## Facades

### `GolferTripFacade`
Located in `app/facades/`. Used in `GolferTripsController#create` to handle golfer registration — creates `GolferNight` and `GolferRound` records based on form params, and determines `is_full_trip`.

---

## Mailers (`GolferMailer`)

| Method | Trigger |
|---|---|
| `trip_signup` | Golfer registers for a trip |
| `payment_received` | Payment recorded |
| `balance_paid` | Balance marked as paid in full |
| `password_reset` | Password reset requested |
| `announcement` | Admin broadcasts to all registered golfers |
| `trip_reminder_paid` / `trip_reminder_unpaid` | Called manually from console ~1 month before trip |

---

## Routes Summary

```
GET  /                        welcome#index
GET  /dashboard               golfers#show
GET  /register                golfers#new
POST /golfers                 golfers#create
GET/PATCH /profile(/edit)     golfers#edit/update
GET/POST /login               sessions
DELETE /logout                sessions

GET/POST /register_trip       golfer_trips#new/create
GET/PATCH /golfer_trips/:id   golfer_trips#edit/admin_update (site admin only)
PUT /update_golfer_payment    golfer_trips#update

GET  /finances                finances#index (admin)
GET  /attendance              attendance#index (admin)
GET  /roster                  rosters#index
GET  /previous_trips          previous_trips#index
POST /trip_financial_summaries

GET/POST /announcements/new   announcements (site admin)
GET/PATCH /password_resets

# Trip mgmt (site admin)
GET/POST  /trips/new, /trips
GET/PATCH /trips/:id/edit, /trips/:id
PATCH     /trips/:id/complete

# Course mgmt (site admin)
/courses (index/new/create/edit/update)

# Expense mgmt (admin)
/expenses (index/new/create/edit/update/destroy)

# Tournament (admin)
GET  /tournament
POST /tournament/generate
POST /tournament/redraw       # ?round_id=X
GET/PATCH /rounds/:id/scores
PATCH /tournament_assignments/:id
PATCH /tournament_matchup_results/:round_id
```

---

## Tournament Feature

### How it works

1. Admin marks 2 rounds as `is_tournament_round: true` on the trip edit page
2. Admin enters stroke scores for golfers on non-tournament rounds via `/rounds/:id/scores`
3. Admin visits `/tournament` and clicks "Generate Teams"
4. Algorithm ranks players by average score (ascending — lower = better), then uses serpentine assignment into groups of 4 to produce balanced teams
5. Pairings are generated per round (same by default, but each round's assignments are independent records)
6. Admin can redraw pairings for a single round or override individual player assignments
7. After each tournament round, admin enters results (Team A wins / Tie / Team B wins) per matchup group
8. Team standings aggregate automatically

### Score fallback
If a golfer has no scores on the current trip's non-tournament rounds, the algorithm falls back to their average score from the most recent prior trip. Golfers with no history at all sort last (treated as weakest).

### Team generation algorithm
- Sort participants ascending by avg score (rank 1 = best)
- Decompose into groups of 4, with tail groups of 3 (triple → 2v1) or 2 (pair → 1v1) as needed
- Within each group of 4: A gets positions 0 and 3 (best + worst), B gets 1 and 2 (middle two)
- This guarantees equal rank sums within every foursome (provably exact when N mod 4 == 0)

---

## Tests

RSpec. Run with:

```bash
bundle exec rspec
bundle exec rspec spec/models/
bundle exec rspec spec/models/tournament_assignment_spec.rb
```

Uses `shoulda-matchers` for one-liner relationship/validation assertions. Database is cleaned via transactional fixtures (`use_transactional_fixtures = true`). Existing tests use direct `Model.create!` calls; new tests should use FactoryBot factories for scalability.

---

## Conventions

- No Devise. Auth is custom and intentional — don't add Devise.
- No service objects except `GolferTripFacade` (which predates this convention). Keep logic in models.
- Controllers are thin. Business logic lives in model class/instance methods.
- Views use inline `<style>` blocks — no separate CSS files. Background image is `course_1.jpg` via `asset_path`.
- `button_to` with `method: :get` is used for navigation buttons throughout the admin UI. This is intentional (existing pattern).
- All admin actions use `before_action :require_admin`. Site-admin-only actions use `require_site_admin`.
- `Trip.current` is the single source of truth for the active trip — driven by `CURRENT_TRIP_NUMBER` env var, not a database flag.
