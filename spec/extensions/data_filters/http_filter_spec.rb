require "httplog/extensions/data_filters/http_filter"

describe Extensions::DataFilters::HttpFilter do
  subject { described_class.new(filtered_keys: filtered_keys,
                                filtered_value: filtered_value) }

  let(:http_data) { "username=testuser&password=mypass&secret=mysecret" }
  let(:json_data) { {username: "testuser", password: "mypass", secret: "mysecret"}.to_json }
  let(:matching_data) { "username=testuser&password_confirmation=mypass&secret=mysecret" }
  let(:case_insensitive_data) { "userName=testuser&PasSword_Confirmation=mypass&Secret=mysecret" }
  let(:filtered_keys) { [:password, :secret] }
  let(:filtered_value) { "[FV]" }

  describe "#suitable?" do
    context "http data" do
      it "is true" do
        subject.suitable?(http_data).should be_true
      end
    end

    context "json data" do
      it "is false" do
        subject.suitable?(json_data).should be_false
      end
    end
  end

  it "replaces exact keys' values with filtered_value" do
    subject.filter(http_data).should \
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
      subject.filter(http_data).should \
        eq("username=testuser&password=[FILTERED]&secret=[FILTERED]")
    end
  end
end
