require 'csv'

class CSVParser
  class << self
    @@parsers = []

    private

    # Add a column parser
    def parse(criteria, params={}, &block)
      @@parsers << {
        criteria: criteria,
        block: block,
      }.merge(params)
    end

    # Add a parser that will only get called once per row
    def parse_once(criteria, params={}, &block)
      parse criteria, {
        once: true,
      }.merge(params), block
    end
  end

  def initialize(data, options={})
    @csv = CSV.new(data, options.merge(headers: false))
  end

  include Enumerable

  def each
    # Get header values used later in prasing
    @headers = @csv.shift.map(&:to_s).map(&:strip)

    # Parse each row
    @csv.each do |row|
      yield parse_row row
    end
  end

  private

  def parse_row(row)
    # Create a new attributes hash for this row, this will be our result
    @attributes = defaults
    # Keep track of which parsers have already been executed for this row
    @executed = []

    # Parse each column of the row
    row.each_with_index do |val, i|
      parse_val val.to_s.strip, @headers[i]
    end

    # Return the attributes that were built using #[]=
    @attributes
  end

  # Parse a column value
  def parse_val(val, key)
    @@parsers.each do |parser|
      # Execute any parsers that match this column
      if not onced?(parser) && match?(parser, val, key)
        instance_exec val, key, &parser[:block]
        @executed << parser
      end
    end
  end

  # Is the parser a once parser and has already been executed for this row?
  def onced?(parser)
    parser[:once] && @executed.include?(parser)
  end

  # Does the parser criteria match the column?
  def match?(parser, val, key)
    parser[:criteria] === key
  end

  # Default hash values to use for each row
  def defaults
    Hash.new
  end

  protected

  def [](name)
    @attributes[name]
  end

  def []=(name, val)
    @attributes[name] = val
  end
end