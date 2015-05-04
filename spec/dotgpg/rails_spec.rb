require "rails"
require 'spec_helper'
require 'rake'
ENV["RAILS_ENV"] = "test"


describe Dotgpg::Railtie do
  # Fake watcher for Spring
  class SpecWatcher
    attr_reader :items

    def initialize
      @items = []
    end

    def add(*items)
      @items |= items
    end
  end

  before do
    allow(Rails).to receive(:root)
      .and_return Pathname.new($fixtures)
    Rails.application = double(:application)
    Spring.watcher = SpecWatcher.new
  end

  after do
    # Reset
    Spring.watcher = nil
    Rails.application = nil
  end

  context "before_configuration" do
    it "calls #load" do
      expect(Dotgpg::Railtie.instance).to receive(:load)
      ActiveSupport.run_load_hooks(:before_configuration)
    end
  end

  context "load" do
    before { Dotgpg::Railtie.load }

    it "watches config/dotgpg/test.gpg with Spring" do
      expect(Spring.watcher.items).to include(($dotgpg + "test.gpg").to_s)
    end

    it "loads values into ENV" do
      expect(ENV['FOO']).to eq('bar')
      expect(ENV['BAZ']).to eq('bat')
    end

    context "when Rails.root is nil" do
      before do
        allow(Rails).to receive(:root).and_return(nil)
      end

      it "falls back to RAILS_ROOT" do
        ENV["RAILS_ROOT"] = "/tmp"
        expect(Dotgpg::Railtie.root.to_s).to eql("/tmp")
      end
    end
  end

  # not working yet
  xit "rake tasks" do
    # copied from https://robots.thoughtbot.com/test-rake-tasks-like-a-boss
    let(:rake)      { Rake::Application.new }
    let(:task_name) { 'dotgpg:rails:init' }
    let(:task_path) { Rails.root.join 'lib/dotgpg/rails/tasks/dotgpg_rails.rake' }
    subject         { rake[task_name] }

    def loaded_files_excluding_current_rake_file
      $".reject {|file| file == Rails.root.join("#{task_path}.rake").to_s }
    end

    before do
      Rake.application = rake
      Rake.application.rake_require(task_path, [Rails.root.to_s], loaded_files_excluding_current_rake_file)

      Rake::Task.define_task(:environment)
    end

    it "works" do
      subject.invoke
    end

  end
end
