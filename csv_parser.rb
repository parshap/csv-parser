require 'csv'

class CSVParser
  class << self
    @@parsers = []

    private

    def parse(criteria, params={}, &block)
      @@parsers << {
        criteria: criteria,
        block: block,
      }.merge(params)
    end

    def parse_once(criteria, params={}, &block)
      parse criteria, {
        once: true,
      }.merge(params), block
    end
  end

  def initialize(data, options={})
      @csv = CSV.new(data, options.merge headers: false)
  end

  include Enumerable

  def each
    @headers = @csv.shift.map(&:to_s).map(&:strip)

    super() do |row|
      yield parse_row row
    end
  end

  private

  def parse_row(row)
    @attributes = {}
    @executed = []

    row.each_with_index do |val, i|
      parse_val val.to_s.strip, @headers[i]
    end

    @attributes
  end

  def parse_val(val, key)
    @@parsers.each do |parser|
      if not onced?(parser) && match?(parser, val, key)
        instance_exec val, key, &parser[:block]
        @executed << parser
      end
    end
  end

  def onced?(parser)
    parser[:once] && @executed.include?(parser)
  end

  def match?(parser, val, key)
    parser[:criteria] === key
  end

  protected

  def [](name)
    @attributes[name]
  end

  def []=(name, val)
    @attributes[name] = val
  end
end

class ZillowContactImporter < CSVParser
  before do
    self[:contact] = Hash.new
    self[:notes] = []
    self[:contact_types] = []
    self[:phone_numbers] = []
    self[:property_search] = {
      misc_locations: []
    }
  end

  parse_once "Name" do |val|
    first_name, last_name = val.split(nil, 2)
    # @TODO need `to_s`?
    self[:contact][:first_name] = first_name
    self[:contact][:last_name] = last_name
  end

  parse_once "Search Timeframe" do |val|
    self[:contact][:timeframe] = val
  end

  parse_once "Email (Personal) #1" do |val|
    self[:contact][:email] = split(val).join ","
  end

  parse_once "Contact Type" do |val|
    self[:contact_types] << val
  end

  parse_once /^Phone (Mobile) #\d$/ do |val|
    self[:phone_numbers] << {
      label: "Cell",
      number: val,
    }
  end

  # Notes
  [
    "Note",
    "Home Type",
    "Latest Communication",
    /^Listing #\d$/,
  ].each do |name|
    parse name do |val|
      # @TODO Include label somehow?
      self[:notes] << {
        content: val
      }
    end
  end

  # Property Search

  parse_once "Min. Price" do |val|
    self[:property_search][:price_low] = val
  end

  parse_once "Max. Price" do |val|
    self[:property_search][:price_high] = val
  end

  parse /^Location #\d$/ do |val|
    self[:property_search][:misc_locations] << {
      name: "Other #{val}",
      location_value: val,
    }
  end

  private

  def split(s)
    s.split(/[\s*,;]/).map(&:strip).reject(&:empty?)
  end
end