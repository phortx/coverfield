class Coverfield::Report
  public def initialize(source_files)
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

    # Some calculations
    total_uncovered = @total_relevant_methods - @total_covered
    relevant_percent = (@total_relevant_methods * 100 / @total_methods).round.to_s + '%'
    covered_percent = (@total_covered * 100 / @total_methods).round.to_s + '%'
    uncovered_percent = (total_uncovered * 100 / @total_methods).round.to_s + '%'

    # Generate summary
    report << "\nThere are #{@total_methods.to_s.yellow} methods in total.\n"
    report << "#{@total_relevant_methods.to_s.yellow} (#{relevant_percent.yellow}) of them are relevant for coverage.\n"
    report << "And #{@total_covered.to_s.yellow} (#{covered_percent.yellow}) methods are covered by tests.\n"
    report << "Thus there are #{total_uncovered.to_s.yellow} (#{uncovered_percent.yellow}) uncovered methods.\n\n"

    report
  end


  private def for_file(file)
    report = ''

    # Generate a report for each class in that file
    file.classes.each do |cls|
      class_name = cls.full_qualified_name.to_s.light_blue
      coverage = "#{file.coverage}/#{cls.relevant_method_count}/#{cls.method_count}"
      covered = file.coverage == cls.relevant_method_count
      report << "#{covered ? '[X]'.green : '[ ]'.red} Found class: #{class_name} with #{covered ? coverage.green : coverage.red} covered methods in #{file.relative_file_name.light_blue}\n".bold

      # Write the hints to the report
      if file.hints.any?
        report << file.hints.map{ |hint| "    - #{hint}" }.reject(&:empty?).join("\n")
        report << "\n"
      end

      # Increase the counter variables
      @total_methods += cls.method_count
      @total_relevant_methods += cls.relevant_method_count
      @total_covered += file.coverage
    end

    report
  end
end
