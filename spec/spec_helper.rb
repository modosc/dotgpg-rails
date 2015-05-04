$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'dotgpg-rails'

# adapted/copied from dotgpg
# Make a totally isolated directory for running tests.
# This is necessary because GPG maintains state in GNUPGHOME,
# and we don't want running the tests to spoil developer's real key stores.
$fixtures = Pathname.new(Dir::mktmpdir).realpath
FileUtils.cp_r "spec/fixtures/", $fixtures
$fixtures += "fixtures"
FileUtils.mkdir_p $fixtures + "lib/dotgpg/rails/tasks"
FileUtils.cp_r "lib/dotgpg/rails/tasks", $fixtures + "lib/dotgpg/rails/"
$keys = $fixtures + "keys"
$dotgpg = $fixtures + "config/dotgpg"
ENV["GNUPGHOME"] = $fixtures.join("gnupghome").to_s
at_exit{ FileUtils.rm_rf $fixtures }

