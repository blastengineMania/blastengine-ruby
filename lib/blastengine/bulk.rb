require "time"

module Blastengine
	class Bulk
		include Blastengine
		attr_accessor :subject, :text_part, :encode, :html_part, :attachments, :delivery_id
		def initialize
			@to = []
			@attachments = []
			@encode = "UTF-8"
		end

		#
		# 送信主の追加
		#
		def from(email, name = "")
			@_from = {email: email, name: name}
		end

		#
		# バルクメールの登録
		#
		def register
			# APIリクエスト用のパス
			path = "/deliveries/bulk/begin"
			data = {
				from: @_from,
				subject: @subject,
				encode: @encode,
				text_part: @text_part,
			}
			# HTMLパートがある場合は追加
			data[:html_part] = @html_part unless @html_part.nil?
			# API実行
			res = @@client.post path, data, @attachments
			@delivery_id = res["delivery_id"]
			return res["delivery_id"]
		end

		#
		# 受信者の追加
		#
		def add(email, params = {})
			@to << {
				email: email,
				insert_code: params.map{|key, value| {
					key: "__#{key}__",
					value: value
				}}
			}
		end

		#
		# バルクメールの更新
		#
		def update
			# APIリクエスト用のパス
			path = "/deliveries/bulk/update/#{@delivery_id}"
			data = {
				to: @to
			}
			# subject, text_part, from, html_partはあれば追加
			data[:subject] = @subject unless @subject.nil?
			data[:from] = @_from unless @_from.nil?
			data[:text_part] = @text_part unless @text_part.nil?
			data[:html_part] = @html_part unless @html_part.nil?
			# API実行
			res = @@client.put path, data
			return res["delivery_id"]
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

		#
		# バルクメールの送信
		#
		def send(date = nil)
			# APIリクエスト用のパス
			path = date ? 
				"/deliveries/bulk/commit/#{@delivery_id}" :
				"/deliveries/bulk/commit/#{@delivery_id}/immediate"
			# APIリクエスト用のデータ
			data = date ? {reservation_time: date.iso8601} : {}
			# API実行
			res = @@client.patch path, data
			# エラーがあったら例外を投げるので、この場合は通常終了
			return res["delivery_id"]
		end
	end
end
