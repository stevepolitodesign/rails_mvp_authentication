# 🔐 Rails MVP Authentication

An authentication generator for Rails 7. Based on the [step-by-step guide on how to build your own authentication system in Rails from scratch](https://github.com/stevepolitodesign/rails-authentication-from-scratch).

## 🚀 Installation

Add this line to your application's Gemfile:

```ruby
gem "rails_mvp_authentication"
```

And then execute:
```bash
bundle
```

Or install it yourself as:
```bash
gem install rails_mvp_authentication
```

Then run the installation command:
```bash
rails g rails_mvp_authentication:install
```

Once installed make follow these steps:

1. Run `bundle install` to install [bcrypt](https://rubygems.org/gems/bcrypt/)
2. Run `rails db:migrate` to add the `users` and `active_sessions` tables
3. Add a root path in `config/routes.rb`
4. Ensure you have flash messages in `app/views/layouts/application.html.erb`

```html+erb
<p class="notice"><%= notice %></p>
<p class="alert"><%= alert %></p>
```

## 🙏 Contributing

If you'd like to open a PR please make sure the following things pass:

```ruby
bin/rails test
bundle exec standardrb
```
## 📜 License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).