require 'rake/clean'
require 'rake/testtask'

CLEAN.include "**/*.rbc"
CLEAN.include "**/.DS_Store"

Rake::TestTask.new do |t|
  t.options = "-v"
  t.test_files = FileList["test/*test*.rb"]
end
