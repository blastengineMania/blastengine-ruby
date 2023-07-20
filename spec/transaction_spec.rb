require "../blastengine/lib/blastengine.rb"
require "json"

config = JSON.parse(File.read("./spec/config.json"))
RSpec.describe 'Transaction test' do
  describe 'Basic' do
		before do
			Blastengine.initialize api_key: config["apiKey"], user_name: config["user_name"]
		end
    context 'Send email' do
      it "Success to send text email" do
				transaction = Blastengine::Transaction.new
				transaction.from email: config["from"]["email"], name: config["from"]["name"]
				transaction.to << config["to"]
				transaction.insert_code = {
					name1: "name 1",
				}
				transaction.subject = "Test email"
				transaction.text_part = "This is a test email __name1__"
				begin
					delivery_id = transaction.send
					# Check delivery_id is integer
					expect(delivery_id).to be_an(Integer)
				rescue => e
					puts e
				end
			end
      it "Success to send email w/ attachment" do
				transaction = Blastengine::Transaction.new
				transaction.from email: config["from"]["email"], name: config["from"]["name"]
				transaction.to << config["to"]
				transaction.subject = "Test email w/ attachments"
				transaction.text_part = "This is a test email with attachments"
				transaction.attachments << "README.md"
				transaction.attachments << "./spec/test.jpg"
				begin
					delivery_id = transaction.send
					# Check delivery_id is integer
					expect(delivery_id).to be_an(Integer)
				rescue => e
					puts e
				end
			end
		end
	end
end