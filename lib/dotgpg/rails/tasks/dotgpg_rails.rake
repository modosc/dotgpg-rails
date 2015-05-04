namespace :dotgpg do
  namespace :rails do
    desc "initialize dotgpg_rails"
    task :init do
      require 'fileutils'
      require 'dotgpg'

      # create config/dotgpg if it doesn't already exist
      dir = Rails.root.join 'config/dotgpg'
      unless File.directory?(dir)
        $stdout.puts "Creating #{dir}"
        FileUtils.mkdir_p dir
      end

      # setup dotgpg directory if necessary
      dotgpg_dir = Dotgpg::Dir.new(dir)
      unless dotgpg_dir.dotgpg?
        begin
          $stdout.puts "Initializing dotgpg directory #{dir}"
          Dir.chdir dir
          Dotgpg.interactive = true
          Dotgpg::Cli.start ['init']
        ensure
          # make sure thor didn't overwrite STDIN/STDOUT/STDERR
          $stderr = STDERR
          $stdin = STDIN
          $stdout = STDOUT

          # and change back to our RAILS_ROOT
          Dir.chdir Rails.root
        end
      end

      # get the list of rails environments that we require dotgpg-rails in and
      # initialize a dotgpg file for each one. this depends on having the gem
      # listed either in :default or in groups that match 1:1 environments we
      # can find in config/environments. it's somewhat error-prone, i suppose we
      # could also just create one for every environment?
      definition = Bundler.definition
      envs = Dir['./config/environments/*'].map{|f| File.basename f, '.*'}
      if definition.specs_for([:default])['dotgpg-rails'].empty?
        # we're not in the default group, check our gemfile for groups that match
        # our environment names
        envs.reject!{|e| definition.specs_for([e.to_sym])['dotgpg-rails'].empty? }
      end

      # for each of the environments that require dotgpg-rails initialize a blank
      # dotgpg file in config/dotgpg/environment.gpg
      envs.each do |env|
        path = File.join dir, "#{env}.gpg"
        next if File.exists? path
        $stdout.puts "Initializing empty dotgpg file #{path}"
        dotgpg_dir.encrypt path, "# placeholder dotgpg file for #{env} environment.\n"
      end
    end
  end
end
