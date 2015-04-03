require 'bundler/setup'
Bundler.setup

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require_relative '../lib/sequent-sinatra'
require 'rspec/collection_matchers'
require 'rspec-html-matchers'
require 'support/mocks'
