# Represents a method within a class
class Coverfield::Source::Method
  attr_reader :name, :args, :body, :source_class

  # Constructor
  public def initialize(method_name, args, body, source_class)
    @name = method_name
    @args = args
    @body = body
    @source_class = source_class
  end


  # Tells whether the method should be covered by a test or not
  public def nocov?
    @source_class.source_file.nocov? @body
  end
end
