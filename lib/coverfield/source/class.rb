require 'coverfield/source/method'

# Represents a class within a source file
class Coverfield::Source::Class
  attr_reader :name, :module_name, :node, :methods, :source_file, :coverage, :hints

  # Constructor
  public def initialize(class_name, module_name, node, source_file)
    @name = class_name
    @module_name = module_name
    @node = node
    @methods = []
    @source_file = source_file
    @coverage = 0
    @hints = []
    find_methods
  end


  # Returns the full qualified name like Coverfield::Source::Class
  public def full_qualified_name
    name = @name
    name = "#{@module_name}::#{name}" unless @module_name.empty?
    name
  end


  # Returns the amount of methods, which should be covered by tests
  public def relevant_method_count
    relevant_methods = @methods.select { |m| !m.nocov?}
    relevant_methods.size
  end


  # Returns the total amount of methods within the class
  public def method_count
    @methods.size
  end


  # Calculates the coverage of that class based on the relevant methods
  # and sets the @coverage and the @hints fields
  public def calculate_coverage
    @coverage = 0
    @hints = []
    test_file = source_file.test_file

    methods.each do |method|
      # Is the method covered?
      if test_file.cover?(full_qualified_name, method.name)
        @coverage += 1
      else
        # Should it be covered?
        if method.nocov?
          @coverage += 1
        else
          # If it should be covered, but isn't, create a hint
          method_name = "#{name}.#{method.name}".red
          @hints << "Missing test for #{method_name}"
        end
      end
    end
  end


  # Finds all methods within the class
  private def find_methods
    node.each_node(:def) do |node|
      @methods << Coverfield::Source::Method.new(*node, self)
    end
  end
end
