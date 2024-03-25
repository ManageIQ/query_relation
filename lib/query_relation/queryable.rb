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
                   :order,
                   :reorder,
                   :first,
                   :last,
                   :take,
                   :to_a,
                   :pluck,
                   :count
  end
end
