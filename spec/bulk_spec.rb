require "../blastengine/lib/blastengine.rb"
require "json"

config = JSON.parse(File.read("./spec/config.json"))
RSpec.describe 'Bulk test' do
  describe 'Basic' do
		before do
			Blastengine.initialize api_key: config["apiKey"], user_name: config["user_name"]
		end
=begin
    context 'Send email' do
			it "Delete ignore email" do
				(400..600).each do |i|
					begin
						transaction = Blastengine::Transaction.new
						transaction.delivery_id = i
						transaction.get
						puts transaction.status
						if transaction.status == "EDIT"
							transaction.delete
							puts "Deleted #{i}"
						end
					rescue => e
					end
				end
			end
		end
=end
		context 'Send email' do
			it "Success to send text email" do
				bulk = Blastengine::Bulk.new
				bulk.from email: config["from"]["email"], name: config["from"]["name"]
				bulk.subject = "Test bulk email"
				bulk.text_part = "This is a test email to __name__"
				bulk.html_part = "<p>This is a test email to __name__</p>"
				begin
					delivery_id = bulk.register
					expect(delivery_id).to be_an(Integer)
					bulk.addTo "atsushi+1@moongift.co.jp", {name: "Atsushi 1"}
					bulk.addTo "atsushi+2@moongift.co.jp", {name: "Atsushi 2"}
					bulk.update
					bulk.send
					# bulk.delete
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
					bulk.addTo "atsushi+1@moongift.co.jp", {name: "Atsushi 1"}
					bulk.addTo "atsushi+2@moongift.co.jp", {name: "Atsushi 2"}
					bulk.update
					# 2 minutes later
					bulk.send Time.now + 120
					sleep 2
					bulk.get
					expect(bulk.status).to eq("RESERVE")
					bulk.cancel
					sleep 2
					bulk.get
					expect(bulk.status).to eq("EDIT")
				rescue => e
					puts e
				end
				sleep 2
				bulk.delete
			end

      it "Success to send text email w/ unsubscribe" do
				bulk = Blastengine::Bulk.new
				bulk.from email: config["from"]["email"], name: config["from"]["name"]
				bulk.subject = "Test bulk unsubscribe email"
				bulk.text_part = "This is a test email to __name__"
				begin
					delivery_id = bulk.register
					expect(delivery_id).to be_an(Integer)
					bulk.addTo "atsushi+1@moongift.co.jp", {name: "Atsushi 1", hash: "aaaa"}
					bulk.addTo "atsushi+2@moongift.co.jp", {name: "Atsushi 2", hash: "bbbb"}
					bulk.unsubscribe url: "https://example.com/unsubscribe/__hash__"
					bulk.update
					# 2 minutes later
					bulk.send
					sleep 5
					bulk.get
					expect(bulk.status).to eq("SENDING")
				rescue => e
					puts e
				end
				sleep 2
				bulk.delete
			end

      it "Import email addresses from CSV file" do
				bulk = Blastengine::Bulk.new
				bulk.from email: config["from"]["email"], name: config["from"]["name"]
				bulk.subject = "Test bulk email, 2 minute later"
				bulk.text_part = "This is a test email to __name__"
				delivery_id = bulk.register
				begin
					expect(delivery_id).to be_an(Integer)
					job = bulk.import "./spec/example.csv"
					while !job.finish?
					end
					expect(job.percentage).to eq(100)
					puts job.error_message
				rescue => e
					puts e
				end
				sleep 2
				bulk.delete
			end
		end
	end
end