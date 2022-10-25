module Blastengine
	class Email < Base
		include Blastengine
		attr_accessor :delivery_id, :address, :insert_code, :email_id, :created_time, :updated_time
		def initialize delivery_id
			@delivery_id = delivery_id
			@insert_code = {}
		end

		def get
			# APIリクエスト用のパス
			path = "/deliveries/-/emails/#{@email_id}"
			# API実行
			res = @@client.get path
			@email_id = res["email_id"]
			res["insert_code"].each do |params|
				@insert_code[params["key"].gsub("__", "")] = params["value"]
			end
			@address = res["email"]
			@created_time = Time.parse(res["created_time"])
			@updated_time = Time.parse(res["updated_time"])
			return res["email_id"]
		end

		def save
			# APIリクエスト用のパス
			if @email_id.nil?
				return create
			else
				return update
			end
		end

		def create
			path = "/deliveries/#{@delivery_id}/emails"
			params = {
				email: @address,
				insert_code: @insert_code.map{|key, value| {
					key: "__#{key}__",
					value: value
				}}
			}
			# API実行
			res = @@client.post path, params
			@email_id = res["email_id"]
			return res["email_id"]
		end

		def update
			path = "/deliveries/-/emails/#{@email_id}"
			params = {
				email: @address,
				insert_code: @insert_code.map{|key, value| {
					key: "__#{key}__",
					value: value
				}}
			}
			# API実行
			res = @@client.put path, params
			@email_id = res["email_id"]
			return res["email_id"]
		end

		def delete
			path = "/deliveries/-/emails/#{@email_id}"
			# API実行
			res = @@client.delete path
			return res["email_id"]
		end
	end
end