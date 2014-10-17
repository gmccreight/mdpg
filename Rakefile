require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end

desc "run the tests and profile them"
task :prof do
  exec "ruby-prof ./spec.rb 2>/dev/null | head -n 50"
end

desc "run all the tests, including style and coverage ones"
task :ta do
  exec "./bin/tests/all.sh"
end

desc "run coverage and send to coveralls"
task :cov do
  exec "COVERALLS_RUN_LOCALLY=1 rake"
end

desc "deploy to production"
task :dep do
  exec "./bin/ops/deploy"
end

desc "copy production data"
task :copy do
  exec "./bin/ops/copy_production_data"
end

desc "run the mutant tests"
task :mut do
  exec "./bin/mutant"
end

desc "run the server"
task :server do
  exec "./bin/run_server"
end

desc "run the tests ten times for timing"
task :time do
  exec "
    for i in {1..10};
      do { time ./bin/tests/spec.rb >/dev/null ; } 2>&1 | grep real
    done
  "
end
