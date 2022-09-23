require "../blastengine/lib/blastengine.rb"

RSpec.describe 'Client test' do
  describe 'Basic' do
    context 'initialize' do
      it "Initialize client" do
        client = Blastengine.initialize api_key: "ABCDEFG", user_name: "blastengine"
        expect(client).to be_truthy
        expect(client.generate_token).to eq("MWYwZWVlOGZjMTIwNjc2ZmM1ODk0OTJmMTUyMjhlZmIzZDAyMWYwYWVlNGIwMDZlZmIyN2M3ZWUzM2Y1ZDZjOQ==")
      end
    end
  end
end