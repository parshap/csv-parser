# CSVParser

Parse CSV rows by defining parsing blocks for individual columns.

Each row is parsed one-by-one. First a new *Hash* is initialized to store data for the row. Then, each **individual column** is parsed by calling matching parsing blocks. Parsing blocks are passed the column's value and header key and can set arbitrary state on the *Hash* for the current row.

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

### Defining Parsers

Parsing blocks are added using the `CSVParser.parse` class method. The first and only parameter, *case*, determines if the block should be executed for a particular column (by using the `===` operator with the column's header value). The block is passed the column value and its associated header value. The block can update the values for the current row by using `self` as a *Hash*.

Column and header values are always converted to strings and `strip`ped of whitespace first.

```rb
class MyParser < CSVParser
  parse /^(first|last)?\W*name$/i do |val|
    self[:name] = val.capitalize
  end
end
```

#### Once Parsers

Using `CSVParser.parse_once`, you can define parsers that will only execute once per row at most. In the above example, if `parse_once` was used, the block would only be called once even with the occurrence of multiple *name* columns.

### Default Row Values

The `CSVParser#defaults` method is used to generate a hash to use for each row. You can use this to set default values.

```rb
class MyParser < CSVParser
  def defaults
    { name: "User", email: [] }
  end
end
```

## Questions

### Setting values in blocks

Is the `#[]=` method to allow `self[:something]` inside the blocks good? Is it weird setting state that way? Is there a better way? 

Should I maybe do something like the following so that each row's data is explicitly in scope and I don't have the `#[]=` magic?

```rb
class MyParser < CSVParser
  row do |data|
    parse "Name" do |val|
      data[:name] = val
    end
  end
end
```

### Protected & Private

Are my uses correct? `#[]=` is protected because it needs to be called with an explicit receiver (`self`) but the rest of the methods are only used internally with the implicit receiver, so I think they should be private?

### Instance-based parsers instead of class-based

Would it be better to define parsers by creating new instances, instead of having to define classes? For example, the API might alternatively look something like:

```rb
parser = CSVParser.new(CSV.open "data.csv") do
  defaults { { name: "User", email: [] } }

  parse "Name" do |val|
    self[:name] = val.capitalize
  end
end

parser.each do |row|
  # ...
end
```

### Yield instead of returning?

Should I yield the `parser` instance to a block instead of directly returning it? I guess this doesn't make too much sense for `CSVParser.new` but maybe if there was a `CSVParser.open` class method? Or does it?