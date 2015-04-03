require 'spec_helper'

describe Sequent::Web::Sinatra::FormHelpers do
  let(:app) { MockAppForFormHelper.new.helpers }

  it "should correctly create a form" do
    form = app.html_form_for(Country.new, "/foo", :post) { "" }
    expect(form).to eq %Q{<form action="/foo" method="POST" role="form"><p>CSRF</p></form>}
  end

  it "should fail if the object of the form does not respond to to_h" do
    expect { app.html_form_for("hallo", "/foo", :post) { "" } }.to raise_exception(/Given object of class String does not respond to :as_params. Are you including Sequent::Core::Helpers::ParamSupport?/)
  end

  it "should be able to handle nil as object parameter." do
    form = app.html_form_for(nil, "/foo", :post) { "" }
    expect(form).to eq %Q{<form action="/foo" method="POST" role="form"><p>CSRF</p></form>}
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
    expect(Hash.from_xml(output)).to eq Hash.from_xml(%Q{<form action="/foo" method="POST" role="form"><p>CSRF</p><input id="country_name" name="country[name]" type="text" /></form>})
  end

  context "without a backing object" do
    context "it should be able to create a form" do
      it "that is empty" do
        form = app.html_form("/foo", :post) { "" }
        expect(form).to eq %Q{<form action="/foo" method="POST" role="form"><p>CSRF</p></form>}
      end

      it "that has a single field without a fieldset" do
        erb_string = <<-EOF
             <% html_form('/foo', :post) do |form| %>
                 <%= form.raw_input(:name) %>
             <% end %>
        EOF

        output = app.get_erb(erb_string)
        expect(Hash.from_xml(output)).to eq Hash.from_xml(%Q{<form action="/foo" method="POST" role="form" ><p>CSRF</p><input id="name" name="name" type="text" /></form>})
      end

      it "should calculate the i18n name" do
        form = Sequent::Web::Sinatra::Form.new(app, nil, '/foo')
        expect(form.i18n_name(:bar)).to eq "bar"
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
end
