module Coverfield
  module Source
  end

  class << self
    public def find_source_files(paths)
      require 'rubocop'
      require 'coverfield/source/file'

      # Find files
      target_finder = RuboCop::TargetFinder.new(RuboCop::ConfigStore.new)
      target_files = target_finder.find(paths)


      # Map all found files to SourceFiles
      target_files.map { |file| Coverfield::Source::File.new(file) }
    end
  end
end
