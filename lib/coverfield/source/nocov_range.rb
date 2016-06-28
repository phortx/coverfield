# Represents a range of lines in a source file which is wrapped in :nocov: tags
class Coverfield::Source::NocovRange
  # Consructor
  public def initialize(first_line, last_line)
    @first_line = first_line
    @last_line = last_line
  end

  # Tells if a node is within that nocov rage
  public def includes?(node)
    source_range = node.source_range
    source_range.first_line > @first_line && source_range.last_line < @last_line
  end
end
