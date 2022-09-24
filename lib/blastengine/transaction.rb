module Blastengine
	class Transaction
		include Blastengine
		attr_accessor :to, :subject, :text_part, :encode, :html_part, :attachments
		def initialize
			@to = []
			@attachments = []
			@encode = "UTF-8"
		end

		#
		# 送信主の追加
		#
		def from(email:, name: "")
			@_from = {email: email, name: name}
		end

		#
		# トランザクションメールの送信
		#
		def send
			# APIリクエスト用のパス
			path = "/deliveries/transaction"
			# APIリクエスト用のデータ
			data = {
				from: @_from,
				to: @to.join(","),
				subject: @subject,
				encode: @encode,
				text_part: @text_part,
			}
			# HTMLパートがある場合は追加
			data[:html_part] = @html_part unless @html_part.nil?
			# API実行
			res = @@client.post path, data, @attachments
			# エラーがあったら例外を投げるので、この場合は通常終了
			return res["delivery_id"]
		end
	end
end
