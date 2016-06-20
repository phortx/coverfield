module Coverfield::FileMethods
  attr_reader :file_name

  # Parse the source code
  private def parse_code
    @processed_source = RuboCop::ProcessedSource.from_file(@file_name, 2.3)
  end


  # Returns the file name relative to the app root
  public def relative_file_name
    @file_name.gsub(APP_ROOT + '/', '')
  end
end