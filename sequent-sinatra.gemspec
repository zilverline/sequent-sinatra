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
  s.files       = ["lib/sequent-sinatra.rb"]
  s.homepage    = 'https://github.com/zilverline/sequent-sinatra'
  s.license       = 'MIT'

  s.add_dependency             'sequent'
  s.add_dependency             'sinatra', '~> 1.4.5'
  s.add_dependency             'rack_csrf', '~> 2.5.0'
  s.add_development_dependency 'rspec', '~> 3.2.0'
  s.add_development_dependency 'rspec-mocks', '~> 3.2.0'
  s.add_development_dependency 'rspec-collection_matchers', '~> 1.1.2'
  s.add_development_dependency 'rspec-html-matchers', '~> 0.7.0'
end
