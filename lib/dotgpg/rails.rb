require "dotgpg/rails/version"
require "dotgpg"
require "dotgpg/environment"

class Dotgpg

  module Rails
    class << self
      attr_accessor :instrumenter
    end

    module_function

    def load(*filenames)
      with(*filenames) do |f|
        ignoring_nonexistent_files do
          env = Environment.new(f)
          instrument("dotgpg.load", :env => env) { env.apply }
        end
      end
    end

    # same as `load`, but raises Errno::ENOENT if any files don't exist
    def load!(*filenames)
      with(*filenames) do |f|
        env = Environment.new(f)
        instrument("dotgpg.load", :env => env) { env.apply }
      end
    end

    # same as `load`, but will override existing values in `ENV`
    def overload(*filenames)
      with(*filenames) do |f|
        ignoring_nonexistent_files do
          env = Environment.new(f)
          instrument("dotgpg.overload", :env => env) { env.apply! }
        end
      end
    end


    # Internal: Helper to expand list of filenames.
    #
    # Returns a hash of all the loaded environment variables.
    def with(*filenames, &block)
      filenames << ".env" if filenames.empty?

      filenames.reduce({}) do |hash, filename|
        hash.merge! block.call(File.expand_path(filename)) || {}
      end
    end

    def instrument(name, payload = {}, &block)
      if instrumenter
        instrumenter.instrument(name, payload, &block)
      else
        block.call
      end
    end

    def ignoring_nonexistent_files
      yield
    rescue Errno::ENOENT
    end

  end

  class Railtie < ::Rails::Railtie
    config.before_configuration { load }

    rake_tasks do
      Rake.load_rakefile File.expand_path('../rails/tasks/dotgpg_rails.rake', __FILE__).to_s
    end

    # Public: Load dotgpg
    #
    # This will get called during the `before_configuration` callback, but you
    # can manually call `Dotgpg::Railtie.load` if you needed it sooner.
    def load
      file = root.join 'config/dotgpg', "#{::Rails.env}.gpg"
      if File.exists? file
        Dotgpg::Rails.load file
      else
        # if our file doesn't exist don't bother trying to load. if we're not
        # being called from our rake task print an error message to STDERR
        unless File.basename($PROGRAM_NAME) == 'rake' && ARGV[0] == 'dotgpg:rails:init'
          $stderr.puts "Couldn't initialize dotgpg file #{file}: " <<
                       "(do you need to run 'rake dotgpg:rails:init' ?)"
        end
        # gracefully fail and return an empty string - maybe we want to make this
        # fatal in the future?
        ''
      end
    end

    # Internal: `Rails.root` is nil in Rails 4.1 before the application is
    # initialized, so this falls back to the `RAILS_ROOT` environment variable,
    # or the current working directory.
    def root
      ::Rails.root || Pathname.new(ENV["RAILS_ROOT"] || Dir.pwd)
    end

    # Rails uses `#method_missing` to delegate all class methods to the
    # instance, which means `Kernel#load` gets called here. We don't want that.
    def self.load
      instance.load
    end

  end
end

Dotgpg::Rails.instrumenter = ActiveSupport::Notifications

# Watch all loaded env files with Spring
begin
  require "spring/watcher"
  ActiveSupport::Notifications.subscribe(/^dotgpg/) do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    Spring.watch event.payload[:env].filename if Rails.application
  end
rescue LoadError
  # Spring is not available
end


