require "../blastengine/lib/blastengine.rb"
require "json"

config = JSON.parse(File.read("./spec/config.json"))
RSpec.describe 'Bulk test' do
  describe 'Basic' do
		before do
			Blastengine.initialize api_key: config["apiKey"], user_name: config["user_name"]
		end
    context 'Send email' do
      it "Success to send text email" do
				bulk = Blastengine::Bulk.new
				bulk.from email: config["from"]["email"], name: config["from"]["name"]
				bulk.subject = "Test bulk email"
				bulk.text_part = "This is a test email to __name__"
				begin
					delivery_id = bulk.register
					expect(delivery_id).to be_an(Integer)
					bulk.add "atsushi+1@moongift.co.jp", {name: "Atsushi 1"}
					bulk.add "atsushi+2@moongift.co.jp", {name: "Atsushi 2"}
					bulk.update
					bulk.send
				rescue => e
					puts e
				end
			end
      it "Success to send text email w/ time" do
				bulk = Blastengine::Bulk.new
				bulk.from email: config["from"]["email"], name: config["from"]["name"]
				bulk.subject = "Test bulk email, 2 minute later"
				bulk.text_part = "This is a test email to __name__"
				begin
					delivery_id = bulk.register
					expect(delivery_id).to be_an(Integer)
					bulk.add "atsushi+1@moongift.co.jp", {name: "Atsushi 1"}
					bulk.add "atsushi+2@moongift.co.jp", {name: "Atsushi 2"}
					bulk.update
					# 2 minutes later
					bulk.send Time.now + 120
				rescue => e
					puts e
				end
			end
		end
	end
end