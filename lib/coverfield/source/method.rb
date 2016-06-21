class Coverfield::Source::Method
  attr_reader :name, :args, :body, :source_class

  public def initialize(method_name, args, body, source_class)
    @name = method_name
    @args = args
    @body = body
    @source_class = source_class
  end

  public def nocov?
    @source_class.source_file.nocov? @body
  end
end
