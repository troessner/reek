shared_examples_for 'a variable detector' do
  context 'with no variables' do
    it "doesn't record a smell" do
      @detector.examine_context(@ctx)
      expect(@detector.smells_found.length).to eq(0)
    end
  end

  context 'with one variable encountered twice' do
    before :each do
      @ctx.send(@record_variable, :something)
      @ctx.send(@record_variable, :something)
      @detector.examine_context(@ctx)
    end

    it 'records only one smell' do
      expect(@detector.smells_found.length).to eq(1)
    end
    it 'mentions the variable name in the report' do
      expect(@detector).to have_smell([/something/])
    end
  end

  context 'with two variables' do
    before :each do
      @ctx.send(@record_variable, :something)
      @ctx.send(@record_variable, :something_else)
      @detector.examine_context(@ctx)
    end

    it 'records both smells' do
      expect(@detector.num_smells).to eq(2)
    end
    it 'mentions both variable names in the report' do
      expect(@detector).to have_smell([/something/])
      expect(@detector).to have_smell([/something_else/])
    end
  end
end
