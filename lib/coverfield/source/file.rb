require 'coverfield/source/file_methods'
require 'coverfield/source/test_file'
require 'coverfield/source/class'
require 'coverfield/source/nocov_range'

class Coverfield::Source::File
  include Coverfield::Source::FileMethods

  attr_reader :classes, :test_file, :coverage, :hints

  # Constructor
  public def initialize(file_name)
    @file_name = file_name
    @classes = []
    @coverage = 0
    @hints = []
    @nocov_ranges = []

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


  # Calculates the number of covered methods of this file and sets @coverage and @hints
  private def calculate_coverage
    @coverage = 0

    classes.each do |cls|
      cls.methods.each do |method|
        if test_file.cover?(cls.full_qualified_name, method.name)
          @coverage += 1
        else
          method_name = "#{cls.name}.#{method.name}".red

          if method.nocov?
            @coverage += 1
          else
            @hints << "Missing test for #{method_name} in #{test_file.relative_file_name.yellow}"
          end
        end
      end
    end
  end


  public def nocov?(method_body_node)
    @nocov_ranges.each do |nocov_range|
      return true if nocov_range.includes?(method_body_node)
    end

    false
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

      @classes << Coverfield::Source::Class.new(const_name, module_name, node, self)
    end
  end


  # Find the spec file for that class
  private def find_test_file
    spec_path = APP_ROOT + '/spec'
    relative_file_name = @file_name.to_s.gsub(APP_ROOT, '')
    @test_file = Coverfield::Source::TestFile.new(spec_path + relative_file_name.gsub('.rb', '_spec.rb'))

    # When no file was found also try without '/lib' or '/app'
    unless @test_file.file_exists?
      relative_file_name.gsub!(/^\/(lib|app)/, '')
      @test_file = Coverfield::Source::TestFile.new(spec_path + relative_file_name)
    end
  end


  private def find_nocov_ranges
    first = true
    line = 0

    @processed_source.comments.each do |comment|
      if comment.type == :inline && comment.text.strip =~ /^#\s*\:nocov\:/
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
