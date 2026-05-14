# KPC Payment Automation: Committee Summary

**Date:** February 2026
**Status:** Under Consideration — No Decision Made Yet

---

## The Problem We're Solving

Right now, when a golfer pays their trip balance, nothing happens automatically. The treasurer has to manually log into the app and record each payment by hand. This creates delays between when money arrives and when the app reflects it, and it's an ongoing time burden on the treasurer.

This proposal explores **automating payment tracking for US golfers**, so that when a payment clears, the app records it, updates the golfer's balance, and sends a confirmation email — all without the treasurer doing anything.

Canadian golfers would continue paying the same way they do today, with the treasurer manually recording those payments.

---

## What Would Change for Golfers

US golfers would pay their trip balance via **bank transfer directly through the KPC app**. The process would look like this:

1. Golfer logs into the KPC app and sees their balance
2. They click **"Pay by Bank Transfer"**
3. A secure Stripe-hosted screen appears — they connect their bank account by logging into their bank (takes about 1 minute) or by entering their routing and account numbers
4. They confirm the amount and submit
5. **3–4 business days later**, the transfer clears — the app automatically records the payment, updates their balance, and sends them a confirmation email

No follow-up is needed from the golfer or the treasurer.

Canadian golfers would see no change whatsoever. They would continue to pay via Venmo, PayPal, check, or however they do today, and the treasurer would record those payments manually as usual.

---

## What Would Change for the Treasurer

### One-Time Setup
The treasurer would create a free account with **Stripe** (a widely-used payment platform) and complete a standard identity verification (name, address, date of birth, last 4 of SSN — the same information any financial platform requires). They would then link a personal checking account to receive payouts.

### Ongoing
- Stripe automatically deposits collected funds into the treasurer's checking account, typically within a week of a golfer initiating payment
- The Stripe website provides a full record of all transactions, pending payments, and payout history
- The KPC app's existing finances page continues to show all golfer balances and payment history
- Canadian golfer payments continue to be recorded manually, exactly as today

### Important: Tax Reporting
Stripe is required by the IRS to send a **1099-K tax form** to any account that receives more than $600/year. Since the treasurer would be collecting several thousand dollars annually, they will receive one. A 1099-K reports the gross dollar amount processed — it does not mean the treasurer owes taxes on that money (they are collecting on behalf of the group, not earning income). However, it does create a paper trail that may require a note on a tax return. **The treasurer should be aware of this and comfortable with it before we move forward.**

---

## Cost

The payment processor charges **0.8% per transaction, with a maximum of $5.00**.

| Payment Amount | Fee |
|---|---|
| $300 | $2.40 |
| $400 | $3.20 |
| $500 | $4.00 |
| $625 or more | $5.00 (cap) |

For a year where we collect roughly $10,000 from US golfers, total estimated fees would be around **$50–75**. There are no monthly fees, no setup fees — we only pay when a payment is collected.

For comparison, PayPal Friends & Family payments currently cost $0 in fees. The Stripe fee is the cost of automation. Whether that trade-off makes sense is a committee decision.

---

## Two Options to Consider

### Option A: Bank Transfer as an Added Choice

US golfers would see both the existing payment instructions (Venmo, PayPal, check) **and** a new "Pay by Bank Transfer" option. They choose whichever they prefer.

**Upside:** Non-disruptive. Golfers who prefer their current methods can keep using them.

**Downside:** The treasurer may still receive a mix of Stripe payments and manual payments from US golfers, so some manual tracking burden would remain. Adoption is uncertain.

---

### Option B: Bank Transfer Required for US Golfers

US golfers would **only** see the bank transfer option. The Venmo/PayPal/check instructions would no longer appear for US golfers. The treasurer could still manually record any payment for any golfer in edge cases.

**Upside:** Full automation for all US payments — the treasurer does not need to track or record any US payment. Clean, predictable process.

**Downside:** US golfers must complete a one-time bank account connection step before paying. Most will find it straightforward, but some — particularly members less familiar with online banking — may find it unfamiliar or uncomfortable.

---

## Risks Worth Knowing

**Payments are not instant.** There is a 3–4 business day window between when a golfer submits a payment and when it clears. During that window, the golfer's app would show a "payment pending" status so they know it's on the way.

**Payments can occasionally fail.** If a golfer's account has insufficient funds or incorrect details, the transfer is returned. Stripe charges a **$4.00 fee for failed transfers**. The treasurer would need to follow up with the golfer in those cases.

**The bank connection step is new.** Golfers need to complete a one-time bank account verification before their first payment. It typically takes about a minute, but it is a new step compared to simply sending a Venmo.

---

## What the Committee Needs to Decide

1. **Is the treasurer willing to set up a Stripe account and accept 1099-K tax reporting?** If not, we stop here — the current manual process continues with no changes.

2. **If yes: Option A (bank transfer as an added option) or Option B (bank transfer required for US golfers)?**

3. **Is the estimated $50–75/year in processing fees acceptable** in exchange for fully automating US payment tracking?

If the preference is to keep the current zero-fee, manual process and have the treasurer continue recording payments by hand, that is a perfectly valid choice and requires no changes to the app.
