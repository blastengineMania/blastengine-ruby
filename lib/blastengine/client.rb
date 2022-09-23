require "base64"

module Blastengine
	DOMAIN = "app.engn.jp"
	BASE_PATH = "/api/v1"
	@@api_key = nil
	@@user_name = nil
	@@last_error = nil
	@@client = nil

	class Client
		include Blastengine
		def generate_token
			str = "#{@@user_id}#{@@api_key}";
			token = Base64.urlsafe_encode64 Digest::SHA256.hexdigest(str).downcase
		end
	end

	def Blastengine.initialize(api_key, user_name)
		@@api_key = api_key
		@@user_name = user_name
		@@client = Client.new
	end
end