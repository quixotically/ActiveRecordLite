require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    if options.include?(:foreign_key)
      @foreign_key = options[:foreign_key]
    else
      @foreign_key = "#{name}_id".to_sym
    end

    if options.include?(:primary_key)
      @primary_key = options[:primary_key]
    else
      @primary_key = :id
    end

    if options.include?(:class_name)
      @class_name = options[:class_name]
    else
      @class_name = name.to_s.camelcase
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    if options.include?(:foreign_key)
      @foreign_key = options[:foreign_key]
    else
      @foreign_key = "#{self_class_name.underscore}_id".to_sym
    end

    if options.include?(:primary_key)
      @primary_key = options[:primary_key]
    else
      @primary_key = :id
    end

    if options.include?(:class_name)
      @class_name = options[:class_name]
    else
      @class_name = name.to_s.camelcase.singularize
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    define_method(name) do
      foreign_key = options.send(:foreign_key)
      foreign_key_value = self.send(foreign_key)
      model_class = options.model_class
      primary_key = options.primary_key
      model_class.where(primary_key => foreign_key_value).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)

    define_method(name) do
      primary_key = options.send(:primary_key)
      primary_key_value = self.send(primary_key)
      model_class = options.model_class
      foreign_key = options.foreign_key
      model_class.where(foreign_key => primary_key_value)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
