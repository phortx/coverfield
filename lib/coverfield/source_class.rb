class Coverfield::SourceClass
  attr_reader :name, :module_name, :node, :methods

  # Constructor
  public def initialize(class_name, module_name, node)
    @name = class_name
    @module_name = module_name
    @node = node
    @methods = []
    find_methods
  end

  # Finds all methods
  private def find_methods
    node.each_node(:def) do |node|
      method_name, args, body = *node
      @methods << method_name
    end
  end
end
