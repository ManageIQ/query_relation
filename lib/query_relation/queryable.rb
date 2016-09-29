require 'forwardable'

class QueryRelation
  module Queryable
    extend Forwardable

    def all(*args)
      QueryRelation.new(self, *args) { |*params| search(*params) }
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
                   :count
  end
end
