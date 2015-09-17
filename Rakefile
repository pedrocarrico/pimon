require 'rspec/core/rake_task'

desc 'run specs'
RSpec::Core::RakeTask.new

namespace :coverage do
  desc 'run rspec code coverage'
  task :spec do
    ENV['COVERAGE'] = 'on'
    FileUtils.rm_r 'coverage', force: true
    Rake::Task[:spec].execute
  end
end
