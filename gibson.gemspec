require './lib/gibson/version'

Gem::Specification.new do |s|
  s.name = %q{gibson}
  s.version = Gibson::VERSION
  s.license = "BSD"

  s.authors = ["Simone Margaritelli"]
  s.description = %q{High performance Gibson client for Ruby}
  s.email = %q{evilsocket@gmail.com}
  s.files = Dir.glob("lib/**/*") + [
     "LICENSE",
     "README.md",
     "Rakefile",
     "Gemfile",
     "gibson.gemspec"
  ]
  s.homepage = %q{http://gibson-db.in/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.summary = %q{High performance Gibson client for Ruby}

  s.add_development_dependency("rake")
end

