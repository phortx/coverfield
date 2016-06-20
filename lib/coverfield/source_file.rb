require 'coverfield/file_methods'

class Coverfield::SourceFile
  include Coverfield::FileMethods

  attr_reader :classes, :test_file, :coverage, :hints

  # Constructor
  public def initialize(file_name)
    @file_name = file_name
    @classes = []
    @coverage = 0
    @hints = []

    unless File.zero?(file_name)
      parse_code
      find_classes
      find_test_file
      calculate_coverage
    end
  rescue Exception => e
    raise RuntimeError, "Error while processing file #{file_name}: #{e.message}", e.backtrace
  end


  # Calculates the number of covered methods of this file and sets @coverage and @hints
  public def calculate_coverage
    @coverage = 0

    classes.each do |cls|
      cls.methods.each do |method_name|
        if test_file.cover?(cls.full_qualified_name, method_name)
          @coverage += 1
        else
          method_name = "#{cls.name}.#{method_name}".red
          @hints << "Missing test for #{method_name} in #{test_file.relative_file_name.yellow}"
        end
      end
    end
  end


  # Find class definitions
  private def find_classes
    @processed_source.ast.each_node(:class) do |node|
      name, superclass, body = *node
      _scope, const_name, value = *name
      module_name = node.parent_module_name

      if module_name == 'Object'
        nothing, scope_name, nothing = *_scope
        module_name = scope_name.to_s
      end

      @classes << Coverfield::SourceClass.new(const_name, module_name, node)
    end
  end


  # Find the spec file for that class
  private def find_test_file
    relative_file_name = @file_name.to_s.gsub(APP_ROOT, '')
    relative_file_name.gsub!('/app', '')
    @test_file = Coverfield::TestFile.new(APP_ROOT + '/spec' + relative_file_name.gsub('.rb', '_spec.rb'))
  end
end
