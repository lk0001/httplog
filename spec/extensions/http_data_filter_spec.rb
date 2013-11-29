require "httplog/extensions/http_data_filter"

describe Extensions::HttpDataFilter do
  subject { described_class.new(filtered_keys: filtered_keys,
                                filtered_value: filtered_value) }

  let(:data) { "username=testuser&password=mypass&secret=mysecret" }
  let(:matching_data) { "username=testuser&password_confirmation=mypass&secret=mysecret" }
  let(:case_insensitive_data) { "userName=testuser&PasSword_Confirmation=mypass&Secret=mysecret" }
  let(:filtered_keys) { [:password, :secret] }
  let(:filtered_value) { "[FV]" }

  it "replaces exact keys' values with filtered_value" do
    subject.filter(data).should \
      eq("username=testuser&password=[FV]&secret=[FV]")
  end

  it "replaces matching keys' values with filtered_value" do
    subject.filter(matching_data).should \
      eq("username=testuser&password_confirmation=[FV]&secret=[FV]")
  end

  it "is not case sensitive" do
    subject.filter(case_insensitive_data).should \
      eq("userName=testuser&PasSword_Confirmation=[FV]&Secret=[FV]")
  end

  context "with default filtered_value" do
    subject { described_class.new(filtered_keys: filtered_keys) }

    it "replaces filtered keys with default filtered_value" do
      subject.filter(data).should \
        eq("username=testuser&password=[FILTERED]&secret=[FILTERED]")
    end
  end
end
