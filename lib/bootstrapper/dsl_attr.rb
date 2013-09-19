module Bootstrapper

  # Unique object that can be used as a default argument for "DSL style"
  # setters to differentiate from nil.
  NULL_ARG = Object.new


  # == Bootstrapper::DSLAttr
  # Extends a class with a class method for defining "DSL attrs", which are
  # like attr_accessor except that they also support "DSL style" setters, that
  # is:
  #    obj.attribute("new value")
  module DSLAttr

    def dsl_attr(attr_name)
      attr_writer attr_name
      ivar = "@#{attr_name}"
      # default value of block arg not ruby 18 friendly
      define_method(attr_name) do |value=NULL_ARG|
        if value.equal?(NULL_ARG)
          instance_variable_get(ivar)
        else
          instance_variable_set(ivar, value)
        end
      end
    end

  end
end
