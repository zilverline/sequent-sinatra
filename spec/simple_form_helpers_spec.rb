require 'spec_helper'
require "rspec-html-matchers"

describe Sequent::Web::Sinatra::FormHelpers, no_database: true do

  let(:app) { MockAppForFormHelper.new.helpers }

  it "should correctly create a form" do
    form = app.html_form_for(Country.new, "/foo", :post) { "" }
    form.should == %Q{<form action="/foo" method="POST" role="form"><p>CSRF</p></form>}
  end

  it "should fail if the object of the form does not respond to to_h" do
    expect { app.html_form_for("hallo", "/foo", :post) { "" } }.to raise_exception(/Given object of class String does not respond to :as_params. Are you including Sequent::Core::Helpers::ParamSupport?/)
  end

  it "should be able to handle nil as object parameter." do
    form = app.html_form_for(nil, "/foo", :post) { "" }
    form.should == %Q{<form action="/foo" method="POST" role="form"><p>CSRF</p></form>}
  end

  it "should create a form with a fieldset" do
    erb_string = <<-EOF
      <% html_form_for(Address.new, '/foo', :post) do |form| %>
        <% form.fieldset(:country) do |c| %>
          <%= c.raw_input(:name) %>
        <% end %>
      <% end %>
    EOF

    output = app.get_erb(erb_string)
    Hash.from_xml(output).should == Hash.from_xml(%Q{<form action="/foo" method="POST" role="form"><p>CSRF</p><input id="country_name" name="country[name]" type="text" /></form>})
  end

  context "without a backing object" do

    context "it should be able to create a form" do

      it "that is empty" do
        form = app.html_form("/foo", :post) { "" }
        form.should == %Q{<form action="/foo" method="POST" role="form"><p>CSRF</p></form>}
      end

      it "that has a single field without a fieldset" do
        erb_string = <<-EOF
             <% html_form('/foo', :post) do |form| %>
                 <%= form.raw_input(:name) %>
             <% end %>
        EOF

        output = app.get_erb(erb_string)
        Hash.from_xml(output).should == Hash.from_xml(%Q{<form action="/foo" method="POST" role="form" ><p>CSRF</p><input id="name" name="name" type="text" /></form>})
      end

      it "should calculate the i18n name" do
        form = Sequent::Web::Sinatra::Form.new(app, nil, '/foo')
        form.i18n_name(:bar).should == "bar"
      end

    end

    it "should not be possible to create fieldset" do
      erb_string = <<-EOF
                   <% html_form('/foo', :post) do |form| %>
                       <% form.fieldset(:country) do |c| %>
                       <% end %>
                   <% end %>
      EOF

      expect { app.get_erb(erb_string) }.to raise_exception(/can not create a fieldset without a form backing object/)
    end

  end

  describe Sequent::Web::Sinatra::Fieldset do

    it "should correctly create a field within a fieldset" do
      f = Sequent::Web::Sinatra::Fieldset.new(app, :foo, {}, {})
      f.calculate_name(:bar).should == "foo[bar]"
      f.calculate_name("bar").should == "foo[bar]"
      f.calculate_id("bar").should == "foo_bar"
    end

    it "should correctly create a field within a nested fieldset" do
      f = Sequent::Web::Sinatra::Fieldset.new(app, :foo, {}, {})

      f.nested("bar") do |nested|
        nested.calculate_name("foobar").should == "foo[bar][foobar]"
        nested.nested(:super_nested) do |super_nested|
          super_nested.calculate_name("foo").should == "foo[bar][super_nested][foo]"
          super_nested.calculate_id("foo").should == "foo_bar_super_nested_foo"
        end
      end
    end

    describe "checkboxes" do
      it "should create a checkbox" do
        f = Sequent::Web::Sinatra::Fieldset.new(app, :foo, {}, {})
        tag = f.raw_checkbox("checkit")
        tag.should == %Q{<input id="foo_checkit" name="foo[checkit]" type="checkbox" value="foo_checkit" />}
      end

      it "should create a checkbox with arbitrary data" do
        f = Sequent::Web::Sinatra::Fieldset.new(app, :foo, {}, {})
        tag = f.raw_checkbox("checkit", :"data-foo" => "bar")
        tag.should == %Q{<input data-foo="bar" id="foo_checkit" name="foo[checkit]" type="checkbox" value="foo_checkit" />}
      end

      it "should take over the given value if any" do
        f = Sequent::Web::Sinatra::Fieldset.new(app, :foo, {}, {})
        tag = f.raw_checkbox("checkit", value: "42")
        tag.should == %Q{<input id="foo_checkit" name="foo[checkit]" type="checkbox" value="42" />}
      end

      it "should check the checkbox if the value is in the params" do
        f = Sequent::Web::Sinatra::Fieldset.new(app, "foo", {"foo" => {"checkit" => "42"}}, {})
        tag = f.raw_checkbox("checkit", value: "42")
        tag.should == %Q{<input checked="checked" id="foo_checkit" name="foo[checkit]" type="checkbox" value="42" />}
      end
    end

  end

  class MockAppForFormHelper < Sinatra::Base
    include Sequent::Web::Sinatra::FormHelpers,
            Sequent::Web::Sinatra::TagHelper

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
end
