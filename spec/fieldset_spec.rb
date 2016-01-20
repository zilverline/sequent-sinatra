require 'spec_helper'

describe Sequent::Web::Sinatra::Fieldset do
  let(:app) { MockAppForFormHelper.new.helpers }

  it "should correctly create a field within a fieldset" do
    f = Sequent::Web::Sinatra::Fieldset.new(app, :foo, {}, {})
    expect(f.calculate_name(:bar)).to eq "foo[bar]"
    expect(f.calculate_name("bar")).to eq "foo[bar]"
    expect(f.calculate_id("bar")).to eq "foo_bar"
  end

  it "should correctly create a field within a nested fieldset" do
    f = Sequent::Web::Sinatra::Fieldset.new(app, :foo, {}, {})

    f.nested("bar") do |nested|
      expect(nested.calculate_name("foobar")).to eq "foo[bar][foobar]"
      nested.nested(:super_nested) do |super_nested|
        expect(super_nested.calculate_name("foo")).to eq "foo[bar][super_nested][foo]"
        expect(super_nested.calculate_id("foo")).to eq "foo_bar_super_nested_foo"
      end
    end
  end

  describe 'arrays' do
    it 'handles arrays' do
      f = Sequent::Web::Sinatra::Fieldset.new(app, :foo, {foo: {bar: []}}, {})
      f.nested_array(:bar) do |nested|
        expect(nested.calculate_name('foobar')).to eq 'foo[bar][][foobar]'
        expect(nested.calculate_id('foobar')).to eq 'foo_bar_0_foobar'
        tag = nested.raw_input(:foobar)
        expect(tag).to eq %Q{<input id="foo_bar_0_foobar" name="foo[bar][][foobar]" type="text" />}
      end
    end


    it 'handles deeply nested arrays' do
      f = Sequent::Web::Sinatra::Fieldset.new(app, :foo, {}, {})
      f.nested_array(:bar) do |nested1|
        nested1.nested(:baz) do |nested2|
          nested2.nested_array(:boop) do |nested3|
            expect(nested3.calculate_name('beboop')).to eq 'foo[bar][][baz][boop][][beboop]'
          end
        end
      end
    end

    it 'extracts values' do
      f = Sequent::Web::Sinatra::Fieldset.new(app, 'foo', {'foo' => {'bar' => [{'baz' => 'one'}, {'baz' => 'two'}]}}, {})
      values = []
      f.nested_array('bar') do |nested1|
        values << nested1.param_or_default('baz', '')
      end
      expect(values).to eq ['one', 'two']
    end

    it "calculates the name with empty params" do
      f = Sequent::Web::Sinatra::Fieldset.new(app, :foo, {}, {})
      f.nested_array(:bar) do |nested|
        expect(nested.calculate_name('foobar')).to eq 'foo[bar][][foobar]'
      end
    end
  end

  describe ".raw_checkbox" do
    let(:fieldset) { Sequent::Web::Sinatra::Fieldset.new(app, :foo, {}, {}) }
    it "should create a checkbox" do
      tag = fieldset.raw_checkbox("checkit")
      expect(tag).to eq %Q{<input id="foo_checkit" name="foo[checkit]" type="checkbox" value="foo_checkit" />}
    end

    it "can override the id" do
      tag = fieldset.raw_checkbox("checkit", {id: "bar_foo"})
      expect(tag).to eq %Q{<input id="bar_foo" name="foo[checkit]" type="checkbox" value="bar_foo" />}
    end

    it "should create a checkbox with arbitrary data" do
      tag = fieldset.raw_checkbox("checkit", :"data-foo" => "bar")
      expect(tag).to eq %Q{<input data-foo="bar" id="foo_checkit" name="foo[checkit]" type="checkbox" value="foo_checkit" />}
    end

    it "should take over the given value if any" do
      tag = fieldset.raw_checkbox("checkit", default: "42")
      expect(tag).to eq %Q{<input id="foo_checkit" name="foo[checkit]" type="checkbox" value="42" />}
    end

    context "with value" do
      let(:fieldset) { Sequent::Web::Sinatra::Fieldset.new(app, "foo", {"foo" => {"checkit" => "42"}}, {}) }
      it "should check the checkbox if the value is in the params" do
        tag = fieldset.raw_checkbox("checkit", default: "42")
        expect(tag).to eq %Q{<input checked="checked" id="foo_checkit" name="foo[checkit]" type="checkbox" value="42" />}
      end
    end
  end

  describe ".raw_input" do
    let(:fieldset) { Sequent::Web::Sinatra::Fieldset.new(app, :foo, {}, {}) }
    it "should create a checkbox" do
      tag = fieldset.raw_input("field")
      expect(tag).to eq %Q{<input id="foo_field" name="foo[field]" type="text" />}
    end

    it "can override the id" do
      tag = fieldset.raw_input("field", {id: "bar_field"})
      expect(tag).to eq %Q{<input id="bar_field" name="foo[field]" type="text" />}
    end

    it "uses the given value if any" do
      tag = fieldset.raw_input("field", {default: "42"})
      expect(tag).to eq %Q{<input id="foo_field" name="foo[field]" type="text" value="42" />}
    end

    context "with value" do
      let(:fieldset) { Sequent::Web::Sinatra::Fieldset.new(app, "foo", {"foo" => {"field" => "42"}}, {}) }
      it "prefill with actual value" do
        tag = fieldset.raw_input("field")
        expect(tag).to eq %Q{<input id="foo_field" name="foo[field]" type="text" value="42" />}
      end
    end
  end

  describe ".raw_password" do
    let(:fieldset) { Sequent::Web::Sinatra::Fieldset.new(app, :foo, {}, {}) }
    it "should create a checkbox" do
      tag = fieldset.raw_password("pwd_field")
      expect(tag).to eq %Q{<input id="foo_pwd_field" name="foo[pwd_field]" type="password" />}
    end

    it "can override the id" do
      tag = fieldset.raw_password("pwd_field", {id: "bar_pwd_field"})
      expect(tag).to eq %Q{<input id="bar_pwd_field" name="foo[pwd_field]" type="password" />}
    end

    it "uses the given value if any" do
      tag = fieldset.raw_password("pwd_field", {default: "42"})
      expect(tag).to eq %Q{<input id="foo_pwd_field" name="foo[pwd_field]" type="password" value="42" />}
    end

    context "with value" do
      let(:fieldset) { Sequent::Web::Sinatra::Fieldset.new(app, "foo", {"foo" => {"pwd_field" => "42"}}, {}) }
      it "prefill with actual value" do
        tag = fieldset.raw_password("pwd_field")
        expect(tag).to eq %Q{<input id="foo_pwd_field" name="foo[pwd_field]" type="password" value="42" />}
      end
    end
  end

  describe ".raw_textarea" do
    let(:fieldset) { Sequent::Web::Sinatra::Fieldset.new(app, :foo, {}, {}) }
    it "should create a checkbox" do
      tag = fieldset.raw_textarea("field")
      expect(tag).to eq %Q{<textarea id="foo_field" name="foo[field]" rows="3" ></textarea>}
    end

    it "can override the id" do
      tag = fieldset.raw_textarea("field", {id: "bar_field"})
      expect(tag).to eq %Q{<textarea id="bar_field" name="foo[field]" rows="3" ></textarea>}
    end

    it "uses the given value if any" do
      tag = fieldset.raw_textarea("field", {default: "42"})
      expect(tag).to eq %Q{<textarea id="foo_field" name="foo[field]" rows="3" >42</textarea>}
    end

    context "with value" do
      let(:fieldset) { Sequent::Web::Sinatra::Fieldset.new(app, "foo", {"foo" => {"field" => "42"}}, {}) }
      it "prefill with actual value" do
        tag = fieldset.raw_textarea("field")
        expect(tag).to eq %Q{<textarea id="foo_field" name="foo[field]" rows="3" >42</textarea>}
      end
    end
  end

  describe ".raw_hidden" do
    let(:fieldset) { Sequent::Web::Sinatra::Fieldset.new(app, :foo, {}, {}) }
    it "should create a checkbox" do
      tag = fieldset.raw_hidden("field")
      expect(tag).to eq %Q{<input id="foo_field" name="foo[field]" type="hidden" />}
    end

    it "can override the id" do
      tag = fieldset.raw_hidden("field", {id: "bar_field"})
      expect(tag).to eq %Q{<input id="bar_field" name="foo[field]" type="hidden" />}
    end

    it "uses the given value if any" do
      tag = fieldset.raw_hidden("field", {default: "42"})
      expect(tag).to eq %Q{<input id="foo_field" name="foo[field]" type="hidden" value="42" />}
    end

    context "with value" do
      let(:fieldset) { Sequent::Web::Sinatra::Fieldset.new(app, "foo", {"foo" => {"field" => "42"}}, {}) }
      it "prefill with actual value" do
        tag = fieldset.raw_hidden("field")
        expect(tag).to eq %Q{<input id="foo_field" name="foo[field]" type="hidden" value="42" />}
      end
    end
  end

  describe ".raw_select" do
    let(:fieldset) { Sequent::Web::Sinatra::Fieldset.new(app, :foo, {}, {}) }
    it "should create a checkbox" do
      tag = fieldset.raw_select("field", [["id", "value"]])
      expect(tag).to eq %Q{<select id="foo_field" name="foo[field]"><option value="id">value</option></select>}
    end

    it "can override the id" do
      tag = fieldset.raw_select("field", [["id", "value"]], {id: "bar_field"})
      expect(tag).to eq %Q{<select id="bar_field" name="foo[field]"><option value="id">value</option></select>}
    end

    context "with value" do
      let(:fieldset) { Sequent::Web::Sinatra::Fieldset.new(app, "foo", {"foo" => {"field" => "42"}}, {}) }
      it "prefill with actual value" do
        tag = fieldset.raw_select("field", [["42", "value"]])
        expect(tag).to eq %Q{<select id="foo_field" name="foo[field]"><option selected="selected" value="42">value</option></select>}
      end
    end
  end

  describe ".raw_radio" do
    let(:fieldset) { Sequent::Web::Sinatra::Fieldset.new(app, :foo, {}, {}) }

    it "fails without been given a value" do
      expect{fieldset.raw_radio("field")}.to raise_exception /radio buttons need a value/
    end

    it "can create a radio button" do
      tag = fieldset.raw_radio("field", value: "Option 1")
      expect(tag).to eq %Q{<input id="foo_field" name="foo[field]" type="radio" value="Option 1" />}
    end

    it "can manually check a radio button" do
      tag = fieldset.raw_radio("field", value: "Option 1", checked: "checked")
      expect(tag).to eq %Q{<input checked="checked" id="foo_field" name="foo[field]" type="radio" value="Option 1" />}
    end

    context "with value" do
      let(:fieldset) { Sequent::Web::Sinatra::Fieldset.new(app, "foo", {"foo" => {"field" => "Option 2"}}, {}) }
      it "uses the given value" do
        tag = fieldset.raw_radio("field", value: "Option 1")
        expect(tag).to eq %Q{<input id="foo_field" name="foo[field]" type="radio" value="Option 1" />}
      end
    end

  end

  describe ".raw_email" do
    let(:fieldset) { Sequent::Web::Sinatra::Fieldset.new(app, :foo, {}, {}) }
    it "should create a checkbox" do
      tag = fieldset.raw_email("field")
      expect(tag).to eq %Q{<input id="foo_field" name="foo[field]" type="email" />}
    end

    it "can override the id" do
      tag = fieldset.raw_email("field", {id: "bar_field"})
      expect(tag).to eq %Q{<input id="bar_field" name="foo[field]" type="email" />}
    end

    it "uses the given value if any" do
      tag = fieldset.raw_email("field", {default: "ben@ajax.nl"})
      expect(tag).to eq %Q{<input id="foo_field" name="foo[field]" type="email" value="ben@ajax.nl" />}
    end

    context "with value" do
      let(:fieldset) { Sequent::Web::Sinatra::Fieldset.new(app, "foo", {"foo" => {"field" => "ben@ajax.nl"}}, {}) }
      it "prefill with actual value" do
        tag = fieldset.raw_email("field")
        expect(tag).to eq %Q{<input id="foo_field" name="foo[field]" type="email" value="ben@ajax.nl" />}
      end
    end
  end

end
