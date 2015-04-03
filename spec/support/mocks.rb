class MockAppForFormHelper < Sinatra::Base
  include Sequent::Web::Sinatra::FormHelpers
  include Sequent::Web::Sinatra::TagHelper

  def initialize
    super
    @_out_buf = ""
  end

  def csrf_tag
    "<p>CSRF</p>"
  end

  def h(text)
    text
  end

  def params
    {}
  end

  def get_erb(string)
    erb string
  end
end

class Country
  def as_params
  end
end

class Address
  def as_params
  end
end
