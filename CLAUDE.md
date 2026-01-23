# Project Guidelines for Claude

## Code Style

- **Always run `bundle exec standardrb --fix`** after making Ruby code changes
- Follow StandardRB conventions (no explicit rubocop config needed)

## Testing Requirements

- **Write specs for all new code** - models, controllers, jobs, concerns, and features
- Use RSpec with FactoryBot for testing
- Use VCR cassettes for any external HTTP requests
- Run `bundle exec rspec` to verify all tests pass before finishing

### Test Types

- **Model specs** (`spec/models/`) - test validations, scopes, and instance methods
- **Request specs** (`spec/requests/`) - test controller actions and HTTP responses
- **Feature specs** (`spec/features/`) - test user-facing functionality with Capybara
- **Job specs** (`spec/jobs/`) - test background job behavior
- **Concern specs** (`spec/models/concerns/`) - test shared model behavior

## Architecture Conventions

- Use **concerns** instead of service objects for shared model behavior
- Use **Stimulus controllers** for JavaScript (not vanilla JS)
- Use **Tailwind CSS** for styling (simple, no gradients)
- Use **Solid Queue** for background jobs with `config/recurring.yml` for scheduled jobs
- Use **Turbo** for SPA-like interactions

## Admin Interface

- All admin routes are under the `/admin` namespace
- Admin controllers inherit from `Admin::BaseController`
- HTTP Basic Auth protects all admin routes (credentials: admin/password in test)

## Database

- SQLite for development and production
- Use the `discard` gem for soft deletes (not hard deletes)
- Articles older than 14 days are automatically discarded

## Commands

```bash
# Run tests
bundle exec rspec

# Run linter
bundle exec standardrb --fix

# Start development server
bin/dev

# Run migrations
bin/rails db:migrate
```
