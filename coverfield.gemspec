$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'coverfield/version'

Gem::Specification.new do |gem|
  gem.name        = 'coverfield'
  gem.version     = Coverfield::VERSION
  gem.platform    = Gem::Platform::RUBY
  gem.authors     = ['Benjamin Klein']
  gem.email       = ['benny at itws de']
  gem.homepage    = 'http://github.com/phortx/coverfield'
  gem.description = 'Smarter Ruby/RSpec coverage reports: Tells you which classes, modules and methods don\'t have any specs'
  gem.summary     = 'Smarter Ruby/RSpec coverage reports'
  gem.license     = 'GPL-3.0'
  gem.required_ruby_version = '>= 2.3.0'


  gem.add_dependency 'rubocop',  '~> 0.40'
  gem.add_dependency 'colorize', '~> 0.7'

  gem.add_development_dependency 'bundler', '~> 1.12'
  gem.add_development_dependency 'rspec', '~> 3.4'


  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.require_paths = ['lib']
end
