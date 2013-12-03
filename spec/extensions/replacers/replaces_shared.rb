shared_examples_for "replaces" do |argument, result|
  it "replaces #{argument} with #{result}" do
    subject.replace(argument).should eq(result)
  end
end
