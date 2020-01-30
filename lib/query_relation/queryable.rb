require 'forwardable'

class QueryRelation
  module Queryable
    extend Forwardable

    def all(*args)
      QueryRelation.new(self, *args)
    end

    def_delegators :all,
                   :select,
                   :where,
                   :limit,
                   :offset,
                   :except,
                   :unscope,
                   :includes,
                   :references,
                   :preload,
                   :left_join,
                   :left_outer_join,
                   :order,
                   :reorder,
                   :first,
                   :last,
                   :take,
                   :count
  end
end
