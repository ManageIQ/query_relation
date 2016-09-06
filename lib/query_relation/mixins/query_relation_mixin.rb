require 'active_support'
require 'active_support/core_ext'

module QueryRelationMixin
  extend ActiveSupport::Concern

  def all(*args)
    QueryRelation.new(self, *args)
  end

  # TODO: ids, second, third, fourth, fifth, not, only, reverse_order

  delegate :first, :last,
           :select, :where,
           :limit, :offset,
           :size, :length, :take, :each, :empty?, :presence,
           :except, :unscope,
           :includes, :references,
           :find, :count,
           :order, :reorder, :to => :all
end
