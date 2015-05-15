require 'spec_helper'
require 'rack/test'

describe Sequent::Web::Sinatra::App do
  include Rack::Test::Methods

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
