# Dotgpg::Rails [![Gem Version](https://badge.fury.io/rb/dotgpg-rails.svg)](https://badge.fury.io/rb/dotgpg-rails)

Shim to load environment variables directly into Rails from dotgpg encrypted files.


## Installation

### Rails

Add this line to the top of your application's Gemfile

```ruby
gem 'dotgpg-rails', :groups => [:development, :test]
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dotgpg-rails

You should also refer to the dotenv Notes on load order section.


## Usage

This code is almost 100% copied from dotgpg/rails, refer to the [dotenv readme](https://github.com/bkeepers/dotenv/blob/master/README.md), for more info since almost all of that document applies to this gem as well.

#### Note on load order

dotgpg is initialized in your Rails app during the `before_configuration` callback, which is fired when the `Application` constant is defined in `config/application.rb` with `class Application < Rails::Application`. If you need it to be initialized sooner, you can manually call `Dotgpg::Railtie.load`.

```ruby
# config/application.rb
Bundler.require(*Rails.groups)

Dotgpg::Railtie.load

HOSTNAME = ENV['HOSTNAME']
```

If you use gems that require environment variables to be set before they are loaded, then list `dotenv-rails` in the `Gemfile` before those other gems and require `dotgpg/rails-now`.

```ruby
gem 'dotgpg-rails', :require => 'dotgpg/rails-now'
gem 'gem-that-requires-env-variables'
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/dotgpg-rails/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
