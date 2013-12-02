require "httplog/extensions/data_filters/empty_filter"

describe Extensions::DataFilters::EmptyFilter do
  subject { described_class.new(filtered_keys: filtered_keys,
                                filtered_value: filtered_value) }

  let(:http_data) { "username=testuser&password=mypass&secret=mysecret" }
  let(:json_data) { {username: "testuser", password: "mypass", secret: "mysecret"}.to_json }
  let(:filtered_keys) { [:password, :secret] }
  let(:filtered_value) { "[FV]" }

  describe "#suitable?" do
    context "http data" do
      it "is true" do
        subject.suitable?(http_data).should be_true
      end
    end

    context "json data" do
      it "is true" do
        subject.suitable?(json_data).should be_true
      end
    end
  end

  describe "#filter" do
    context "http data" do
      it "returns unchanged data" do
        subject.filter(http_data).should eq(http_data)
      end
    end

    context "json data" do
      it "returns unchanged data" do
        subject.filter(json_data).should eq(json_data)
      end
    end
  end
end
