require 'date'

module Blastengine
	class Transaction < Base
		include Blastengine
		attr_accessor :to, :cc, :bcc, :subject, :text_part, :encode, :html_part, :attachments, :insert_code
		def initialize
			@to = ""
			@cc = []
			@bcc = []
			@attachments = []
			@encode = "UTF-8"
			@insert_code = {}
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
				to: @to,
				cc: @cc,
				bcc: @bcc,
				subject: @subject,
				encode: @encode,
				text_part: @text_part,
			}
			# HTMLパートがある場合は追加
			data[:html_part] = @html_part unless @html_part.nil?
			if @insert_code != nil
				data[:insert_code] = @insert_code.map do |key, value|
					{
						key: "__#{key}__",
						value: value
					}
				end
			end
			# API実行
			res = @@client.post path, data, @attachments
			# エラーがあったら例外を投げるので、この場合は通常終了
			@delivery_id = res["delivery_id"]
			return res["delivery_id"]
		end
	end
end
