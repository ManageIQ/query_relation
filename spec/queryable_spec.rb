describe QueryRelation::Queryable do
  let(:model) do
    Class.new do
      extend QueryRelation::Queryable

      def self.search(mode, _options = {})
        records = [1, 2, 3]
        case mode
        when :all   then records
        when :first then records.first
        when :last  then records.last
        end
      end
    end
  end

  it ".all" do
    relation = model.all
    expect(relation).to be_kind_of(QueryRelation)
    expect(relation.to_a).to eq([1, 2, 3])
  end

  it ".select" do
    relation = model.select(:a)
    expect(relation).to be_kind_of(QueryRelation)
    expect(relation.options).to eq(:select => [:a])
  end

  it ".where" do
    relation = model.where(:a => 1)
    expect(relation).to be_kind_of(QueryRelation)
    expect(relation.options).to eq(:where => {:a => 1})
  end

  it ".limit" do
    relation = model.limit(2)
    expect(relation).to be_kind_of(QueryRelation)
    expect(relation.options).to eq(:limit => 2)
  end

  it ".offset" do
    relation = model.offset(2)
    expect(relation).to be_kind_of(QueryRelation)
    expect(relation.options).to eq(:offset => 2)
  end

  it ".except" do
    relation = model.where(:a => 1).limit(2).except(:where)
    expect(relation).to be_kind_of(QueryRelation)
    expect(relation.options).to eq(:limit => 2)
  end

  it ".unscope" do
    relation = model.where(:a => 1).limit(2).unscope(:where)
    expect(relation).to be_kind_of(QueryRelation)
    expect(relation.options).to eq(:limit => 2, :where => nil)
  end

  it ".includes" do
    relation = model.includes(:a)
    expect(relation).to be_kind_of(QueryRelation)
    expect(relation.options).to eq(:includes => [:a])
  end

  it ".references" do
    relation = model.references(:a)
    expect(relation).to be_kind_of(QueryRelation)
    expect(relation.options).to eq(:references => [:a])
  end

  it ".order" do
    relation = model.order(:a)
    expect(relation).to be_kind_of(QueryRelation)
    expect(relation.options).to eq(:order => [:a])
  end

  it ".reorder" do
    relation = model.order(:a).reorder(:b)
    expect(relation).to be_kind_of(QueryRelation)
    expect(relation.options).to eq(:order => [:b])
  end

  it ".first" do
    expect(model.first).to eq(1)
  end

  it ".last" do
    expect(model.last).to eq(3)
  end

  it ".take" do
    expect(model.take(2)).to eq([1, 2])
  end

  it ".count" do
    expect(model.count).to eq(3)
  end
end
