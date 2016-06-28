class Coverfield::Report
  public def initialize(config, source_files)
    @config = config
    @source_files = source_files
  end


  public def full_report
    # Some counter variables
    @total_covered = 0
    @total_methods = 0
    @total_relevant_methods = 0

    # Will contain the report
    report = ''

    # Iterate over all found files and generate a report for each file
    report << @source_files.map(&method(:for_file)).reject(&:empty?).join("\n")

    # Report summary
    unless @config.skip_summary
      # Some calculations
      total_uncovered = @total_relevant_methods - @total_covered
      relevant_percent = (@total_relevant_methods * 100 / @total_methods).round.to_s + '%'
      covered_percent = (@total_covered * 100 / @total_methods).round.to_s + '%'
      uncovered_percent = (total_uncovered * 100 / @total_methods).round.to_s + '%'

      # Generate summary
      report << "\nThere are #{@total_methods.to_s.yellow} methods in total.\n"
      report << "#{@total_relevant_methods.to_s.yellow} (#{relevant_percent.yellow}) of them are relevant for coverage.\n"
      report << "And #{@total_covered.to_s.yellow} (#{covered_percent.yellow}) methods are covered by tests.\n"
      report << "Thus there are #{total_uncovered.to_s.yellow} (#{uncovered_percent.yellow}) uncovered methods.\n"
    end

    report + "\n"
  end


  # Tells if a line should be displayed according to the amount of
  # relevant_methods, if the class is covered and the config
  private def should_display_line?(relevant_methods, covered)
    relevant_methods > 0 && !(@config.uncovered_only && covered)
  end


  private def for_file(file)
    report = ''

    # Generate a report for each class in that file
    file.classes.each do |cls|
      covered = cls.coverage == cls.relevant_method_count

      if should_display_line?(cls.relevant_method_count, covered)
        class_name = cls.full_qualified_name.to_s.light_blue
        coverage = "#{cls.coverage}/#{cls.relevant_method_count}/#{cls.method_count}"
        report << "#{covered ? '[X]'.green : '[ ]'.red} Found class: #{class_name} with #{covered ? coverage.green : coverage.red} covered methods.\n".bold
        report << "    => Source file: #{file.relative_file_name.light_blue}\n"

        if file.test_file.file_exists?
          report << "    => Test file: #{file.test_file.relative_file_name.light_blue}\n"
        else
          report << "    => Test file: #{'Not found'.light_red} (expected one of #{file.allowed_test_files.join(', ')})\n"
        end

        # Write the hints to the report
        if cls.hints.any?
          report << cls.hints.map{ |hint| "    - #{hint}" }.reject(&:empty?).join("\n")
          report << "\n"
        end
      end

      # Increase the counter variables
      @total_methods += cls.method_count
      @total_relevant_methods += cls.relevant_method_count
      @total_covered += cls.coverage
    end

    report
  end
end
