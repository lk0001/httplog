require "httplog/extensions/replacers/half_replacer"
require "extensions/replacers/replaces_shared"

describe Extensions::Replacers::HalfReplacer do
  subject { described_class.new(filtered_value: filtered_value) }

  let(:filtered_value) { "*" }

  describe "#replace" do
    it_behaves_like "replaces", "test_string", "******tring"
    it_behaves_like "replaces", "08 chars", "****hars"
    it_behaves_like "replaces", "09 chars|", "*****ars|"
    it_behaves_like "replaces", "", ""
    it_behaves_like "replaces", [1, 2, 3], "*****, 3]"
  end
end
