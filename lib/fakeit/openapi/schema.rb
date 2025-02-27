require 'fakeit/openapi/example/array_example'
require 'fakeit/openapi/example/boolean_example'
require 'fakeit/openapi/example/integer_example'
require 'fakeit/openapi/example/number_example'
require 'fakeit/openapi/example/object_example'
require 'fakeit/openapi/example/string_example'

module Fakeit
  module Openapi
    module Schema
      include Fakeit::Openapi::Example

      def to_example(**example_options)
        return example if example_options[:use_example] && example

        return one_of_example(example_options) if one_of
        return all_of_example(example_options) if all_of
        return any_of_example(example_options) if any_of

        type_based_example(example_options)
      end

      private

      def one_of_example(example_options)
        example_options[:static] ? one_of.first.to_example(example_options) : one_of.sample.to_example(example_options)
      end

      def all_of_example(example_options)
        all_of
          .select { |option| option.type == 'object' }
          .map { |option| option.to_example(example_options) }
          .reduce(&:merge)
      end

      def any_of_example(example_options)
        any_of
          .select { |option| option.type == 'object' }
          .then { |options| example_options[:static] ? options : options.sample(Faker::Number.between(1, any_of.size)) }
          .map { |option| option.to_example(example_options) }
          .reduce(&:merge)
      end

      def type_based_example(example_options)
        send("#{type}_example", example_options) if %w[string integer number boolean array object].include?(type)
      end
    end
  end
end
