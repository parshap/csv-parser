require "test/unit"
require "csv"
require_relative "lib/csv_parser"

class SimpleParser < CSVParser
  attr_reader :called
  attr_reader :once_called
  attr_reader :first_called

  def initialize(csv)
    @called = 0
    @once_called = 0
    @first_called = 0
    super
  end

  parse String do |val, key|
    @called += 1
    self[key] = val
  end

  parse_once String do
    @once_called += 1
  end

  parse "first" do
    @first_called += 1
  end
end

class RegexpParser < CSVParser
  parse /first(_name)?/ do |val, key|
    self[key] = val
  end
end

class MethodParser < CSVParser
  parse :foo do |val, key|
    self[key] = val
  end

  def foo(key)
    true
  end
end

class CSVParserTest < Test::Unit::TestCase
  def csv
    CSV.new <<-EOF
      first,last
      parsha,pourkhomami
      hey,you
    EOF
  end

  def test_basic
    count = 0
    CSVParser.new(csv).each do |data|
      assert data
      count += 1
    end
    assert_equal 2, count
  end

  def test_simple_parser
    assert_equal 0, CSVParser.parsers.length
    assert_equal 3, SimpleParser.parsers.length

    parser = SimpleParser.new csv
    count = 0
    array = []

    parser.each do |data|
      assert data
      count += 1
      assert_equal 2 * count, parser.called
      assert_equal 1 * count, parser.once_called
      assert_equal 1 * count, parser.first_called
      array << data
    end

    assert_equal({
      "first" => "parsha",
      "last" => "pourkhomami",
    }, array[0])

    assert_equal({
      "first" => "hey",
      "last" => "you",
    }, array[1])

    assert_equal 2, count
    assert_equal 2, array.length
    assert_equal 4, parser.called
    assert_equal 2, parser.once_called
    assert_equal 2, parser.first_called
  end

  def test_regexp
    array = RegexpParser.new(csv).to_a
    assert_equal 2, array.length
    assert_equal({ "first" => "parsha" }, array[0])
    assert_equal({ "first" => "hey" }, array[1])
  end

  def test_method_criteria
    array = MethodParser.new(csv).to_a
    assert_equal 2, array.length
    assert_equal({ "first" => "parsha", "last" => "pourkhomami" }, array[0])
    assert_equal({ "first" => "hey", "last" => "you" }, array[1])
  end
end
