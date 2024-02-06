require "../blastengine/lib/blastengine.rb"
require "json"

config = JSON.parse(File.read("./spec/config.json"))
RSpec.describe 'Mail test' do
  describe 'Basic' do
		before do
			Blastengine.initialize api_key: config["apiKey"], user_name: config["user_name"]
		end
		context 'Find log' do
			it "Find log" do
				params = {
					delivery_type: ["BULK"],
					status: ["EDIT", "SENT"]
				}
				ary = Blastengine::Log.find params
			end
		end
		context 'Find mail' do
			it "by find method" do
				params = {
					delivery_type: ["BULK"],
					status: ["EDIT", "SENT"],
					list_unsubscribe_mailto: "moongift",
				}
				ary = Blastengine::Mail.find params
				puts ary
			end
			it "by all method" do
				params = {
					delivery_type: ["BULK"],
					status: ["EDIT", "SENT"]
				}
				# ary = Blastengine::Mail.all params
			end
		end
	end
end
