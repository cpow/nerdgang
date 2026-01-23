# News Aggregator

A Rails 8 application that aggregates tech news from Reddit and Hacker News, providing a clean admin interface to browse, filter, and bookmark articles.

## Features

- **Automated Scraping**: Daily scraping of Reddit and Hacker News via Solid Queue
- **Smart Filtering**: Filter by source, time period, read status, and minimum score
- **Multiple Sort Options**: Sort by recent, hot score, top score, or most comments
- **Bookmarking**: Save articles for later reading
- **Read Tracking**: Automatically marks articles as read when viewed
- **Dark Mode**: Toggle between light and dark themes (defaults to dark)
- **Auto-Cleanup**: Articles older than 14 days are automatically archived

## Sources

**Reddit Subreddits:**
- r/programming, r/webdev, r/javascript, r/python, r/ruby, r/rust, r/golang
- r/linux, r/commandline, r/selfhosted, r/devops, r/sysadmin
- r/opensource, r/LocalLLaMA

**Hacker News:**
- Top stories from the front page

## Setup

```bash
# Install dependencies
bundle install

# Setup database
bin/rails db:setup

# Start the development server
bin/dev
```

Visit `http://localhost:3000` and log in with the admin credentials.

## Configuration

Set admin credentials via environment variables or Rails credentials:

```bash
# Environment variables
export ADMIN_USERNAME=admin
export ADMIN_PASSWORD=your_secure_password
```

Or via `rails credentials:edit`:

```yaml
admin:
  username: admin
  password: your_secure_password
```

## Usage

### Manual Scraping

Click "Refresh All" in the admin interface, or run manually:

```bash
bin/rails runner "ScrapeAllSourcesJob.perform_now"
```

### Scheduled Jobs

Jobs are configured in `config/recurring.yml` and run via Solid Queue:

- **6:00 AM**: Scrape Reddit and Hacker News
- **7:00 AM**: Archive stale articles (older than 14 days)

Start the job runner:

```bash
bin/jobs
```

## Testing

```bash
# Run all tests
bundle exec rspec

# Run specific test types
bundle exec rspec spec/models
bundle exec rspec spec/features
bundle exec rspec spec/requests
```

## Code Style

This project uses [StandardRB](https://github.com/standardrb/standard) for Ruby linting:

```bash
bundle exec standardrb --fix
```

## Tech Stack

- **Ruby on Rails 8.1**
- **SQLite** - Database
- **Solid Queue** - Background jobs
- **Tailwind CSS** - Styling
- **Hotwire (Turbo + Stimulus)** - Frontend interactivity
- **RSpec** - Testing

## License

MIT
