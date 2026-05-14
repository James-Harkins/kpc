# KPC — Golf Trip Management App

Full-stack Ruby on Rails 5.2.8 web application for managing an annual group golf trip. Members register for the trip, select which nights and rounds they'll attend, and track payments. Admins manage trip logistics, record payments, and monitor trip finances in real time.

---

## Features

### For Golfers
- **Registration & Authentication** — Account creation with invite token, secure login/logout, and password reset via tokenized email link
- **Trip Registration** — Select individual nights and golf rounds, or register for the full trip (which applies a first-night discount)
- **Personal Dashboard** — View trip itinerary, cost breakdown, payment history, and outstanding balance
- **Profile Management** — Update name, email, password, and t-shirt size

### For Admins
- **Finances Page** — Live view of every golfer's cost, net paid, outstanding balance, and paid status across the trip
- **Payment Recording** — Log payments as they arrive, mark golfers as fully paid in one step, or record partial payments
- **Return Processing** — Issue refunds when a golfer's cost is reduced after they've already paid; overpayment is flagged with a warning before processing
- **Golfer Trip Editing** — Modify which nights and rounds a golfer is attending after registration; cost and balance recalculate automatically
- **Expense Tracking** — Log and manage trip expenses
- **Attendance Calendar** — Visual grid of which golfers are attending each night and playing each round
- **Course Management** — Maintain a database of golf courses with address information
- **Trip Announcements** — Send announcements to all registered golfers via email
- **Previous Trips** — Historical archive of past trips with attendance and financial records
- **Trip Finalization** — Lock in a trip financial summary snapshot (site admin only)

### Automated Workflows
- **Pre-trip reminder emails** — A GitHub Actions scheduled job runs daily starting in the weeks before the trip and sends reminder emails to golfers with outstanding balances; the workflow self-disables after March 1
- **Transactional emails** — Trip signup confirmation, payment received, and balance paid emails fire automatically on the corresponding events

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Ruby on Rails 5.2.8 |
| Language | Ruby 2.7.4 |
| Database | PostgreSQL |
| Frontend | Bootstrap 5.1.3, jQuery 3.6.0, Turbolinks 5, SCSS |
| Authentication | bcrypt (`has_secure_password`), custom session management |
| Authorization | Role-based (`default` / `admin`), site admin via env var |
| Email | ActionMailer + LetterOpener (development) |
| Rate Limiting | Rack::Attack |
| Environment Config | Figaro |
| Markdown Rendering | Redcarpet |
| Testing | RSpec, FactoryBot, Faker, WebMock, VCR, SimpleCov |
| Linting | StandardRB |
| Containerization | Docker |
| Hosting | Fly.io |
| CI/CD | GitHub Actions |

---

## Database Schema

![Database schema](https://github.com/user-attachments/assets/e750002f-8c8d-4cbd-91bb-19439f06808a)

### Key Models

| Model | Description |
|---|---|
| `Golfer` | User accounts with roles (`default`, `admin`) |
| `Trip` | A single annual golf trip with year, number, location, and dates |
| `Night` | An individual night of accommodation on a trip, with a per-night cost |
| `Round` | An individual golf round on a trip, with a per-round cost |
| `GolferTrip` | Join table recording a golfer's registration for a trip; holds `cost`, `balance`, `is_paid`, and `is_full_trip` |
| `GolferNight` | Records which nights a golfer is attending |
| `GolferRound` | Records which rounds a golfer is playing |
| `Payment` | A payment or return for a golfer trip; negative `amount` values represent returns |
| `Expense` | A trip expense attributed to a golfer |
| `Course` | A golf course with address info |
| `TripFinancialSummary` | A finalized financial snapshot of a completed trip |

---

## Architecture Highlights

### Financial Logic

The core financial invariant is:

```
balance = max(cost - payments.sum(:amount), 0)
```

Every code path that writes to `balance` recomputes it from a fresh `payments.sum` rather than from the cached `balance` value, preventing drift. Returns are modeled as `Payment` records with a negative `amount` — no separate table.

The payment system handles five distinct flows: registration, adding a payment, marking as paid in one step, admin editing of nights/rounds (with overpayment detection and confirmation), and processing returns. See [`FINANCIAL_LOGIC.md`](FINANCIAL_LOGIC.md) for a complete walkthrough.

### Trip Cost Calculation

A golfer's cost is computed from the nights and rounds they selected:

- **Gross cost** = sum of selected night costs + sum of selected round costs
- **Full trip discount** — if the golfer attends every night and every round, the first night is free
- `is_full_trip` is detected automatically during registration by comparing selected counts against total trip counts, or via an explicit "whole enchilada" registration option

### Role-Based Authorization

Two authorization levels are enforced via before-action filters throughout the controllers:

- **`require_admin`** — any golfer with `role: :admin`; gates payment recording, the finances page, and attendance views
- **`require_site_admin`** — a single designated golfer identified by matching `SITE_ADMIN_EMAIL`; gates return processing, golfer trip editing, and trip finalization

### Password Reset Security

Reset tokens are generated with `SecureRandom.urlsafe_base64`, immediately hashed with SHA256 before being stored in the database, and expire after 2 hours. The raw token is sent in the email link; the hashed version is what's stored — the database never holds a redeemable token.

### Automated Email Scheduling

A GitHub Actions workflow runs on a daily cron schedule and fires pre-trip reminder emails via a Fly.io one-off machine running `rails emails:send_pre_trip_reminder`. The workflow includes a dry-run input for testing and self-disables on March 1 each year so it doesn't continue running after the relevant window.

---

## Local Development Setup

### Prerequisites

- Ruby 2.7.4
- PostgreSQL
- Node.js 18+ and Yarn 1.22+
- Bundler

### Steps

```bash
# Clone the repo
git clone <repo-url>
cd kpc

# Install dependencies
bundle install
yarn install

# Set up environment variables
cp config/application.yml.example config/application.yml
# Edit config/application.yml and fill in required values

# Create and migrate the database
rails db:create db:migrate

# (Optional) Seed with demo data — Sopranos-themed golfers
rails db:seed

# Start the server
rails server
```

### Required Environment Variables (`config/application.yml`)

| Key | Description |
|---|---|
| `REGISTER_TOKEN` | Token required to create a new account |
| `SITE_ADMIN_EMAIL` | Email address of the site admin golfer |
| `TREASURER_NAME` | Displayed on the payment instructions page |
| `TREASURER_EMAIL` | Treasurer's email for payment reference |
| `TREASURER_VENMO` | Treasurer's Venmo handle |
| `TREASURER_PAYPAL` | Treasurer's PayPal handle |
| `CURRENT_TRIP_NUMBER` | Roman numeral of the current trip (e.g., `XXVI`) |

---

## Running Tests

```bash
bundle exec rspec
```

SimpleCov reports **100% line coverage** across all tracked files. Coverage is measured on the application's business logic layer — models, helpers, and facades. Controllers are excluded from the SimpleCov metric; they are thin orchestration layers (find a record, call a model method, redirect) that are better verified by integration/request specs than by unit tests. A representative set of request specs covers the sessions controller to demonstrate the pattern. Full controller and routing coverage is the intended next step.

### What's tested

| Layer | Approach | Coverage |
|---|---|---|
| Models | RSpec unit specs | 100% |
| `ApplicationHelper` | RSpec helper specs | 100% |
| `GolferTripFacade` | RSpec unit specs | 100% |
| Controllers | RSpec request specs (sessions) | Representative |

### Test tooling

| Tool | Purpose |
|---|---|
| RSpec | Test framework |
| Shoulda-Matchers | Concise association and validation matchers |
| SimpleCov | Line coverage reporting |
| FactoryBot | Test object factories |
| Faker | Randomized test data |
| WebMock | HTTP request stubbing |
| VCR | Record/replay HTTP interactions |

```bash
# Lint with StandardRB
bundle exec standardrb
```

---

## Deployment

The app is containerized with Docker and deployed to [Fly.io](https://fly.io).

```bash
# Deploy (requires flyctl and FLY_API_TOKEN)
flyctl deploy --remote-only
```

Continuous deployment is handled by a GitHub Actions workflow (`.github/workflows/fly-deploy.yml`) that triggers on every push to `main`.

Database migrations run automatically as part of the Fly.io release command before the new version of the app goes live.
