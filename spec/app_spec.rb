require 'spec_helper'
require 'rack/test'

describe Sequent::Web::Sinatra::App do
  include Rack::Test::Methods

  describe "sequent_config_dir" do
    class MockOrderSequentApp < Sinatra::Base
      set :root, "#{root}/support"

      register Sequent::Web::Sinatra::App

      get '/' do
        @command_service.class.to_s
      end
    end

    def app
      MockOrderSequentApp.new
    end

    it "should be optional" do
      response = get '/'
      expect(response.body).to eq('Sequent::Core::CommandService')
    end

  end

  describe "initializing" do
    class MockSequentApp < Sinatra::Base
      set :sequent_config_dir, "#{root}/support"

      register Sequent::Web::Sinatra::App

      get '/' do
        @command_service.class.to_s
      end
    end

    def app
      MockSequentApp.new
    end

    it "should set @command_service on every request" do
      response = get '/'
      expect(response.body).to eq('Sequent::Core::CommandService')
    end
  end
end
