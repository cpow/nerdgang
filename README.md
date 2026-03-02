# Power Dev

Rails app for curated tech/news workflows plus a new **YouTube Creator Intelligence** dashboard for Typecraft.

## New: YouTube Creator Intelligence (Admin)

Track your own channel(s), competitor channels, and idea backlog from one place.

### Domain models

- `CreatorChannel` - channels you track (`@typecraft_dev`, competitors)
- `CreatorVideo` - videos pulled from YouTube
- `VideoSnapshot` - historical metric snapshots
- `Idea` - video idea backlog with status/score

### Rich model concerns (no service-object-heavy design)

- `MetricScorable` concern on `CreatorVideo` for engagement/traction scoring
- `YoutubeSyncable` concern on `CreatorChannel` for sync behavior and YouTube API pulls

### Admin routes

- `/admin/creator_dashboard` - dashboard + sync trigger
- `/admin/creator_channels` - manage tracked channels
- `/admin/ideas` - manage video ideas

### YouTube sync

Set API key:

```bash
export YOUTUBE_API_KEY=your_api_key
```

Manual sync from UI:
- Admin → Creator Intel → **Sync now**

Or from console:

```bash
bin/rails runner "SyncYoutubeDataJob.perform_now"
```

Recurring schedule:
- `config/recurring.yml` includes `sync_youtube_data` (8am)

## Claude settings

This project already contains Claude settings/instructions at:

- `CLAUDE.md`

And the implementation follows those conventions:
- StandardRB linting
- RSpec + FactoryBot + VCR-compatible test setup
- Concerns-centric domain behavior

## Setup

```bash
bundle install
bin/rails db:setup
bin/dev
```

Admin auth defaults:

```bash
export ADMIN_USERNAME=admin
export ADMIN_PASSWORD=password
```

## Test + lint

```bash
bundle exec rspec
bundle exec standardrb --fix
```
