require 'coverfield/source/file_methods'
require 'coverfield/source/test_file'
require 'coverfield/source/class'
require 'coverfield/source/nocov_range'

# Represents a ruby source file which consists of classes
class Coverfield::Source::File
  include Coverfield::Source::FileMethods

  attr_reader :classes, :test_file


  # Constructor
  public def initialize(config, file_name)
    @config = config
    @file_name = file_name
    @classes = []
    @nocov_ranges = []

    # Ignore empty files
    unless File.zero?(file_name)
      parse_code
      find_nocov_ranges
      find_classes
      find_test_file
      calculate_coverage
    end
  rescue Exception => e
    raise RuntimeError, "Error while processing file #{file_name}: #{e.message}", e.backtrace
  end


  # Iterates over all classes and calculates their test coverage
  private def calculate_coverage
    classes.each { |cls| cls.calculate_coverage }
  end


  # Tells if a method node is located within two :nocov: tags
  public def nocov?(method_body_node)
    @nocov_ranges.each do |nocov_range|
      return true if nocov_range.includes?(method_body_node)
    end

    false
  end


  # Finds all class definitions within that file
  private def find_classes
    @processed_source.ast.each_node(:class) do |node|
      name, superclass, body = *node
      _scope, const_name, value = *name
      module_name = node.parent_module_name

      # If the module_name is 'Object', the notation is not Coverfield::Source::TestFile but nested modules/class
      if module_name == 'Object'
        nothing, scope_name, nothing = *_scope
        module_name = scope_name.to_s
      end

      # Create a new class object and push that to the @classes array
      @classes << Coverfield::Source::Class.new(const_name, module_name, node, self)
    end
  end


  # Find the spec file for that class
  private def find_test_file
    allowed_test_files.each do |file|
      @test_file = Coverfield::Source::TestFile.new(@config, file)

      # break
      return false if test_file.file_exists?
    end
  end


  public def allowed_test_files
    template = (@config.spec_dir + relative_file_name).gsub('.rb', '_spec.rb')
    allowed_files = *template
    allowed_files << template.gsub(/^\/(lib|app)/, '')
    allowed_files
  end


  # Collects all :nocov: tag ranges in the file
  private def find_nocov_ranges
    first = true
    line = 0

    @processed_source.comments.each do |comment|
      if comment.type == :inline && comment.text.strip =~ /^#\s*:nocov:/
        if first
          line = comment.loc.expression.first_line
        else
          @nocov_ranges << Coverfield::Source::NocovRange.new(line, comment.loc.expression.first_line)
        end

        first = !first
      end
    end
  end
end
