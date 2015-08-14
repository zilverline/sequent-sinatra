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
      f = Sequent::Web::Sinatra::Fieldset.new(app, :foo, { foo: { bar: [] } }, {})
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
      f = Sequent::Web::Sinatra::Fieldset.new(app, 'foo', { 'foo' => { 'bar' => [{ 'baz' => 'one' }, { 'baz' => 'two' }] } }, {})
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

  describe "checkboxes" do
    it "should create a checkbox" do
      f = Sequent::Web::Sinatra::Fieldset.new(app, :foo, {}, {})
      tag = f.raw_checkbox("checkit")
      expect(tag).to eq %Q{<input id="foo_checkit" name="foo[checkit]" type="checkbox" value="foo_checkit" />}
    end

    it "should create a checkbox with arbitrary data" do
      f = Sequent::Web::Sinatra::Fieldset.new(app, :foo, {}, {})
      tag = f.raw_checkbox("checkit", :"data-foo" => "bar")
      expect(tag).to eq %Q{<input data-foo="bar" id="foo_checkit" name="foo[checkit]" type="checkbox" value="foo_checkit" />}
    end

    it "should take over the given value if any" do
      f = Sequent::Web::Sinatra::Fieldset.new(app, :foo, {}, {})
      tag = f.raw_checkbox("checkit", value: "42")
      expect(tag).to eq %Q{<input id="foo_checkit" name="foo[checkit]" type="checkbox" value="42" />}
    end

    it "should check the checkbox if the value is in the params" do
      f = Sequent::Web::Sinatra::Fieldset.new(app, "foo", {"foo" => {"checkit" => "42"}}, {})
      tag = f.raw_checkbox("checkit", value: "42")
      expect(tag).to eq %Q{<input checked="checked" id="foo_checkit" name="foo[checkit]" type="checkbox" value="42" />}
    end
  end
end
