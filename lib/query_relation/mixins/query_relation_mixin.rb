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
           :limit, :offset, :take,
           :except, :unscope,
           :order, :reorder, :to => :all
end
