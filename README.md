# CSVParser

Parse CSV rows by defining parsing blocks for individual columns.

Each row is parsed one-by-one. First a new *Hash* is initialized to
store data for the row. Then, each **individual column** is parsed by
calling matching parsing blocks. Parsing blocks are passed the column's
value and header key and can set arbitrary state on the *Hash* for the
current row.

## Installation

```
$ gem install parshap-csv_parser
```

## Usage

Example:

```rb
class MyParser < CSVParser
  parse "Name" do |val|
    self[:name] = val
  end
end

parser = MyParser.new CSV.open "data.csv"
parser.each do |row|
  puts row[:name]
end
```

See `example.rb` and `test.rb` for more examples.

### Defining Parsers

Parsing blocks are added using the `CSVParser.parse` class method. The
first and only parameter, *case*, determines if the block should be
executed for a particular column (by using the `===` operator with the
column's header value). The block is passed the column value and its
associated header value. The block can update the values for the current
row by using `self` as a *Hash*.

Column and header values are always converted to strings and `strip`ped
of whitespace first.

```rb
class MyParser < CSVParser
  parse /^(first|last)?\W*name$/i do |val|
    self[:name] = val.capitalize
  end
end
```

#### Once Parsers

Using `CSVParser.parse_once`, you can define parsers that will only be
called once per row, for the first matching column. In the above
example, if `parse_once` was used, the block would only be called once
even with the occurrence of multiple *name* columns.

### Default Row Values

The `CSVParser#defaults` method is used to generate a hash to use for
each row. You can use this to set default values.

```rb
class MyParser < CSVParser
  def defaults
    { name: "User", emails: [] }
  end
end
```

## Tests

```
$ ruby test.rb
```
