require "httplog/extensions/replacers/full_replacer"
require "extensions/replacers/replaces_shared"

describe Extensions::Replacers::FullReplacer do
  subject { described_class.new(filtered_value: filtered_value) }

  let(:filtered_value) { "[FV]" }

  describe "#replace" do
    it_behaves_like "replaces", "test_string", "[FV]"
    it_behaves_like "replaces", "", "[FV]"
    it_behaves_like "replaces", [], "[FV]"
    it_behaves_like "replaces", {}, "[FV]"
    it_behaves_like "replaces", nil, "[FV]"
    it_behaves_like "replaces", Object.new, "[FV]"
  end
end
