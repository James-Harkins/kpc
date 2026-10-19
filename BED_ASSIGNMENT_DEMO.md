# Bed Assignment Feature - Committee Demo Script

A guided walkthrough of the new payment-incentive bed assignment system, using the
seeded demo data. Total runtime: about 15 minutes.

## The pitch (say this first)

> Every year we chase the same guys for money, and last year people backed out at the
> last minute without paying a cent - we ate that cost. This year: the 50% deposit is
> **non-refundable**, and the **best beds go to whoever stays the most nights and pays
> their deposit earliest**. First come, first serve. The app now tracks all of it and
> does the bed math for us.

---

## Prep (before the meeting)

```bash
bin/rails db:reset    # rebuilds the full demo scenario
bin/rails s
```

Emails open automatically in the browser (letter_opener) - no real mail is sent.

**Logins used in the demo** (have these ready in a note):

| Character | Email | Password | Role in the demo |
|---|---|---|---|
| Tony | tony@sopranoenterprisesnj.com | badabing1 | Site admin - runs most of the demo |
| Furio | furio@giunta.it | badabing21 | Regular golfer who hasn't registered yet |
| Vito | vito@spatafore.net | badabing18 | Regular golfer, registered, hasn't paid a dime |

**The seeded story**: KPC XXVI, Oct 17–23, deposit deadline was **June 15**. 17 golfers
are registered. Two houses are booked - Main House (9 beds) and Overflow House (4 beds),
13 beds / 19 spots, every bed ranked 1 (master king) to 13 (air mattress). Payments are
backdated so the roster spreads across every priority tier.

---

## Act 1 - What a golfer sees when they register (3 min)

**Log in as Furio** (he hasn't registered).

1. Dashboard → centered **"Sign up for KPC XXVI"** button → click it.
2. Point out the **deposit policy box**:
   > *"Your 50% deposit is non-refundable and due by June 15. The best beds go to the
   > guys who stay the most nights and pay their deposit earliest."*
3. **Click "Sign me up" without checking the box** - red error appears and the page
   scrolls to it. *Talking point: nobody can claim they didn't see the policy; the app
   stores a timestamp of when each golfer accepted it.*
4. Check the box, pick a few nights, register.
5. Back on the dashboard: point out the **house links** - every golfer can click
   through to the VRBO listings. *What golfers can NOT see: bed assignments or anyone's
   payment status. That stays committee-only.*

Log out.

---

## Act 2 - The priority board (4 min)

**Log in as Tony** → click **Beds** (first button in the admin tools card).

1. Walk the table top to bottom - it tells the whole story:
   - **#1–2 Sil & Walnuts** - gray "Admin - first pick." *Committee always picks first. That's us.*
   - **#3 Feech** - Tier 1, met his deposit **January 5**. Earliest payer among the
     full-trip guys → best non-admin bed.
   - **#8 Johnny Sack** - met it ON deadline day, still Tier 1, but 5 nights ranks
     below the 7-night guys. *Nights first, then payment date.*
   - **#11 Eugene** - full trip, but paid **June 20**, five days late → **Tier 2**,
     behind every Tier 1 golfer including 2-night Hesh. *Miss the deadline, drop a tier.
     This is the incentive.*
   - **#15–17 Vito, Junior, Phil** - red, deposit not met. Junior has paid $400 of his
     $510 deposit - *close doesn't count.* They get whatever's left.
2. Two subtleties worth a sentence each:
   - **Chrissy (#6)**: his first payment was $10 short of the deposit - his clock
     started at his *second* payment. The app tracks the exact moment the 50% line is crossed.
   - **Big Pussy (#4)**: overpaid, got a partial refund, stayed above the deposit,
     keeps his early date. *You can't game it, but honest refunds don't punish you.*

---

## Act 3 - Houses and beds (2 min)

Click **Houses** (site-admin button).

1. Show the two houses, each bed with bedroom / capacity / rank. *We enter this once
   when we book the house - even mid-season, since we usually book after registration opens.*
2. Click **Edit** on Main House: show the add-a-bed row and the rank column.
   *Rank 1 = best bed in the trip, across both houses. We decide what "best" means,
   king vs. private room vs. next to the bathroom.*
3. Cancel out - don't save anything.

---

## Act 4 - Assigning beds (3 min)

Back to **Beds**.

1. Click **"Autofill by Priority"** - the whole board fills instantly:
   - Sil → Master King, Walnuts → Ocean View Queen, Feech → next best…
   - …down to the Tier 3 guys doubling up on the futon and pullout couch.
2. *Nothing is saved yet.* Change a couple of dropdowns to show the override,
   e.g., give Phil a kinder spot. *The algorithm suggests; we decide.*
3. Click **Save Assignments** → the priority table's "Current Bed" column fills in.
4. Try assigning the same golfer to two beds → Save → red error, nothing changed.
   *It won't let us double-book anyone.*

---

## Act 5 - The incentive is live (2 min)

Open **Finances** in another tab.

1. Find **Vito** (unpaid) → **Add a Payment** of `510` → submit.
2. Back to **Beds** → refresh: **Vito jumped from #15 to Tier 2**, ahead of the other
   late payers' spots the moment his money landed. *This updates in real time all
   season - pay, and you move up before the next guy does.*
3. (Optional, if asked about refunds) Find a paid golfer → **Process Return** larger
   than half their cost → the browser warns: *"This return dips into the non-refundable
   50% deposit."* We can still do it - it's a warning, not a wall - but the app knows
   the floor, and their priority date resets if they go under.

---

## Act 6 - The nag works for us (1 min)

In a terminal:

```bash
DRY_RUN=true bin/rails emails:send_deposit_reminder
```

Point at the output: it targets **only** the golfers who haven't met their deposit,
skips admins, skips everyone paid up. In production this runs automatically every day
and fires exactly **one week before the deadline**.

Show the actual email (opens in browser):

```bash
bin/rails runner 'gt = Golfer.find_by(nickname: "Vito").golfer_trips.last;
                  GolferMailer.deposit_reminder(gt.golfer, gt).deliver_now'
```

Deposit owed, paid so far, remaining, Venmo/PayPal, and the kicker line:
*"deposits received after the deadline drop a priority tier."*

---

## Wrap-up talking points

- **For golfers, nothing gets harder** - same registration, one checkbox, and they can
  see the houses. Beds stay private to the committee.
- **For us**: enter the house once, click Autofill, tweak, save. The deposit ledger,
  tiers, and reminders run themselves.
- **Decisions still ours**: assignments are manual-final, admins always pick first,
  refunds are warned but never blocked.

**Likely questions:**

| Question | Answer |
|---|---|
| What if someone drops out? | Their registration (and bed) goes away; the deposit stays on the books per the policy - refunding below the 50% floor triggers a warning but is at our discretion. |
| What if the house isn't booked yet? | Registration and payments run normally; add the house whenever it's booked and backfill beds - the priority order has been accumulating the whole time. |
| Can two guys share? | Yes - kings/queens are capacity 2; autofill doubles up the lowest-priority golfers into the lowest-ranked shared beds. |
| What if someone's cost changes? | The deposit is always 50% of *current* cost, computed live from the payment ledger - nothing goes stale. |
| Who sees the bed list? | Admins only. Golfers see the house links and their own costs, nothing else. |

---

*After the demo, run `bin/rails db:reset` to restore the pristine scenario.*
