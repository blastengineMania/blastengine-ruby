require "../blastengine/lib/blastengine.rb"
require "json"

config = JSON.parse(File.read("./spec/config.json"))
RSpec.describe 'Bulk test' do
  describe 'Basic' do
		before do
			Blastengine.initialize api_key: config["apiKey"], user_name: config["user_name"]
		end
		context 'Manage email' do
			it "Add email address" do
				bulk = Blastengine::Bulk.new
				bulk.from email: config["from"]["email"], name: config["from"]["name"]
				bulk.subject = "Test bulk email"
				bulk.text_part = "This is a test email to __name__"
				begin
					bulk.register
					address = "user1@example.jp"
					email = bulk.email
					email.address = address
					email.insert_code = {
						"name" => "User1"
					}
					email_id = email.save
					# 取り直し
					email = bulk.email
					email.email_id = email_id
					email.get
					expect(email.address).to eq(address)
					new_address = "user2@example.jp"
					email.address = new_address
					email.save
					email.get
					expect(email.address).to eq(new_address)
					email.delete
				rescue => e
					puts e
				end
				sleep 2
				bulk.delete
			end
		end
	end
end
