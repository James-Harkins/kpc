# KPC Financial Logic

## Data Model

### `golfer_trips` columns relevant to finances
| Column | Type | Description |
|---|---|---|
| `cost` | integer | The golfer's total owed cost for the trip (dollars, no cents) |
| `balance` | integer | Amount still owed. Always `max(cost - net_paid, 0)` |
| `is_paid` | boolean | True when `balance == 0` |
| `is_full_trip` | boolean | True when the golfer registered for all nights + all rounds |

### `payments` columns
| Column | Type | Description |
|---|---|---|
| `amount` | integer | Positive = payment received. Negative = return issued |
| `golfer_trip_id` | integer | FK to `golfer_trips` |

Payments and returns share the same table. A return is a `Payment` record with a negative `amount`. There is no separate returns table.

---

## Core Invariant

**`balance` must always equal `max(cost - payments.sum(:amount), 0)`**

`payments.sum(:amount)` is the **net paid** — the sum of all payments minus all returns for that golfer trip. Every code path that writes to `balance` recomputes it from this sum rather than from the cached `balance` value, preventing drift.

`is_paid` is always `balance == 0`. A golfer is marked paid when they owe nothing, which includes the overpayment case (they paid more than cost; balance stays 0).

---

## Cost Calculation

### Components
- **Night cost**: sum of `nights.cost` for each night the golfer selected on this trip
  → `Golfer#trip_nights_total_cost(trip_id)`
- **Round cost**: sum of `rounds.cost` for each round the golfer selected
  → `Golfer#trip_rounds_total_cost(trip_id)`
- **Gross cost**: nights + rounds
  → `Golfer#trip_gross_total_cost(trip_id)`

### Full Trip Discount
If `golfer_trip.is_full_trip == true`, the golfer selected **every night and every round** on the trip. They receive the first night free.

```
net_cost = gross_cost - trip.nights.first.cost   # "first" = earliest date
```

If not a full trip:
```
net_cost = gross_cost
```

→ `Golfer#trip_net_total_cost(trip_id)`

### What counts as a full trip
`GolferTripFacade.is_full_trip` returns true when:
- The `full_trip` param was explicitly submitted (the "whole enchilada" button), **or**
- The count of selected nights equals the total nights on the trip **and** the count of selected rounds equals the total rounds on the trip

On an admin update (`GolferTripsController#admin_update`), full trip is determined by comparing the sorted submitted night/round ID arrays against the sorted valid trip night/round ID arrays.

---

## Revenue Numbers (`Trip` model)

### `total_projected_revenue`
```ruby
golfer_trips.sum(:cost)
```
The total cost owed by all registered golfers. Updates whenever `golfer_trip.cost` changes (i.e., after admin edits a golfer's nights/rounds).

### `total_collected_revenue`
```ruby
golfer_trips.each { |gt| revenue += gt.payments.sum(:amount) }
```
The net cash actually received: sum of all payments minus all returns across all golfer trips for this trip. Automatically decreases when a return is processed.

### `total_uncollected_revenue`
```ruby
golfer_trips.sum(:balance)
```
The total outstanding balance across all golfer trips. Because `balance` is always recomputed from `payments.sum`, this stays accurate.

### Relationship between the three
When there are no overpayments:
```
total_projected_revenue == total_collected_revenue + total_uncollected_revenue
```

When a golfer has overpaid (net paid > cost, balance = 0):
```
total_collected_revenue > total_projected_revenue - total_uncollected_revenue
```
The difference is the total amount that has been collected in excess of what was owed — i.e., the sum of all unprocessed overpayments across golfers.

---

## Payment Flows

### 1. Registration (`GolferTripsController#create`)

1. `GolferTripFacade.create_new_golfer_trip` creates `GolferNight` and `GolferRound` join records
2. `golfer_trip` is saved (cost and balance are still nil at this point)
3. `cost = golfer.trip_net_total_cost(trip.id)` — computed from the just-created join records
4. `golfer_trip.cost = cost`
5. `golfer_trip.balance = cost` — no payments yet, so balance = cost - 0 = cost ✓

Email: `GolferMailer.trip_signup`

### 2. Add a Payment (`PaymentsController#create`)

Guards:
- `amount > 0` — prevents $0 or negative submissions
- `amount <= golfer_trip.balance` — prevents overpayment via this form

Steps:
1. `Payment.create!(amount: amount)`
2. `total_paid = golfer_trip.payments.sum(:amount)` — recomputed fresh
3. `golfer_trip.balance = [golfer_trip.cost - total_paid, 0].max`
4. `golfer_trip.is_paid = golfer_trip.balance == 0`
5. Save

Email: `GolferMailer.balance_paid` if now fully paid, else `GolferMailer.payment_received`

### 3. Mark as Paid (`GolferTripsController#update`)

Used when the admin wants to record full payment in one step, regardless of whether partial payments already exist.

Steps:
1. `total_paid = golfer_trip.payments.sum(:amount)` — net already received
2. `remaining = [golfer_trip.cost - total_paid, 0].max` — how much is actually left
3. `Payment.create!(amount: remaining)` — records exactly what was missing
4. `golfer_trip.balance = 0`
5. `golfer_trip.is_paid = true`
6. Save

Email: `GolferMailer.balance_paid`

Note: If the golfer already has partial payments, only the remaining amount is recorded as a new payment — it does not re-record the full cost.

### 4. Admin Edit of Golfer Nights/Rounds (`GolferTripsController#admin_update`)

Used by site admin to change which nights/rounds a golfer is attending, which changes their cost.

Steps:
1. Intersect submitted night/round IDs with valid trip IDs (security: prevents injecting foreign IDs)
2. Determine `is_full_trip` (all nights + all rounds selected)
3. `gross_cost = sum of selected night costs + sum of selected round costs`
4. `new_cost = gross_cost - first_night_cost` (if full trip, else gross_cost)
5. `total_paid = payments.sum(:amount)` — recomputed fresh

**Overpayment check**: If `new_cost < total_paid` and `confirm_overpayment != '1'`:
- Re-render the edit form with a warning showing how much was overpaid
- Submit button is disabled until the admin checks "I understand, proceed anyway"
- On confirmation: the update proceeds, balance is set to 0, is_paid stays true
- The overpayment amount remains in `total_collected_revenue` until a return is processed

If no overpayment, or after confirmation:
1. Delete removed `GolferNight` / `GolferRound` records; create added ones
2. `new_balance = [new_cost - total_paid, 0].max`
3. `new_is_paid = new_balance == 0`
4. Save `cost`, `balance`, `is_full_trip`, `is_paid` on `golfer_trip`

### 5. Process Return (`ReturnsController#create`)

Used when money needs to be physically returned to a golfer (e.g., after an admin edit reduced their cost below what they already paid).

Site admin only.

Steps:
1. `amount > 0` guard (the admin enters a positive number; the controller negates it)
2. `Payment.create!(amount: -amount)`
3. `total_paid = golfer_trip.payments.sum(:amount)` — now reflects the return
4. `golfer_trip.balance = [golfer_trip.cost - total_paid, 0].max`
5. `golfer_trip.is_paid = golfer_trip.balance == 0`
6. Save

Side effects:
- `total_collected_revenue` decreases by the return amount
- If the return exceeds what was overpaid (e.g., admin returns too much), `total_paid` drops below `cost`, balance goes positive, and `is_paid` flips to false — the golfer appears in the unpaid list with an outstanding balance

---

## Overpayment Lifecycle

```
1. Golfer registers:         cost=$500, balance=$500, net_paid=$0,   is_paid=false
2. Payment received:         cost=$500, balance=$0,   net_paid=$500,  is_paid=true
3. Admin removes a night:    cost=$400, balance=$0,   net_paid=$500,  is_paid=true
   → overpaid by $100, balance clamped to 0
   → "Overpaid by $100 — return needed" shown on finances page
4. Return processed ($100):  cost=$400, balance=$0,   net_paid=$400,  is_paid=true
   → total_collected_revenue decreases by $100
   → books balance correctly
```

---

## Finances Page Display (Site Admin)

For every golfer (paid and unpaid):
- **Net Paid**: `payments.sum(:amount)` — the actual cash in hand for this golfer after any returns
- **Overpaid by $X**: shown in red when `net_paid > cost`; signals a return is needed
- **Process Return form**: present for all golfers; site admin enters the amount to return

For unpaid golfers only:
- **Outstanding Balance**: `golfer_trip.balance`
- **Mark as Paid** button
- **Add a Payment** form

---

## Authorization

| Action | Requirement |
|---|---|
| View finances page | `require_admin` (any admin) |
| Add a payment | `require_admin` (any admin) |
| Mark as paid | `require_admin` (any admin) |
| Edit golfer trip nights/rounds | `require_site_admin` (`SITE_ADMIN_EMAIL` env var) |
| Process a return | `require_site_admin` |

---

## Key Files

| File | Role |
|---|---|
| `app/models/golfer.rb` | Cost calculation methods |
| `app/models/trip.rb` | Revenue aggregate methods |
| `app/models/golfer_trip.rb` | Join model: golfer ↔ trip |
| `app/models/payment.rb` | Payments and returns (shared table) |
| `app/facades/golfer_trip_facade.rb` | Registration logic, full trip detection |
| `app/controllers/golfer_trips_controller.rb` | Registration, mark as paid, admin edit |
| `app/controllers/payments_controller.rb` | Add a payment |
| `app/controllers/returns_controller.rb` | Process a return |
| `app/views/finances/index.html.erb` | Finances dashboard |
