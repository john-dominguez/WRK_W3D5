require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    cols = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      LIMIT
        0
    SQL
    cols = cols.first
    cols.map!(&:to_sym)
    @columns = cols
  end

  def self.finalize!
    self.columns.each do |col|
      define_method(col) do
        self.attributes[col]
      end

      define_method("#{col}=") do |value|
        self.attributes[col] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.tableize
  end

  def self.all
    table = DBConnection.execute2(<<-SQL)
      select "#{self.table_name}".*
      from "#{self.table_name}"
    SQL
    table.map {|el| self.new(el)}
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    params.each do |name, value|
      sym = name.to_sym
      if self.class.columns.include?(sym)
        self.send("#{sym}=",value)
      else
        raise "unknown attribute '#{sym}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |atr| self.send(atr) }
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
