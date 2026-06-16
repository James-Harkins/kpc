Build a read-only scoreboard page for the Kitchen Pass Classic app (Rails 5.2, PostgreSQL, Bootstrap 5, jQuery). The page should display golfer scores by round for a given trip and serve as a live scoreboard that can be displayed on a TV during the trip.

**Access:** Admin only (`before_action :require_admin`). Add a "Scoreboard" button to the admin dashboard alongside the existing admin buttons.

**Route:** `GET /scoreboard` — defaults to the current trip (`Trip.current`), but accepts an optional `?trip_id=X` param so past trips can be viewed too.

**Display:** A table where rows are golfers (sorted by total strokes ascending, i.e. best score first) and columns are the non-tournament rounds for the trip (`Round.non_tournament`), ordered by date. Each cell shows that golfer's score for that round (`GolferRound#score`, which is nullable — show `—` if not yet entered). Include a "Total" column summing entered scores. Only show golfers who are registered for the trip (`GolferTrip`).

**TV-friendly styling:** Large text, high contrast, minimal chrome. Inline `<style>` block in the view (existing convention). No pagination.

**Existing patterns to follow:**
- `Trip.current` for the active trip
- `Round` scopes: `Round.non_tournament`
- `GolferRound` is the join between `Golfer` and `Round`, has a nullable `score` integer
- `GolferTrip` is the join between `Golfer` and `Trip`
- Controllers are thin — put query logic in the model or as straightforward ActiveRecord calls
- `before_action :require_admin` in `ApplicationController`
- Button to the page goes in `app/views/golfers/show.html.erb` in the admin button row

**Do not** add sorting controls, filters, pagination, or auto-refresh. Keep it simple.
