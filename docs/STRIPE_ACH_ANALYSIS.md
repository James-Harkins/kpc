# KPC Payment Automation: Stripe ACH Integration Analysis

**Prepared for:** KPC Committee
**Date:** February 2026
**Status:** Research & Planning — No Implementation Commitment

---

## Background

Currently, the KPC app requires an admin to manually log in and record each payment as it is received from golfers. This is a time burden on the treasurer and is prone to delays between when a payment is received and when the app reflects it. This document evaluates automating payment tracking for US golfers via **Stripe ACH Direct Debit**, while retaining the existing manual process for Canadian golfers.

---

## What Is Stripe ACH Direct Debit?

ACH (Automated Clearing House) is the US bank-to-bank transfer network — the same network that powers direct deposit paychecks and most bill payments. Stripe offers ACH Direct Debit as a payment method through their developer API, allowing apps to initiate bank transfers and receive automated notifications when those transfers settle.

**Key characteristics:**
- Golfer pays directly from their US checking account — no credit card required
- No card network involved; fees are significantly lower than card processing
- Stripe fires a webhook (an automated notification) to the app when a payment settles, triggering automatic recording in the system
- Settlement takes **3–4 business days** from the time the golfer initiates payment
- Funds are automatically deposited into the treasurer's linked checking account within **5–6 business days** of initiation

---

## Why ACH and Not Other Options

Several alternatives were evaluated and ruled out:

| Option | Why Ruled Out |
|---|---|
| **Stripe card payments** | ~2.9% + $0.30 per transaction — too expensive |
| **PayPal Checkout (G&S)** | ~3.49% + $0.49 per transaction — too expensive |
| **PayPal F&F polling** | Webhooks don't fire for Friends & Family transfers; automation requires matching payments to golfers via memo text, which is difficult to enforce reliably |
| **GoCardless** | Cheapest ACH option (~$0.30/transaction) but uses a "pull debit" model that requires golfers to authorize debits from their account — too invasive for a casual group setting |
| **Venmo / Zelle / Cash App** | No developer API available for automated payment detection |
| **Dwolla** | Monthly platform fees make it uneconomical for ~20 annual transactions |

Stripe ACH offers the best balance of cost, automation capability, and familiarity (Stripe is the most widely trusted payment infrastructure in the industry).

---

## The Canadian Golfer Problem

**ACH is a US-only payment network.** Canadian bank accounts cannot participate in ACH transfers. Canadian golfers would need to continue paying the treasurer directly (via PayPal, Venmo, cash, or check) with the treasurer manually recording those payments in the app, exactly as the current process works for everyone today.

This means any Stripe ACH integration is necessarily a **hybrid model**: automated for US golfers, manual for Canadians.

---

## Two Proposed Models

### Model A: Stripe ACH as an Optional Payment Method for US Golfers

US golfers would see both the existing payment instructions (Venmo, PayPal, check) **and** a new "Pay by Bank Transfer" option via Stripe. They can choose whichever method they prefer. The treasurer still accepts manual payments from US golfers and can record them manually if needed.

**Pros:**
- Non-disruptive — golfers who prefer their existing methods can keep using them
- Treasurer retains full flexibility
- Lower adoption risk; golfers who are uncomfortable with a new system can opt out

**Cons:**
- Treasurer may still receive a mix of Stripe and manual payments from US golfers, meaning some manual tracking burden remains
- Harder to realize the full automation benefit if golfers don't adopt Stripe

---

### Model B: Stripe ACH Enforced for US Golfers, Manual Retained Only for Canadians

US golfers would **only** see the Stripe bank transfer option on their dashboard. The Venmo/PayPal/check instructions would be removed from the US golfer view. The treasurer could still manually record payments for any golfer (US or Canadian) via the admin panel, providing a fallback for edge cases.

Canadian golfers would continue to see the existing manual payment instructions unchanged.

**Pros:**
- Full automation for all US payments — treasurer does not need to track or record US payments at all
- Clean, predictable process for the treasurer going forward
- Eliminates the mixed-method tracking burden entirely for the US portion

**Cons:**
- Requires US golfers to go through a one-time bank account verification step (takes ~1–2 minutes via Stripe's bank login flow)
- Removes flexibility for US golfers who prefer Venmo or PayPal
- Treasurer would need to handle any US golfer edge cases (e.g., ACH failure) manually

---

## Cost

**Stripe ACH fee: 0.8% per transaction, capped at $5.00**

| Payment Amount | Fee to Treasurer |
|---|---|
| $300 | $2.40 |
| $400 | $3.20 |
| $500 | $4.00 |
| $625 or more | **$5.00 flat cap** |

For a trip collecting ~$10,000 from US golfers across ~15 transactions, total estimated fees would be in the range of **$50–75 per year**. There are no monthly fees, no setup fees, and no API access fees — the treasurer pays only when a payment is collected.

For context, if golfers currently send PayPal Friends & Family payments, those cost $0 in fees. The Stripe ACH fee is the cost of automation. Whether that trade-off is worthwhile is a committee decision.

---

## What the Golfer Experience Looks Like (US Golfers, Model B)

1. Golfer logs into the KPC app and sees their outstanding balance
2. They click **"Pay by Bank Transfer"**
3. A Stripe-hosted form appears — they connect their bank account either by logging into their bank (instant, ~1 minute) or by entering routing/account numbers manually
4. They confirm the payment amount (up to their full outstanding balance; partial payments are supported)
5. They receive a confirmation that the payment has been initiated
6. **3–4 business days later**, the transfer settles — the app automatically records the payment, decrements their balance, and sends them the existing payment confirmation email
7. If their balance reaches zero, they receive the existing "You're all paid up" email automatically

No further action from the golfer or treasurer is required.

---

## What the Treasurer Experience Looks Like

### Setup (One-Time)
1. Create a free Stripe account at stripe.com
2. Complete identity verification (name, address, last 4 of SSN, date of birth — standard for any regulated financial platform)
3. Link a personal checking account for automatic payouts
4. Share API keys with the developer for app configuration

### Ongoing
- Stripe automatically deposits collected funds into the treasurer's linked checking account on a rolling basis (typically 1–2 business days after ACH settlement)
- The Stripe dashboard provides full visibility into pending payments, settled payments, and payout history
- The KPC app's existing Finances page continues to show all golfer balances and payment history
- Canadian golfer payments continue to be recorded manually via the existing admin panel, same as today

### Important: 1099-K Tax Reporting
Stripe is a regulated financial platform and is required to issue a **1099-K** to any account that receives over **$600/year** in payments (current IRS threshold). Since the treasurer would be collecting several thousand dollars per year through Stripe, they will receive a 1099-K at tax time.

A 1099-K reports gross payment volume — it does not automatically mean tax is owed on that amount (the treasurer is collecting on behalf of the group, not earning income). However, it does create a paper trail that may require a note on a tax return. **The treasurer should be aware of this and comfortable with it before committing to the Stripe approach.**

---

## What Changes in the App

| Component | Change |
|---|---|
| `golfers` database table | Add `canadian` boolean column (default: false) |
| `payments` database table | Add `stripe_payment_intent_id` column (prevents duplicate recording) |
| Golfer registration form | Add "I am a Canadian golfer" checkbox |
| Golfer dashboard | Conditionally show Stripe payment form (US) or existing payment instructions (Canadian) |
| New `StripeController` | Handles payment initiation and incoming Stripe webhook events |
| New routes | Two new endpoints: create payment intent, receive webhook |
| Gemfile | Add `stripe` gem |
| Application layout | Load Stripe.js (Stripe's frontend library) |

## What Does Not Change

- The `PaymentsController` and all existing payment recording logic
- The `GolferTrip` balance tracking
- All existing email automations (payment received, balance paid)
- The admin Finances page and manual payment entry forms
- Canadian golfer experience — entirely unchanged

---

## Key Risks and Considerations

**ACH is not instant.** There is a 3–4 business day window between a golfer initiating payment and the app reflecting it. The golfer dashboard should show a "payment pending" state during this window to avoid confusion.

**ACH payments can fail.** If a golfer's bank account has insufficient funds or incorrect details, the transfer will be returned. Stripe charges a **$4.00 return fee** for failed ACH payments. The treasurer would need to follow up manually in these cases.

**Bank account verification adds a step.** Golfers must complete a one-time bank verification before paying. Stripe's preferred method (logging into their bank via Stripe's modal) takes about 1 minute. Some golfers may find this unfamiliar or uncomfortable, particularly older members. An alternative (entering routing + account numbers manually) is available but requires Stripe to send two small microdeposits that the golfer must verify 2–3 days later.

**The treasurer must be comfortable with Stripe's onboarding.** The identity verification and 1099-K reporting are non-negotiable aspects of using Stripe as a business payment processor.

---

## Recommendation Summary

| Factor | Model A (Optional) | Model B (Enforced for US) |
|---|---|---|
| Automation for US golfers | Partial (only if they opt in) | Full |
| Treasurer manual work (US) | Reduced but not eliminated | Eliminated |
| Treasurer manual work (Canadian) | Same as today | Same as today |
| Golfer disruption | Low | Moderate (one-time bank verification) |
| Annual fees (est. $10K collected) | $50–75 (on Stripe payments only) | $50–75 |
| Complexity to implement | Moderate | Moderate |

**The committee should decide:**
1. Whether the treasurer is willing to set up a Stripe account and accept 1099-K reporting
2. Whether Model A (optional) or Model B (enforced for US) better fits the group's expectations
3. Whether the ~$50–75/year in fees is acceptable in exchange for full US payment automation

If the treasurer prefers to keep the current zero-fee, fully manual process and simply continue recording payments by hand, that remains a perfectly valid choice and requires no development work.

---

## Committee Decision

> **TODO:** Fill this in after the committee meeting before starting development.

```
Decision date:
Proceeding with: Model A / Model B (circle one)
Treasurer who will hold the Stripe account:
Treasurer has been informed of 1099-K reporting: yes / no
Notes:
```

---

## How to Move Forward After the Decision

Once the committee has filled in the section above, share this document with the developer and say:

> "We've made our decision — please implement the Stripe ACH integration as described in `STRIPE_ACH_ANALYSIS.md`."

Claude (or any developer) will read this file, explore the existing codebase, and have everything needed to begin. No additional context is required beyond what is already documented here.

**Before starting development, confirm:**
1. The treasurer has created their Stripe account and completed identity verification at stripe.com
2. The treasurer has their Stripe **publishable key** and **secret key** ready to share with the developer (found in the Stripe dashboard under Developers → API Keys)
3. The committee has decided between Model A and Model B

**The developer will handle:**
- Configuring the app with the Stripe API keys
- Building the payment flow for US golfers
- Setting up automatic payment recording when transfers settle
- Keeping the Canadian golfer experience unchanged
- Testing the full flow in Stripe's sandbox environment before going live
