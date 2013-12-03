require "httplog/extensions/data_filters/json_filter"

describe Extensions::DataFilters::JsonFilter do
  subject { described_class.new(filtered_keys: filtered_keys,
                                filtered_value: filtered_value) }

  let(:http_data) { "username=testuser&password=mypass&secret=mysecret" }
  let(:json_data) { {username: "testuser", password: "mypass", secret: "mysecret"}.to_json }
  let(:json_array_data) { [{username: "testuser", password: "mypass", secret: "mysecret"}].to_json }
  let(:matching_data) { {username: "testuser", password_confirmation: "mypass", secret: "mysecret"}.to_json }
  let(:case_insensitive_data) { {userName: "testuser", PasSword_Confirmation: "mypass", Secret: "mysecret"}.to_json }
  let(:nested_json_data) { {credentials: {username: "testuser", password: "mypass"}, secret: "mysecret"}.to_json }
  let(:nested_json_array_data) { {credentials: [{username: "testuser", password: "mypass"}], secret: "mysecret"}.to_json }
  let(:nested_json_data_2) { {secret_credentials: {username: "testuser", password: "mypass"}, secret: "mysecret"}.to_json }
  let(:filtered_keys) { [:password, :secret] }
  let(:filtered_value) { "[FV]" }

  describe "#suitable?" do
    context "http data" do
      it "is false" do
        subject.suitable?(http_data).should be_false
      end
    end

    context "json data" do
      it "is true" do
        subject.suitable?(json_data).should be_true
      end
    end
  end

  it "replaces exact keys' values with filtered_value" do
    subject.filter(json_data).should \
      eq({username: "testuser", password: "[FV]", secret: "[FV]"}.to_json)
  end

  it "replaces exact keys' values with filtered_value" do
    subject.filter(json_array_data).should \
      eq([{username: "testuser", password: "[FV]", secret: "[FV]"}].to_json)
  end

  it "replaces matching keys' values with filtered_value" do
    subject.filter(matching_data).should \
      eq({username: "testuser", password_confirmation: "[FV]", secret: "[FV]"}.to_json)
  end

  it "is not case sensitive" do
    subject.filter(case_insensitive_data).should \
      eq({userName: "testuser", PasSword_Confirmation: "[FV]", Secret: "[FV]"}.to_json)
  end

  it "replaces matching keys in nested json" do
    subject.filter(nested_json_data).should \
      eq({credentials: {username: "testuser", password: "[FV]"}, secret: "[FV]"}.to_json)
  end

  it "replaces matching keys in nested json" do
    subject.filter(nested_json_array_data).should \
      eq({credentials: [{username: "testuser", password: "[FV]"}], secret: "[FV]"}.to_json)
  end

  it "replaces whole nested hash if it matches" do
    subject.filter(nested_json_data_2).should \
      eq({secret_credentials: "[FV]", secret: "[FV]"}.to_json)
  end

  context "with default filtered_value" do
    subject { described_class.new(filtered_keys: filtered_keys) }

    it "replaces filtered keys with default filtered_value" do
      subject.filter(json_data).should \
        eq({username: "testuser", password: "[FILTERED]", secret: "[FILTERED]"}.to_json)
    end
  end
end
