require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end

desc "run all the tests, including style ones"
task :ta do
  exec "./bin/tests/all.sh"
end

desc "deploy to production"
task :dep do
  exec "./bin/ops/deploy"
end
