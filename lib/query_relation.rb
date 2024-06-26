require 'query_relation/version'
require 'query_relation/queryable'

require 'forwardable'

class QueryRelation
  extend Forwardable
  include Enumerable
  attr_reader :klass
  attr_accessor :options

  # - [ ] bind
  # - [ ] create_with
  # - [ ] distinct
  # - [ ] eager_load
  # - [X] except ? - is this not defined in the interface?
  # - [ ] extending
  # - [ ] from
  # - [X] group
  # - [ ] ~~having~~ - NO
  # - [X] includes (partial)
  # - [ ] joins
  # - [X] limit
  # - [ ] lock
  # - [.] none
  # - [X] offset
  # - [X] order (partial)
  # - [ ] preload
  # - [ ] readonly
  # - [X] references (partial)
  # - [X] reorder
  # - [ ] reverse_order
  # - [X] select (partial)
  # - [X] unscope
  # - [ ] uniq
  # - [X] where (partial)
  # - [ ] where.not

  def initialize(model, opts = nil, &block)
    @klass   = model
    @options = opts ? opts.dup : {}
    @target = block || ->(*args) { klass.send(:search, *args) }
  end

  def where(*val)
    val = val.flatten.compact
    val = val.first if val.size == 1 && val.first.kind_of?(Hash)
    dup.tap do |r|
      old_where = r.options[:where]
      if val.nil? || val.empty?
        # nop
      elsif old_where.nil? || old_where.empty?
        r.options[:where] = val
      elsif old_where.kind_of?(Hash) && val.kind_of?(Hash)
        old_where = r.options[:where] = r.options[:where].dup
        val.each_pair do |key, value|
          old_where[key] = if old_where[key]
                             Array(old_where[key]) + Array(value)
                           else
                             value
                           end
        end
      else
        raise ArgumentError,
              "Need to support #{__callee__}(#{val.class.name}) with existing #{old_where.class.name}"
      end
    end
  end

  def where_values
    options[:where]
  end

  def includes(*args)
    append_hash_array_arg :includes, {}, *args
  end

  def references(*args)
    append_hash_array_arg :references, {}, *args
  end

  # @param val [Integer] maximum number of rows to bring back
  def limit(val)
    assign_arg :limit, val
  end

  def limit_value
    options[:limit]
  end

  # @param columns [Array<Symbol>, Symbol] columns for order
  def order(*columns)
    append_hash_array_arg :order, "ASC", *columns
  end

  def order_values
    options[:order] || []
  end

  # @param columns [Array<Symbol>, Symbol] columns for order, replacing original
  def group(*columns)
    append_hash_arg :group, *columns
  end

  # @param columns [Array<Symbol>, Symbol] columns for order, replacing original
  def reorder(*columns)
    columns = columns.flatten.compact
    if columns.first.kind_of?(Hash)
      raise ArgumentError, "Need to support #{__callee__}(#{columns.class.name})"
    end

    assign_arg(:order, columns)
  end

  # @param val [Array<Symbol>, Symbol] attributes to remove from the query
  def except(*val)
    dup.tap do |r|
      val.flatten.compact.each do |key|
        r.options.delete(key)
      end
    end
  end

  # @param val [Array<Symbol>, Symbol] attributes to remove from the query
  # similar to except. difference being this persists across merges
  def unscope(*val)
    dup.tap do |r|
      val.flatten.compact.each do |key|
        r.options[key] = nil
      end
    end
  end

  # @param val [Integer] offset
  def offset(val)
    assign_arg :offset, val
  end

  def offset_value
    options[:offset]
  end

  # @param columns [Array<Sting, Symbol>, String, Symbol] columns to bring back
  def select(*columns)
    append_hash_arg :select, *columns
  end

  # @param columns [Array<Sting,Symbol>,String, Symbol] columns to bring back
  def pluck(*columns)
    columns = columns.flatten.compact

    val = assign_arg(:select, columns).to_a

    if columns.size == 1
      column = columns.first
      val.map { |row| row[column] }
    else
      val.map { |row| columns.map { |col| row[col] } }
    end
  end

  def to_a
    @results ||= call_query_method(:all)
  end

  def all
    self
  end

  # count(:all) is very common
  # but [1, 2, 3].count(:all) == 0
  def count(*_args)
    to_a.size
  end

  def_delegators :to_a, :size, :length, :take, :each, :empty?

  def presence
    to_a if present?
  end

  def blank?
    to_a.nil? || to_a.empty?
  end

  def present?
    !blank?
  end

  # TODO: support arguments
  def first
    defined?(@results) ? @results.first : call_query_method(:first)
  end

  # TODO: support arguments
  def last
    defined?(@results) ? @results.last : call_query_method(:last)
  end

  def instances_are_derived?
    true
  end

  private

  def dup
    self.class.new(klass, options, &@target)
  end

  def call_query_method(mode)
    @target.call(mode, options.delete_if { |_n, v| v.nil? || (v.respond_to?(:empty?) && v.empty?) })
  end

  def append_hash_arg(symbol, *val)
    val = val.flatten.compact
    if val.first.kind_of?(Hash)
      raise ArgumentError, "Need to support #{symbol}(#{val.class.name})"
    end
    dup.tap do |r|
      r.options[symbol] = r.options[symbol] ? (r.options[symbol] + val) : val
    end
  end

  def append_hash_array_arg(symbol, default, *val)
    val = val.flatten.compact
    val = val.first if val.size == 1 && val.first.kind_of?(Hash)
    dup.tap do |r|
      r.options[symbol] = merge_hash_or_array(r.options[symbol], val, default)
    end
  end

  # @param a [Array, Hash]
  # @param b [Array, Hash]
  # @param default default value for conversion to a hash. e.g.: {} or "ASC"
  def merge_hash_or_array(a, b, default = {})
    if a.nil? || a.empty?
      b
    elsif b.nil? || b.empty?
      a
    elsif a.kind_of?(Array) && b.kind_of?(Array)
      a + b
    else
      a = array_to_hash(a, default) if a.kind_of?(Array)
      b = array_to_hash(b, default) if b.kind_of?(Array)
      a.merge(b)
    end
  end

  # This takes the array form and converts into the equivalent hash form
  #
  # @example converting an order parameter
  #   # Vm.order(:name, :ip)
  #   array_to_hash([:name, :ip], "ASC") #=> {:name => "ASC", :ip => "ASC"}
  #
  # @example converting an includes parameter
  #   # Vm.includes([:ext_management_system, :host])
  #   array_to_hash([:ext_management_system, :host], {}) #=> {:ext_management_system => {}, :host =>{}}
  #
  # @param array [Array<Symbol>] array of names
  # @param default value to be associated with each object (i.e.: "ASC", {})
  # @return [Hash{Symbol => String, Hash}] Hash equivalent of the input array
  def array_to_hash(array, default = {})
    array.each_with_object({}) { |k, h| h[k] = default.dup }
  end

  def assign_arg(symbol, val)
    dup.tap do |r|
      r.options[symbol] = val
    end
  end
end
