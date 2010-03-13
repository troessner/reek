shared_examples_for 'a variable detector' do
  context 'with no variables' do
    it "doesn't record a smell" do
      @detector.examine_context(@ctx)
      @detector.smells_found.length.should == 0
    end
  end

  context 'with one variable encountered twice' do
    before :each do
      @ctx.send(@record_variable, :something)
      @ctx.send(@record_variable, :something)
      @detector.examine_context(@ctx)
    end

    it 'records only one smell' do
      @detector.smells_found.length.should == 1
    end
    it 'mentions the variable name in the report' do
      @detector.should have_smell([/something/])
    end
  end

  context 'with two variables' do
    before :each do
      @ctx.send(@record_variable, :something)
      @ctx.send(@record_variable, :something_else)
      @detector.examine_context(@ctx)
    end

    it 'records both smells' do
      @detector.num_smells.should == 2
    end
    it 'mentions both variable names in the report' do
      @detector.should have_smell([/something/])
      @detector.should have_smell([/something_else/])
    end
  end
end
