require 'optparse'
require 'coverfield/config'

# Command Line Interface: Parses the options and constructs a
# Coverfield::Config, which is available via the `config` method
class Coverfield::CLI
  attr_reader :config

  # Constructor
  public def initialize
    # Create the config store
    @config = Coverfield::Config.new

    # Parse the CLI options and write them to the config store
    parse_cli_options

    # Determine all source pathes
    @config.include_paths = include_paths

    # Debug output
    @config.dump_config if @config.debug
  end


  # Parses the CLI options and writes them to the config store
  private def parse_cli_options
    opt_parser = OptionParser.new do |opt|
      opt.banner = 'Usage: coverfield [OPTION]... [FILE]...'
      opt.separator  ''
      opt.separator  'Options:'

      # --uncovered-only
      opt.on('-u', '--uncovered-only', "Don't print classes with 100% coverage") do
        @config.uncovered_only = true
      end

      # --skip-summary
      opt.on('-s', '--skip-summary', "Don't print the coverage summary") do
        @config.skip_summary = true
      end

      # --spec-dir
      opt.on('-d', '--spec-dir=DIR', "Sets the directory which contains the specs. Default is 'spec/'") do |dir|
        @config.spec_dir = dir
      end


      # --debug
      opt.on('-D', '--debug', 'Enables debug output') do
        @config.debug = true
      end

      # --help
      opt.on('-h', '--help', 'Prints usage informations') do
        puts opt
        exit
      end
    end

    opt_parser.parse!
  end


  # Determines all pathes where ruby source files should be searched in
  private def include_paths
    # Ensure there are paths to search for
    paths = ARGV
    paths = [config.app_root + '/lib'] if paths.empty?

    # Filter everything, that doesn't exist
    paths.select { |path| File.exists?(path) }
  end
end
