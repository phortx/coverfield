require 'coverfield/source/file_methods'

# Represents a spec file
class Coverfield::Source::TestFile
  include Coverfield::Source::FileMethods


  # Constructor
  public def initialize(config, file_name)
    @config = config
    @file_name = config.app_root + '/' + file_name
    @file_exists = File.exists?(file_name) && !File.zero?(file_name)
    @describes = {}

    # If the file doesn't exist, do nothing
    if file_exists?
      parse_code
      find_describes
    end
  rescue Exception => e
    raise RuntimeError, "Error while processing file #{file_name}: #{e.message}", e.backtrace
  end


  # Tells if the test file even exists
  public def file_exists?
    @file_exists
  end


  # Tells if that file covers a method of a class pair
  public def cover?(class_name, method_name)
    return false unless file_exists?

    @describes.each_pair do |subject, test_methods|
      return true if subject == class_name &&
                     test_methods.include?(method_name.to_s)
    end

    false
  end


  # Helper method which builts the full qualified class name out of
  # a describe arguments node
  private def get_spec_class_name(describe_args_node)
    # If the argument is already a string, there's nothing to do
    return describe_args_node if describe_args_node.is_a?(String)

    # Otherwise it's a constant chain like Coverfield::Source::TestFile
    # which will be concatenated
    subject_ary = []

    describe_args_node.each_node(:const) do |const_part|
      _scope, const_name, value = *const_part
      subject_ary << const_name
    end

    subject_ary.reverse * '::'
  end


  # Collects the describe calls in the spec and sets @describes
  private def find_describes
    # Contains the current test subject where alls test methods should be associated with
    current_subject = nil
    first_describe = true

    # Iterate over all send nodes (method calls)
    @processed_source.ast.each_node(:send) do |node|
      # Get the args and the method_name
      nothing, method_name, args = *node

      # We only care if it's a describe() call
      if method_name == :describe
        if first_describe || args.const_type?
          # If it's a const, it's the first describe, which describes the class/module to test
          current_subject = get_spec_class_name(args)
          @describes[current_subject] = []
        else
          # Otherwise, get the String argument, it will contain something like '#method_name'
          value, nothing = *args.each_node(:str).first

          if value == nil
            # That happens if the argument is a symbol
            value, nothing = *args.each_node(:sym).first
            value = value.to_s
          end

          # Remove the . or # from the string
          @describes[current_subject] << value.strip.gsub(/^(?:\.|#)(.+)$/i, '\1')
        end

        first_describe = false
      end
    end
  end
end
