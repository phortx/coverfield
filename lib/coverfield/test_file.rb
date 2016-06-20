class Coverfield::TestFile
  include Coverfield::FileMethods

  # Constructor
  public def initialize(file_name)
    @file_name = file_name
    @file_exists = File.exists?(@file_name) && !File.zero?(file_name)
    @describes = {}

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


  # Tells if that file covers a class_name method_name pair
  public def cover?(class_name, method_name)
    return false unless file_exists?

    @describes.each_pair do |subject, test_methods|
      return true if subject == class_name &&
                     test_methods.include?(method_name.to_s)
    end

    false
  end


  # Small helper method which builts the full qualified class name out of a describe arguments node
  private def get_spec_class_name(describe_args_node)
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

    # Iterate over all send nodes (method calls)
    @processed_source.ast.each_node(:send) do |node|
      # Get the args and the method_name
      nothing, method_name, args = *node

      # We only care if it's a describe() call
      if method_name == :describe
        if args.const_type?
          # If it's a const, it's the first describe, which describes the class/module to test
          current_subject = get_spec_class_name(args)
          @describes[current_subject] = []
        else
          # Otherwise, get the String argument, it will contain something like '#method_name'
          value, nothing = *args.each_node(:str).first
          @describes[current_subject] << value.strip.gsub(/^(?:\.|#)(.+)$/i, '\1')
        end
      end
    end
  end
end
