# Dashboard gas time estimate

`GET /api/gas/prediction/?sensor_id=13` returns the selected account-owned sensor's
`projected_days`, `projected_hours`, `expected_depletion_date`, `prediction_source`,
`daily_consumption_kg`, `confidence`, `trend`, and advice in plain English.

The backend groups up to 30 days of readings by hour. It estimates gas use from
weight decreases, including idle time and skipping large refill/calibration
changes and offline gaps over two days. Small scale fluctuations do not accumulate
as consumption. The latest gross weight, the account's tare weight, and its chosen
bottle capacity determine the current gas amount.

At least one hour of observed use supports an early estimate; a full day or more
is better. With no measurable use, the response says it is still learning. An
empty bottle returns zero with `trend: empty`, even without historical readings.

The forecast calls Google Gemini directly through its `generateContent` API.
Set the Google AI Studio key only on the Django service:

```dotenv
GEMINI_API_KEY=your_google_ai_studio_key
GEMINI_MODEL=gemini-3.5-flash-lite
```

Only aggregated consumption metrics are sent to Gemini. Its proposed daily rate
must remain within half to twice the measured baseline. If Gemini is unavailable,
malformed, outside those bounds, disabled for the sensor, or unconfigured, the
measured-use calculation remains available and `prediction_source` is `usage`
rather than `ai`.

See Google's [Gemini generateContent API documentation](https://ai.google.dev/api/generate-content).

History is cached for five minutes and successful AI rates for ten minutes.
AI failures back off for one minute. Each request uses the latest weight to
recalculate time left; the cached value is a rate, not an old number of days.
Both client dashboards refresh automatically every 30 seconds and show hours or
minutes for time under one day. Confidence describes history coverage, not a
validated percentage accuracy guarantee.

Deploy the backend changes to Railway and rebuild/restart the client apps to make
the feature live. No database migration is needed.

Checks (the backend command uses an isolated in-memory test database):

```sh
DATABASE_URL=sqlite:///:memory: OPENROUTER_API_KEY= backend/venv/bin/python backend/manage.py test mynewapp.test_gas_prediction --noinput
cd mobilefrontend
flutter test test/gas_prediction_test.dart --no-pub
```
