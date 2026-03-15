# Power Dev

Rails app for curated tech/news workflows.

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
