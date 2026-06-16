# Trip Lifecycle

End-to-end process for creating, running, and closing out a KPC trip.

---

## 1. Create the Trip

**Who:** Site admin only (the golfer whose email matches `SITE_ADMIN_EMAIL`)

**How:** Dashboard → "Create Trip" button → `/trips/new`

Fill in:
- **Year**, **Number** (Roman numeral, e.g. `XXVI`), **Location**, **Start date**
- **Nights** — one row per night: date + cost
- **Rounds** — one row per round: date + cost + tee time + course + tournament round checkbox

On save, the `Trip`, `Night`, and `Round` records are created. The trip is not yet visible to golfers.

---

## 2. Open Registration

**Who:** Site admin (Fly.io dashboard or CLI)

**How:** Set the `CURRENT_TRIP_NUMBER` secret in Fly to the trip's Roman numeral number:

```bash
fly secrets set CURRENT_TRIP_NUMBER=XXVI -a <app-name>
```

This triggers a redeploy. Once live, `Trip.current` returns the new trip.

**What golfers see:**
- Registered golfers: full trip details, calendar, balance
- Unregistered golfers: "Sign up for KPC XXVI" button
- Trip reminder emails should be sent manually from the console roughly one month before the trip:

```ruby
# From rails console on Fly:
GolferMailer.trip_reminder_paid(golfer, golfer_trip).deliver_now
GolferMailer.trip_reminder_unpaid(golfer, golfer_trip).deliver_now
```

---

## 3. Decommission from Golfer Dashboards

**When:** After the trip ends and golfers no longer need to see it on their dashboards.

**How:** Unset `CURRENT_TRIP_NUMBER` in Fly:

```bash
fly secrets unset CURRENT_TRIP_NUMBER -a <app-name>
```

This triggers a redeploy. `Trip.current` returns `nil`.

**What golfers see:** "Stay tuned for KPC XXVII!" (or equivalent next number). No trip details, no registration link.

**Admins:** The trip is still accessible via the "Edit Trip" dropdown on the dashboard (which shows all trips with a future or recent start date). Finances, attendance, and tournament features remain fully functional.

> **Note:** `config/application.yml` is excluded from the Docker image via `.dockerignore`, so the Fly secret is the sole source of truth for `CURRENT_TRIP_NUMBER` in production.

---

## 4. Finalize Finances

**Who:** Site admin

**When:** After all payments have been recorded and expenses entered.

**How:** Finances page (`/finances?trip_id=<id>`) → "Finalize Trip Finances" button at the bottom.

This creates a `TripFinancialSummary` snapshot record for the trip containing:
- Total projected revenue (sum of golfer trip costs)
- Total expenses
- Net deficit (expenses − revenue)
- Committee count and fair share per admin

The summary is idempotent — clicking again overwrites the existing snapshot with current figures. It can be regenerated if costs or expenses change after the initial save.

Once created, the summary appears on the Previous Trips page for that trip.

---

## 5. Complete the Trip

**Who:** Site admin

**When:** After finances are finalized and all settlements are confirmed.

**How:** Finances page → "Complete Trip" button (appears after a `TripFinancialSummary` exists).

This sets `trip.completed = true`. The trip:
- Moves to the Previous Trips page (`/previous_trips`)
- No longer appears in the admin "Edit Trip" dropdown
- Shows full financial summary and attendance grid on the Previous Trips page

The completed flag is permanent — there is no "uncomplete" action in the UI.

---

## Summary

| Step | Action | Where |
|------|--------|-------|
| 1. Create | Fill out trip form | Dashboard → "Create Trip" |
| 2. Open registration | `fly secrets set CURRENT_TRIP_NUMBER=XXVI` | Fly CLI |
| 3. Decommission | `fly secrets unset CURRENT_TRIP_NUMBER` | Fly CLI |
| 4. Finalize finances | Click "Finalize Trip Finances" | `/finances` |
| 5. Complete | Click "Complete Trip" | `/finances` |
