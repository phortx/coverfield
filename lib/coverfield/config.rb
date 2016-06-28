# A simple config store
class Coverfield::Config
  attr_accessor :uncovered_only,
                :skip_summary,
                :include_paths,
                :app_root,
                :spec_dir,
                :debug

  # Constructor
  public def initialize
    @uncovered_only = false
    @skip_summary = false
    @debug = false
    @include_paths = []
    @spec_dir = 'spec/'

    # Bundler already contains a good logic to determine the apps root
    require 'bundler'
    @app_root = Bundler.root.to_s
  end


  # Returns the full absolute path to the spec dir
  public def spec_path
    @app_root + '/' + @spec_dir
  end


  # Prints all options
  public def dump_config
    puts 'Options:'.blue
    puts "    Uncovered only:  #{@uncovered_only}"
    puts "    Skip summary:    #{@skip_summary}"
    puts "    Debug mode:      #{@debug}"
    puts "    Include paths:   #{@include_paths}"
    puts "    App root:        #{@app_root}"
    puts "    Spec directory:  #{@spec_dir} (= #{spec_path})"
    puts
    puts
  end
end
