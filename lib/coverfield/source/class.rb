require 'coverfield/source/method'

class Coverfield::Source::Class
  attr_reader :name, :module_name, :node, :methods, :source_file

  # Constructor
  public def initialize(class_name, module_name, node, source_file)
    @name = class_name
    @module_name = module_name
    @node = node
    @methods = []
    @source_file = source_file
    find_methods
  end

  public def full_qualified_name
    name = @name
    name = "#{@module_name}::#{name}" unless @module_name.empty?
    name
  end

  public def relevant_method_count
    relevant_methods = @methods.select { |m| !m.nocov?}
    relevant_methods.size
  end

  public def method_count
    @methods.size
  end

  # Finds all methods
  private def find_methods
    node.each_node(:def) do |node|
      @methods << Coverfield::Source::Method.new(*node, self)
    end
  end
end
