module Blastengine
	class Base
		include Blastengine
		attr_accessor :delivery_id, :status, :delivery_time, :delivery_type, :open_count,
			:created_time, :updated_time, :hard_error_count, :soft_error_count, :drop_count, :sent_count, :total_count

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

		def report
			report = Blastengine::Report.new @delivery_id
			report.create
			report
		end
	end
end
