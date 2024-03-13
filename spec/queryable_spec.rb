describe QueryRelation::Queryable do
  let(:model) do
    Class.new do
      extend QueryRelation::Queryable

      def self.search(mode, _options = {})
        records = [{:a => 1, :b => 11}, {:a => 2, :b => 22}, {:a => 3, :b => 33}]
        case mode
        when :all   then records
        when :first then records.first
        when :last  then records.last
        end
      end
      private_class_method :search
    end
  end

  it ".all" do
    relation = model.all
    expect(relation).to be_kind_of(QueryRelation)
    expect(relation.to_a).to eq([{:a => 1, :b => 11}, {:a => 2, :b => 22}, {:a => 3, :b => 33}])
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
    expect(model.first).to eq({:a => 1, :b => 11})
  end

  it ".last" do
    expect(model.last).to eq({:a => 3, :b => 33})
  end

  it ".take" do
    expect(model.take(2)).to eq([{:a => 1, :b => 11}, {:a => 2, :b => 22}])
  end

  it ".count" do
    expect(model.count).to eq(3)
  end
end
