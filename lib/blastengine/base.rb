require "date"

module Blastengine
	class Base
		include Blastengine
		attr_accessor :delivery_id, :status, :delivery_time, :delivery_type, :open_count,
			:created_time, :updated_time, :hard_error_count, :soft_error_count, :drop_count, :sent_count, :total_count

		def self.client
			base = Base.new
			base.client
		end

		def client
			@@client
		end

		def sets(params)
			params.each do |key, value|
				self.set(key, value)
			end
		end

		def set(key, value)
			case key
			when "delivery_id"
				@delivery_id = value
			when "status"
				@status = value
			when "delivery_time"
				@delivery_time = Date.parse(value) if value != nil
			when "delivery_type"
				@delivery_type = value
			when "open_count"
				@open_count = value
			when "created_time"
				@created_time = Date.parse(value) if value != nil
			when "updated_time"
				@updated_time = Date.parse(value) if value != nil
			when "hard_error_count"
				@hard_error_count = value
			when "soft_error_count"
				@soft_error_count = value
			when "drop_count"
				@drop_count = value
			when "sent_count"
				@sent_count = value
			when "total_count"
				@total_count = value
			when "from"
				@_from = value
			when "reservation_time"
				@reservation_time = Date.parse(value) if value != nil
			when "maillog_id"
				@maillog_id = value
			when "email"
				@to = value
			when "last_response_code"
				@last_response_code = value
			when "last_response_message"
				@last_response_message = value
			when "subject"
				@subject = value
			when "open_time"
				@open_time = Date.parse(value) if value != nil
			end
			self
		end
	
		def get
			# APIリクエスト用のパス
			path = "/deliveries/#{@delivery_id}"
			res = @@client.get path
			# エラーがあったら例外を投げるので、この場合は通常終了
			@delivery_type = res["delivery_type"]
			@delivery_id = res["delivery_id"]
			@status = res["status"]
			@total_count = res["total_count"]
			@sent_count = res["sent_count"]
			@drop_count = res["drop_count"]
			@hard_error_count = res["hard_error_count"]
			@soft_error_count = res["soft_error_count"]
			@open_count = res["open_count"]
			@delivery_time = res["delivery_time"]
			@reservation_time = res["reservation_time"]
			@created_time = res["created_time"]
			@updated_time = res["updated_time"]
			@_from = res["from"]
			@subject = res["subject"]
			@text_part = res["text_part"]
			@html_part = res["html_part"]
		end

		#
		# バルクメールの削除
		#
		def delete
			path = "/deliveries/#{@delivery_id}"
			# API実行
			res = @@client.delete path
			return res["delivery_id"]
		end
	end
end
