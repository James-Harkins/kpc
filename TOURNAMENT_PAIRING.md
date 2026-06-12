# Kitchen Pass Classic — Tournament Team Generation Explained

This document explains how the app automatically generates tournament teams and pairings. The goal is to create balanced, competitive matchups every time — no manual sorting, no arguments about who goes where.

---

## The Big Picture

The tournament spans two rounds of golf. Before those rounds, every participant gets assigned to either **Team A** or **Team B**, and placed into a **matchup group** (a small group of 2, 3, or 4 golfers who compete directly against each other). After each round, an admin records which team won each matchup, and the app tracks cumulative team points.

The app generates the same team assignments for both tournament rounds by default, but an admin can redraw pairings for a single round independently if needed. Individual assignments can also be overridden one at a time.

---

## Step 1 — Who's In?

The app looks at who is signed up for the tournament rounds. Only golfers registered for those rounds are included in team generation.

---

## Step 2 — Ranking Everyone by Skill

The app calculates an **average stroke score** for each participant using their scores from the non-tournament rounds of the current trip. Lower average = better golfer (golf scoring — lower is better).

**Fallback rules:**
- If a golfer played no non-tournament rounds this trip (or has no scores entered), the app looks back at their scores from the most recent previous trip and uses that average instead.
- If a golfer has absolutely no scoring history anywhere, they're treated as the weakest player and sorted to the bottom of the list.

Once everyone has a score (or fallback), the app sorts the full group from best to worst.

---

## Step 3 — Breaking Into Groups

The sorted list is divided into **groups of 4**, which each play a 2v2 match. If the total number of players doesn't divide evenly into fours, the app handles the leftovers like this:

| Total players | How it breaks down |
|---|---|
| Divisible by 4 (e.g. 8, 12, 16) | All groups of 4 — all 2v2 matches |
| 2 left over (e.g. 10, 14) | Groups of 4, plus one group of 2 — that group plays 1v1 |
| 3 left over (e.g. 11, 15) | Groups of 4, plus one group of 3 — that group plays 2v1 |
| 1 left over (e.g. 9, 13) | Groups of 4, plus one group of 3 and one group of 2 — one 2v1 and one 1v1 |

The leftover groups always come from the **bottom of the ranked list** (the weaker players), so the cleanest 2v2 matchups go to the top of the field.

---

## Step 4 — The Serpentine Assignment

This is the core of the system. Within each group of 4, the app assigns teams using a **serpentine pattern** — the same technique used in fantasy sports drafts. Here's how it works:

Imagine the four players in a group are ranked 1 through 4 (1 = best, 4 = worst):

| Rank in group | Team |
|---|---|
| 1 (best) | **Team A** |
| 2 | **Team B** |
| 3 | **Team B** |
| 4 (worst) | **Team A** |

Team A gets the **best and worst** player. Team B gets the **two middle** players. This is mathematically proven to produce equal combined rank sums — both teams are as balanced as possible given who's in that group.

**Why this is fair:** If you add up the rank numbers, Team A gets 1+4=5 and Team B gets 2+3=5. Every single foursome is perfectly balanced.

**For leftover groups:**
- Group of 3 (2v1): Team A gets rank 1 and 3, Team B gets rank 2 — so Team A sends two players, Team B sends one.
- Group of 2 (1v1): Team A gets rank 1, Team B gets rank 2 — straight head-to-head.

---

## Step 5 — Captain Override

If the trip has designated captains (a Captain A and a Captain B), the app checks after generating all assignments to make sure they landed on the correct teams. If they didn't, it swaps players as needed so Captain A is always on Team A and Captain B is always on Team B. This swap is done without disturbing the overall balance of the pairings any more than necessary.

---

## Scoring

After each tournament round, an admin records the result for each matchup group — Team A wins, Team B wins, or Tie.

- A win is worth **1 point**
- A tie is worth **0.5 points** for each team

Points accumulate across both tournament rounds. Whichever team has more total points at the end wins the tournament.

---

## Manual Overrides

The generated pairings are a starting point. Admins have full control:

- **Redraw for one round** — regenerate all pairings for a single round without touching the other round
- **Override one player** — reassign an individual golfer to a different team or matchup group
- These tools exist for edge cases (someone drops out last minute, etc.)

---

## Summary

1. Players are ranked by average score (lower = better), with fallback to prior trip history
2. Sorted list is divided into groups, mostly fours with leftover handling for odd counts
3. Within each group, Team A gets the best and worst player; Team B gets the two in the middle
4. Captains are always placed on their correct team
5. Both tournament rounds use the same assignments by default
6. Results are entered after each round; points accumulate to a final team winner
