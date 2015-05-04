# If you use gems that require environment variables to be set before they are
# loaded, then list `dotgpg-rails` in the `Gemfile` before those other gems and
# require `dotgpg/rails-now`.
#
#     gem "dotgpg-rails", :require => "dotgpg/rails-now"
#     gem "gem-that-requires-env-variables"
#

require "dotgpg/rails"
Dotgpg::Railtie.load
