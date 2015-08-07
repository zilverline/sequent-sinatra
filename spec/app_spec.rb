require 'spec_helper'
require 'rack/test'
require 'app_for_test'

describe Sequent::Web::Sinatra::App do
  include Rack::Test::Methods

  def app
    AppForTest
  end

  it "initializes sequent correctly" do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('OK')
    expect(Sequent.command_service).to_not be_nil
  end

end
