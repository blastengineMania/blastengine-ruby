require "../blastengine/lib/blastengine.rb"
require "json"

config = JSON.parse(File.read("./spec/config.json"))
RSpec.describe 'Bulk test' do
  describe 'Basic' do
		before do
			Blastengine.initialize api_key: config["apiKey"], user_name: config["user_name"]
		end
    context 'Get email' do
      it "Get email" do
				transaction = Blastengine::Transaction.new
				transaction.delivery_id = 543
				transaction.get
				expect(transaction.status).to eq("SENT")
			end
      it "Delete email" do
				begin
					transaction = Blastengine::Transaction.new
					transaction.delivery_id = 541
					# transaction.delete
				rescue => e
					puts e
				end
			end
		end
	end
end