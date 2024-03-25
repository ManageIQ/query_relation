describe QueryRelation do
  let(:model) { double("model") }
  let(:query) { described_class.new(model) { |*params| model.search(*params) } }
  let(:query_method) { :search }

  describe "#initialize" do
    it "supports block" do
      expect(model).not_to receive(:search)
      block = -> (mode, opts) { [1, 2, 3] if mode == :all && opts == {:includes => [:a]} }

      query = described_class.new(model,&block)
      expect(query.includes(:a).to_a).to eq([1, 2, 3])
    end

    it "defaults to klass.search" do
      expect(model).to receive(:search).with(:all, {:includes => [:a]}).and_return([1, 2, 3])

      query = described_class.new(model)
      expect(query.includes(:a).to_a).to eq([1, 2, 3])
    end
  end

  describe "#except" do
    it "removes an expression" do
      expect(model).to receive(query_method).with(:all, {:limit => 5}).and_return([1, 2, 3, 4, 5])
      expect(query.where(:a => 1).order(:a).limit(5).except(:where, :order).to_a).to eq([1, 2, 3, 4, 5])
    end
  end

  describe "#includes" do
    it "accepts a single table" do
      expect(model).to receive(query_method).with(:all, {:includes => [:a]})
      query.includes(:a).to_a
    end

    it "accepts multiple tables" do
      expect(model).to receive(query_method).with(:all, {:includes => [:a, :b]})
      query.includes(:a, :b).to_a
    end

    it "accepts a hash argument" do
      expect(model).to receive(query_method).with(:all, {:includes => {:a => {}}})
      query.includes(:a => {}).to_a
    end

    it "chains singles" do
      expect(model).to receive(query_method).with(:all, {:includes => [:a, :b]})
      query.includes(:a).includes(:b).to_a
    end

    it "chains arrays" do
      expect(model).to receive(query_method).with(:all, {:includes => [:a, :b, :c, :d]})
      query.includes(:a, :b).includes(:c, :d).to_a
    end

    it "chains hash array" do
      expect(model).to receive(query_method).with(:all, {:includes => {:a => {}, :b => {}}})
      query.includes(:a => {}).includes(:b).to_a
    end

    it "ignores nils" do
      expect(model).to receive(query_method).with(:all, {:includes => {:a => 5}})
      query.includes(nil).includes(:a => 5).includes(nil).to_a
    end

    it "chains array hash" do
      expect(model).to receive(query_method).with(:all, {:includes => {:a => {}, :b => {}}})
      query.includes(:a).includes(:b => {}).to_a
    end
  end

  describe "#limit" do
    it "limits" do
      expect(model).to receive(query_method).with(:all, {:limit => 5})
      query.limit(5).to_a
    end

    it "supports nils" do
      expect(model).to receive(query_method).with(:all, {})
      query.limit(5).limit(nil).to_a
    end
  end

  describe "#limit_value" do
    it { expect(query.limit_value).to eq(nil) }
    it { expect(query.limit(5).limit_value).to eq(5) }
  end

  # - [.] none

  describe "#offset" do
    it "offsets" do
      expect(model).to receive(query_method).with(:all, {:offset => 5})
      query.offset(5).to_a
    end

    it "supports nils" do
      expect(model).to receive(query_method).with(:all, {})
      query.offset(5).offset(nil).to_a
    end
  end

  describe "#offset_value" do
    it { expect(query.offset_value).to eq(nil) }
    it { expect(query.offset(5).offset_value).to eq(5) }
  end

  describe "#order" do
    it "orders" do
      expect(model).to receive(query_method).with(:all, {:order => [:a]})
      query.order(:a).to_a
    end

    it "accepts multiple fields" do
      expect(model).to receive(query_method).with(:all, {:order => [:a, :b]})
      query.order(:a, :b).to_a
    end

    it "chains singles" do
      expect(model).to receive(query_method).with(:all, {:order => [:a, :b]})
      query.order(:a).order(:b).to_a
    end

    it "chains arrays" do
      expect(model).to receive(query_method).with(:all, {:order => [:a, :b, :c, :d]})
      query.order(:a, :b).order(:c, :d).to_a
    end

    it "chains hash array" do
      expect(model).to receive(query_method).with(:all, {:order => {:a => "DESC", :b => "ASC"}})
      query.order(:a => "DESC").order(:b).to_a
    end

    it "chains hash array" do
      expect(model).to receive(query_method).with(:all, {:order => {:a => "ASC", :b => "DESC"}})
      query.order(:a).order(:b => "DESC").to_a
    end
  end

  describe "#order_values" do
    it { expect(query.order_values).to eq([]) }
    it { expect(query.order(:a).order(:b).order_values).to eq([:a, :b]) }
  end

  describe "#references" do
    it "chains array hash" do
      expect(model).to receive(query_method).with(:all, {:references => {:a => {}, :b => {}}})
      query.references(:a).references(:b => {}).to_a
    end
  end

  describe "#reorder" do
    it "reorders" do
      expect(model).to receive(query_method).with(:all, {:order => [:a]})
      query.reorder(:a).to_a
    end

    it "accepts multiple fields" do
      expect(model).to receive(query_method).with(:all, {:order => [:a, :b]})
      query.reorder(:a, :b).to_a
    end

    it "chains" do
      expect(model).to receive(query_method).with(:all, {:order => [:a, :b]})
      query.reorder(:c, :d).reorder(:a, :b).to_a
    end

    it "overrides order" do
      expect(model).to receive(query_method).with(:all, {:order => [:a, :b]})
      query.order(:c).order(:d).reorder(:a, :b).to_a
    end

    it "replaces order with nil" do
      expect(model).to receive(query_method).with(:all, {})
      query.order(:c).reorder(nil).to_a
    end
  end

  describe "#select" do
    it "supports single field" do
      expect(model).to receive(query_method).with(:all, {:select => [:a]})
      query.select(:a).to_a
    end

    it "accepts multiple fields" do
      expect(model).to receive(query_method).with(:all, {:select => [:a, :b]})
      query.select(:a, :b).to_a
    end

    it "chains fields" do
      expect(model).to receive(query_method).with(:all, {:select => [:c, :d, :a, :b]})
      query.select(:c, :d).select(:a, :b).to_a
    end

    it "ignores nils" do
      expect(model).to receive(query_method).with(:all, {:select => [:a, :b]})
      query.select(nil).select(:a, :b).select(nil).to_a
    end

    it "doesn't support hashes" do # TODO
      expect { query.select(:a => [:c]) }.to raise_error(ArgumentError)
    end
  end

  describe "#unscope" do
    it "removes an expression" do
      expect(model).to receive(query_method).with(:all, {:limit => 5})
      query.where(:a => 1).order(:a).limit(5).unscope(:where, :order).to_a
    end
  end

  describe "#where" do
    it "supports hash" do
      expect(model).to receive(query_method).with(:all, {:where => {:a => 5}})
      query.where(:a => 5).to_a
    end

    it "accepts multiple fields" do
      expect(model).to receive(query_method).with(:all, {:where => {:a => 5, :b => 6}})
      query.where(:a => 5, :b => 6).to_a
    end

    it "chains fields" do
      expect(model).to receive(query_method).with(:all, {:where => {:a => 5, :b => 6}})
      query.where(:a => 5).where(:b => 6).to_a
    end

    it "merges hashes" do
      expect(model).to receive(query_method).with(:all, {:where => {:a => [5, 55], :b => [6, 66]}})
      query.where(:a => 5, :b => 6).where(:a => 55, :b => 66).to_a
    end

    it "ignores nils" do
      expect(model).to receive(query_method).with(:all, {:where => {:a => 5}})
      query.where(nil).where(:a => 5).where(nil).to_a
    end

    it "supports string queries" do
      expect(model).to receive(query_method).with(:all, {:where => ["x = 5"]})
      query.where("x = 5").to_a
    end

    it "supports multiple arguments" do
      expect(model).to receive(query_method).with(:all, {:where => ["x = ?", 5]})
      query.where("x = ?", 5).to_a
    end

    it "supports array queries" do
      expect(model).to receive(query_method).with(:all, {:where => ["x = ?", 5]})
      query.where(["x = ?", 5]).to_a
    end

    it "does not merge hashes and strings" do
      expect { query.where("b = 5").where(:a => :c) }.to raise_error(ArgumentError)
    end

    it "does not merge hashes and strings" do
      expect { query.where(:a => :c).where("b = 5") }.to raise_error(ArgumentError)
    end
  end

  describe "#to_a" do
    it "calls model if not cached" do
      expect(model).to receive(query_method).with(:all, {:includes => [:a]}).and_return([1, 2, 3])
      expect(query.includes(:a).to_a).to eq([1, 2, 3])
    end

    it "uses cached results" do
      expect(model).to receive(query_method).with(:all, {:includes => [:a]}).and_return([1, 2, 3])
      expect(model).not_to receive(query_method).with(:all, {:includes => [:a]})
      my_query = query.includes(:a)
      my_query.to_a # executes/caches the results
      expect(my_query.to_a).to eq([1, 2, 3])
    end
  end

  describe "#all" do
    it "is a no-op" do
      expect(query.all).to equal(query)
    end
  end

  describe "#count" do
    it "accepts a single table" do
      expect(model).to receive(query_method).with(:all, {:includes => [:a]}).and_return([1, 2, 3, 4, 5])
      expect(query.includes(:a).count).to eq(5)
    end

    it "works around count(:all)" do
      expect(model).to receive(query_method).with(:all, {:includes => [:a]}).and_return([1, 2, 3, 4, 5])
      expect(query.includes(:a).count(:all)).to eq(5)
    end
  end

  describe "#first" do
    it "calls model if not cached" do
      expect(model).to receive(query_method).with(:first, {:includes => [:a]}).and_return(5)
      expect(query.includes(:a).first).to eq(5)
    end

    it "uses cached results" do
      expect(model).to receive(query_method).with(:all, {:includes => [:a]}).and_return([1, 2, 3])
      expect(model).not_to receive(query_method).with(:first, {:includes => [:a]})
      my_query = query.includes(:a)
      my_query.to_a # executes/caches the results
      expect(my_query.first).to eq(1)
    end
  end

  describe "#last" do
    it "calls model if not cached" do
      expect(model).to receive(query_method).with(:last, {:includes => [:a]}).and_return(5)
      expect(query.includes(:a).last).to eq(5)
    end

    it "uses cached results" do
      expect(model).to receive(query_method).with(:all, {:includes => [:a]}).and_return([1, 2, 3])
      expect(model).not_to receive(query_method).with(:last, {:includes => [:a]})
      my_query = query.includes(:a)
      my_query.to_a # executes/caches the results
      expect(my_query.last).to eq(3)
    end
  end

  describe "#length" do
    it "accepts a single table" do
      expect(model).to receive(query_method).with(:all, {:includes => [:a]}).and_return([1, 2, 3, 4, 5])
      expect(query.includes(:a).length).to eq(5)
    end
  end

  describe "#size" do
    it "accepts a single table" do
      expect(model).to receive(query_method).with(:all, {:includes => [:a]}).and_return([1, 2, 3, 4, 5])
      expect(query.includes(:a).size).to eq(5)
    end
  end

  describe "#take" do
    it "calls to_a" do
      results = double("results")
      expect(results).to receive(:take).and_return([1, 2])
      expect(model).to receive(query_method).with(:all, {:includes => [:a]}).and_return(results)

      expect(query.includes(:a).take).to eq([1, 2])
    end
  end

  describe "#any?" do
    it "returns true when results are returned" do
      expect(model).to receive(query_method).with(:all, {}).and_return([1, 2])
      expect(query.any?).to be true
    end

    it "returns false when no results are returned" do
      expect(model).to receive(query_method).with(:all, {}).and_return([])
      expect(query.any?).to be false
    end
  end

  describe "#blank?" do
    it "returns false when results are returned" do
      expect(model).to receive(query_method).with(:all, {}).and_return([1, 2])
      expect(query.blank?).to be false
    end

    it "returns true when no results are returned" do
      expect(model).to receive(query_method).with(:all, {}).and_return([])
      expect(query.blank?).to be true
    end
  end

  describe "#empty?" do
    it "returns false when results are returned" do
      expect(model).to receive(query_method).with(:all, {}).and_return([1, 2])
      expect(query.empty?).to be false
    end

    it "returns true when no results are returned" do
      expect(model).to receive(query_method).with(:all, {}).and_return([])
      expect(query.empty?).to be true
    end
  end

  describe "#present?" do
    it "returns false when results are returned" do
      expect(model).to receive(query_method).with(:all, {}).and_return([1, 2])
      expect(query.present?).to be true
    end

    it "returns true when no results are returned" do
      expect(model).to receive(query_method).with(:all, {}).and_return([])
      expect(query.present?).to be false
    end
  end

  describe "#presence" do
    it "returns array when results are returned" do
      results = [1, 2]
      expect(model).to receive(query_method).with(:all, {}).and_return(results)
      expect(query.presence).to be(results) # want same exact object
    end

    it "returns nil when no results are returned" do
      expect(model).to receive(query_method).with(:all, {}).and_return([])
      expect(query.presence).to be_nil
    end
  end

  describe "klass" do
    it "is the model" do
      expect(query.klass).to eq(model)
    end
  end

  describe "#instances_are_derived?" do
    it "is derived" do
      expect(query.instances_are_derived?).to be_truthy
    end
  end

  describe "#enumerable" do
    it "maps" do
      expect(model).to receive(query_method).with(:all, {:limit => 5}).and_return([1, 2, 3, 4, 5])
      result = query.limit(5).map { |row| row }
      expect(result).to eq([1, 2, 3, 4, 5])
    end
  end

  describe "#pluck" do
    it "passes select (single)" do
      expect(model).to receive(query_method).with(:all, {:select => [:a]}).and_return([{:a => 1}, {:a => 2}, {:a => 3}])
      result = query.pluck(:a)
      expect(result).to eq([1, 2, 3])
    end

    it "passes select (multi)" do
      expect(model).to receive(query_method).with(:all, {:select => [:a, :b]}).and_return([{:a => 1, :b => 11}, {:a => 2, :b => 22}, {:a => 3, :b => 33}])
      result = query.pluck(:a, :b)
      expect(result).to eq([[1, 11], [2, 22], [3, 33]])
    end

    it "passes where" do
      expect(model).to receive(query_method).with(:all, {:select => [:a], :where => {:a => 1}}).and_return([{:a => 1}])
      result = query.where(:a => 1).pluck(:a)
      expect(result).to eq([1])
    end

    it "supports no pluck parameters" do
      expect(model).to receive(query_method).with(:all, {}).and_return([{:a => 1, :b => 11}, {:a => 2, :b => 22}, {:a => 3, :b => 33}])
      result = query.select(:a, :b).pluck
      expect(result).to eq([[], [], []])
    end
  end
end
