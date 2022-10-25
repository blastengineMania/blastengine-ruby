require "../blastengine/lib/blastengine.rb"
require "json"

config = JSON.parse(File.read("./spec/config.json"))
RSpec.describe 'Bulk test' do
  describe 'Basic' do
		before do
			Blastengine.initialize api_key: config["apiKey"], user_name: config["user_name"]
		end
		context 'Get report' do
			it "Get report" do
				transaction = Blastengine::Transaction.new
				transaction.delivery_id = 681
				report = transaction.report
				while !report.finish?
					expect(report.percentage).to be < 100
				end
				expect(report.percentage).to eq 100
				puts report.get
			end
		end
	end
end