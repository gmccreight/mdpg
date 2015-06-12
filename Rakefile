require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end

desc "run the tests and profile them"
task :prof do
  exec "ruby-prof --min_percent=1 ./bin/tests/spec.rb 2>/dev/null"
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

desc "backup production data to local machine"
task :backup do
  exec "./bin/ops/backup"
end

desc "copy production data - preserves backup of local data"
task :copy do
  exec "./bin/ops/copy_production_data"
end

desc "sync production data - does not preserve local data"
task :sync do
  exec "./bin/ops/sync_production_data"
end

desc "run the server"
task :server do
  exec "./bin/run_server"
end

desc "run ./bin/hack if you have one"
task :hack do
  exec "./bin/hack"
end

desc "run the tests ten times for timing"
task :time do
  exec "
    for i in {1..10};
      do { time ./bin/tests/spec.rb >/dev/null ; } 2>&1 | grep real
    done
  "
end
