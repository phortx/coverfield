module Coverfield
  module Source
  end

  class << self
    # Finds all ruby source files in the given paths
    # Returns an array of Coverfield::Source::File instances
    public def find_source_files(config)
      require 'rubocop'
      require 'coverfield/source/file'

      # Find files
      target_finder = RuboCop::TargetFinder.new(RuboCop::ConfigStore.new)
      target_files = target_finder.find(config.include_paths)


      # Map all found files to SourceFiles
      target_files = target_files.map { |file| Coverfield::Source::File.new(config, file) }

      # Debug output
      dump_file_list(target_files) if config.debug

      # Return the file list
      target_files
    end


    # Dumps the list of found files
    private def dump_file_list(file_list)
      puts "Found #{file_list.size} source files:".blue

      file_list.each do |file|
        test_file_word = (file.test_file.file_exists? ? 'a'.green : 'no'.red)
        puts "    - #{file.relative_file_name} with #{test_file_word} test file"
      end

      puts
      puts
    end
  end
end
