require "httplog/extensions/data_filters/factory"

describe Extensions::DataFilters::Factory do
  subject { described_class.new(filtered_keys: filtered_keys,
                                filtered_value: filtered_value) }

  let(:http_data) { "username=testuser&password=mypass&secret=mysecret" }
  let(:json_data) { {username: "testuser", password: "mypass", secret: "mysecret"}.to_json }
  let(:filtered_keys) { [:password, :secret] }
  let(:filtered_value) { "[FV]" }

  describe "#filter" do
    context "http data" do
      it "returns filtered data" do
        subject.filter(http_data).should \
          eq("username=testuser&password=[FV]&secret=[FV]")
      end
    end

    context "json data" do
      it "returns filtered data" do
        subject.filter(json_data).should \
          eq({username: "testuser", password: "[FV]", secret: "[FV]"}.to_json)
      end
    end
  end
end
