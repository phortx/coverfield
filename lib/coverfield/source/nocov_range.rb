class Coverfield::Source::NocovRange
  public def initialize(first_line, last_line)
    @first_line = first_line
    @last_line = last_line
  end

  public def includes?(node)
    source_range = node.source_range
    source_range.first_line > @first_line && source_range.last_line < @last_line
  end
end
