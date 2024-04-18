require "../blastengine/lib/blastengine.rb"
require "json"
require "date"

config = JSON.parse(File.read("./spec/config.json"))
RSpec.describe 'Mail test' do
  describe 'Basic' do
		before :all do
			Blastengine.initialize api_key: config["apiKey"], user_name: config["user_name"]
		end
		context 'Find emails' do
			it "Find emails" do
				params = {
					"delivery_start": Time.now - 60 * 60 * 24 * 30,
					"delivery_end": Time.now,
					"delivery_type": ["BULK"],
					"status": ["EDIT", "SENT"]
				}
				ary = Blastengine::Mail.find params
			end
		end

		context 'Send mail' do
			it "Send transaction mail" do
				mail = Blastengine::Mail.new
				mail.from email: config["from"]["email"], name: config["from"]["name"]
				mail.addTo email: config["to"], insert_code: { name1: "name 1" }
				mail.subject = "Test email"
				mail.text_part = "This is a test email __name1__"
				mail.html_part = "<html><body>This is a test email __name1__</body></html>"
				bol = mail.send
				expect(bol).to be true
				delivery_id = mail.delivery_id
				expect(delivery_id).to be_an(Integer)
			end

			it "Send transaction mail" do
				mail = Blastengine::Mail.new
				mail.from email: config["from"]["email"], name: config["from"]["name"]
				mail.addTo email: config["to"], insert_code: { name1: "name 1", hash: "aaaa" }
				mail.subject = "Test unsubscribe transaction email"
				mail.text_part = "This is a test email __name1__"
				mail.html_part = "<html><body>This is a test email __name1__</body></html>"
				mail.unsubscribe email: "unsubscribe+__hash__@moongift.co.jp"
				bol = mail.send
				expect(bol).to be true
				delivery_id = mail.delivery_id
				expect(delivery_id).to be_an(Integer)
			end

			it "Send transaction mail w/ attachment" do
				mail = Blastengine::Mail.new
				mail.from email: config["from"]["email"], name: config["from"]["name"]
				mail.addTo email: config["to"], insert_code: { name1: "name 1" }
				mail.subject = "Test email"
				mail.text_part = "This is a test email __name1__"
				mail.html_part = "<html><body>This is a test email __name1__</body></html>"
				mail.attachments << "README.md"
				bol = mail.send
				expect(bol).to be true
				delivery_id = mail.delivery_id
				expect(delivery_id).to be_an(Integer)
			end

			it "Send bulk mail" do
				mail = Blastengine::Mail.new
				mail.from email: config["from"]["email"], name: config["from"]["name"]
				mail.addTo email: "user1@moongift.co.jp", insert_code: { name1: "name 1" }
				mail.addTo email: "user2@moongift.co.jp", insert_code: { name1: "name 2" }
				mail.subject = "Test email"
				mail.text_part = "This is a test email __name1__"
				mail.html_part = "<html><body>This is a test email __name1__</body></html>"
				mail.attachments << "README.md"
				bol = mail.send
				expect(bol).to be true
				delivery_id = mail.delivery_id
				expect(delivery_id).to be_an(Integer)
			end

			it "Send bulk mail with unsubscribe" do
				mail = Blastengine::Mail.new
				mail.from email: config["from"]["email"], name: config["from"]["name"]
				mail.addTo email: "user1@moongift.co.jp", insert_code: { name1: "name 1", hash: "aaaa" }
				mail.addTo email: "user2@moongift.co.jp", insert_code: { name1: "name 2", hash: "bbbb" }
				mail.subject = "Test unsubscribe email by mail class"
				mail.text_part = "This is a test email __name1__"
				mail.html_part = "<html><body>This is a test email __name1__</body></html>"
				mail.unsubscribe email: "info+__hash__@moongift.co.jp"
				mail.attachments << "README.md"
				bol = mail.send
				expect(bol).to be true
				delivery_id = mail.delivery_id
				expect(delivery_id).to be_an(Integer)
			end

			it "Send bulk mail" do
				mail = Blastengine::Mail.new
				mail.from email: config["from"]["email"], name: config["from"]["name"]
				60.times do |i|
					mail.addTo email: "bulk#{i}@moongift.co.jp", insert_code: { name1: "name #{i}" }
				end
				mail.subject = "Test email"
				mail.text_part = "This is a test email __name1__"
				mail.html_part = "<html><body>This is a test email __name1__</body></html>"
				mail.attachments << "README.md"
				bol = mail.send
				expect(bol).to be true
				delivery_id = mail.delivery_id
				expect(delivery_id).to be_an(Integer)
			end

			it "Cancel bulk mail" do
				mail = Blastengine::Mail.new
				mail.from email: config["from"]["email"], name: config["from"]["name"]
				mail.addTo email: "user@moongift.co.jp", insert_code: { name1: "name 2" }
				mail.subject = "Test email"
				mail.text_part = "This is a test email __name1__"
				mail.html_part = "<html><body>This is a test email __name1__</body></html>"
				# 30 sec later now
				bol = mail.send(DateTime.now + Rational(30, 86400))
				expect(bol).to be true
				delivery_id = mail.delivery_id
				expect(delivery_id).to be_an(Integer)
				mail.get
				expect(mail.status).to eq "RESERVE"
				delivery_id = mail.cancel
				expect(delivery_id).to be_an(Integer)
				mail.get
				expect(mail.status).to eq "EDIT"
			end

		end
	end
end
