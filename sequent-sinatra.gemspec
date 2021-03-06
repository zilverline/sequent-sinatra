require_relative 'lib/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'sequent-sinatra'
  s.version     = SequentSinatra::VERSION
  s.date        = '2014-04-03'
  s.summary     = "Event sourcing framework for Ruby - Sinatra adapter"
  s.description = "Sequent is an event sourcing framework for Ruby. This gem allows Sequent to work with Sinatra-backed applications."
  s.authors     = ["Lars Vonk", "Bob Forma", "Erik Rozendaal"]
  s.email       = ["lars.vonk@gmail.com", "bforma@zilverline.com", "erozendaal@zilverline.com"]
  s.files       = Dir["lib/**/*"]
  s.homepage    = 'https://github.com/zilverline/sequent-sinatra'
  s.license       = 'MIT'

  active_star_version = ENV['ACTIVE_STAR_VERSION'] || ['>= 5.0', '< 6.1']

  s.add_dependency              'activerecord', active_star_version

  s.add_dependency             'sequent', '~> 3.1'
  s.add_dependency             'sinatra', '~> 2.0'
  s.add_dependency             'rack_csrf', '~> 2.5'
  s.add_development_dependency 'rack-test', '~> 0.6'
  s.add_development_dependency 'rspec', '~> 3.2'
  s.add_development_dependency 'rspec-mocks', '~> 3.2'
  s.add_development_dependency 'rspec-collection_matchers', '~> 1.1'
  s.add_development_dependency 'rspec-html-matchers', '~> 0.7'
  s.add_development_dependency 'simplecov', '~> 0.9'
  s.add_development_dependency 'rake', '~> 10.4'
  s.add_development_dependency 'pry', '~> 0.10'
end
