class ExampleParser < CSVParser
  parse_once "Name" do |val|
    first_name, last_name = val.split(nil, 2)
    self[:first_name] = first_name
    self[:last_name] = last_name
  end

  parse_once "Search Timeframe" do |val|
    self[:timeframe] = val
  end

  parse_once "Email (Personal) #1" do |val|
    self[:email] = split(val).join ","
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

  def defaults
    {
      notes: [],
      contact_types: [],
      phone_numbers: [],
      property_search: {
        misc_locations: [],
      },
    }
  end
end
