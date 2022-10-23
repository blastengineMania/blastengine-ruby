require "../blastengine/lib/blastengine.rb"
require "json"

config = JSON.parse(File.read("./spec/config.json"))
RSpec.describe 'Usage test' do
  describe 'Basic' do
		before do
			Blastengine.initialize api_key: config["apiKey"], user_name: config["user_name"]
		end
    context 'Get usage' do
      it "Get all usage" do
				usages = Blastengine::Usage.all
				puts usages.first.month
				puts usages.first.remaining
				usages = Blastengine::Usage.all 3
				puts usages.last.month
				puts usages.last.remaining
			end

			it "Get usage by month" do
				usage = Blastengine::Usage.get "202210"
				puts usage.month
				usage = Blastengine::Usage.get
				puts usage.month
			end
		end
	end
end