module Sequent
  module Web
    module Sinatra
      ##
      # Exposes various helper methods for creating form tags
      #
      module TagHelper
        ##
        # creates a <input type=checkbox>
        #
        # Parameters
        #   +field+ the name of the attribute within the current object.
        #   +options+ Hash with optional attributes.
        #               :default - the default checked value if the current object has none
        #               :class - the css class
        def raw_checkbox(field, options={})
          id = options[:id] || calculate_id(field)
          value = param_or_default(field, options.delete(:default), options) || id
          values = [value].compact
          field_value = param_or_default(field, false)
          checked = options.has_key?(:checked) ? options[:checked] : values.include?(field_value)
          checked = checked ? "checked" : nil
          single_tag :input, options.merge(
                             :type => "checkbox",
                             :id => id,
                             :name => calculate_name(field),
                             :value => value, checked: checked
                           )
        end

        ##
        # Creates a <input type=text>
        #
        # Parameters
        #   +field+ the name of the attribute within the current object.
        #   +options+ Hash with optional attributes.
        #               :default - the default value if the current object has none
        #               :class - the css class
        def raw_input(field, options={})
          raw_field(field, "text", options)
        end

        ##
        # Creates a <input type=password>
        #
        # Parameters
        #   +field+ the name of the attribute within the current object.
        #   +options+ Hash with optional attributes.
        #               :default - the default value if the current object has none
        #               :class - the css class
        def raw_password(field, options={})
          raw_field(field, "password", options)
        end

        ##
        # Creates a <textarea>
        #
        # Parameters
        #   +field+ the name of the attribute within the current object.
        #   +options+ Hash with optional attributes.
        #               :default - the default value if the current object has none
        #               :class - the css class
        #               :rows - the number of rows of the textarea, default 3
        def raw_textarea(field, options={})
          value = param_or_default(field, options.delete(:default), options)
          id = options[:id] || calculate_id(field)
          with_closing_tag :textarea, value, {rows: "3"}.merge(options.merge(
                                                                 :id => id,
                                                                 :name => calculate_name(field)
                                                               ))
        end

        ##
        # Creates a <input type=hidden>
        #
        # Parameters
        #   +field+ the name of the attribute within the current object.
        #   +options+ Hash with optional attributes.
        #               :default - the default value if the current object has none
        #               :class - the css class
        def raw_hidden(field, options={})
          raw_field(field, "hidden", options)
        end

        ##
        # Creates a <select> with <option>
        #
        # Parameters
        #   +field+ the name of the attribute within the current object.
        #   +values+ an array of pairs (arrays) of [value, text_to_display]
        #   +options+ Hash with optional attributes.
        #               :default - the default value if the current object has none
        #               :class - the css class
        def raw_select(field, values, options={})
          value = param_or_default(field, options.delete(:default), options)
          content = ""
          css_id = options[:id] || calculate_id(field)
          Array(values).each do |val|
            id, text = id_and_text_from_value(val)
            option_values = {value: id}
            option_values.merge!(selected: "selected") if (id == value)
            option_values.merge!(disabled: "disabled") if options[:disable].try(:include?, id)
            content << tag(:option, text, option_values)
          end
          tag :select, content, options.merge(id: css_id, name: calculate_name(field))
        end

        ##
        # creates a <input type=radio>
        #
        # By default it will check the radio button who's value is present in the backing object
        #
        # Parameters
        #   +field+ the name of the attribute within the current object.
        #   +options+ Hash with optional attributes.
        #               :default - the value of the radio option
        #               :checked - does this radio need to be checked
        #               :class - the css class
        def raw_radio(field, options = {})
          raise "radio buttons need a value" unless options[:value]
          id = options[:id] || calculate_id(field)
          value = options.delete(:value)
          checked = (value == @values[field.to_s] || options.include?(:checked))
          single_tag :input, options.merge(
                             :type => "radio",
                             :id => id,
                             :name => calculate_name(field),
                             :value => value,
                             checked: checked ? "checked" : nil
                           )
        end

        def full_path(field)
          tree_in_names(field, :postfix_for_id).join('_')
        end

        alias_method :calculate_id, :full_path

        def calculate_name(field)
          reverse_names = tree_in_names(field, :postfix)
          "#{reverse_names.first}#{reverse_names[1..-1].map { |n| n == '[]' ? n : "[#{n}]" }.join}"
        end

        def param_or_default(field, default, options = {})
          return options[:value] if options.has_key?(:value)
          @values.nil? ? default : @values.has_key?(field.to_s) ? @values[field.to_s] || default : default
        end

        def merge_and_append_class_attributes(to_append, options = {})
          to_append.merge(options) do |key, oldval, newval|
            key == :class ? "#{oldval} #{newval}" : newval
          end
        end

        def i18n_name(field)
          if @path
            "#{@path}.#{field}"
          else
            field.to_s
          end
        end

        def has_form_error?(name)
          @errors.try(:has_key?, name.to_sym)
        end

        private

        def id_and_text_from_value(val)
          if val.is_a? Array
            [val[0], val[1]]
          else
            [val, val]
          end
        end

        def tag(name, content, options={})
          "<#{name.to_s}" +
            (options.length > 0 ? " #{hash_to_html_attrs(options)}" : '') +
            (content.nil? ? '>' : ">#{content}</#{name}>")
        end

        def hash_to_html_attrs(options={})
          raise %Q{Keys used in options must be a Symbol. Don't use {"class" => "col-md-4"} but use {class: "col-md-4"}} if options.keys.find { |k| not k.kind_of? Symbol }
          html_attrs = ""
          options.keys.sort.each do |key|
            next if options[key].nil? # do not include empty attributes
            html_attrs << %Q(#{key}="#{h(options[key])}" )
          end
          html_attrs.chop
        end

        def raw_field(field, field_type, options)
          value = param_or_default(field, options.delete(:default), options)
          if options[:formatter]
            value = self.send(options[:formatter], value)
            options.delete(:formatter)
          end
          #TODO use calculate_id
          id = options[:id] || calculate_id(field)
          options.merge!(data_attributes(options.delete(:data)))
          single_tag :input, options.merge(
            :type => field_type,
            :id => id,
            :name => calculate_name(field),
            :value => value,
          )
        end

        def data_attributes(data, prefix = 'data')
          case data
          when Hash
            data.reduce({}) { |memo, (key, value)| memo.merge(data_attributes(value, "#{prefix}-#{key}")) }
          else
            { prefix.gsub('_', '-').to_sym => data }
          end
        end

        def tree_in_names(field, postfix_method_name)
          if respond_to? :path
            names = [field, send(postfix_method_name), path].compact
            parent = @parent
            while parent.is_a? Fieldset
              names << parent.postfix if parent.send(postfix_method_name)
              names << parent.path
              parent = parent.parent
            end
            names.reverse
          else
            [field]
          end
        end

        def single_tag(name, options={})
          "<#{name.to_s} #{hash_to_html_attrs(options)} />"
        end

        def with_closing_tag(name, value, options={})
          %Q{<#{name.to_s} #{hash_to_html_attrs(options)} >#{h value}</#{name.to_s}>}
        end

      end
    end
  end
end

