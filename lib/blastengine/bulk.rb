require "time"
require "tempfile"
require "csv"

module Blastengine
	class Bulk < Base
		include Blastengine
		attr_accessor :subject, :text_part, :encode, :html_part, :attachments, :delivery_id, :job
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
		def addTo(email, params = {})
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
			if @to.size > 50
				return self.csv_update
			else
				return self.normal_update
			end
		end

		def normal_update
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

		def csv_update
			f = Tempfile.create(['blastengine', '.csv'])
			f.close
			csv = CSV.open(f.path, "w")
			# ヘッダーの作成
			headers = ["email"]
			@to.each do |to|
				to[:insert_code].each do |insert_code|
					headers << insert_code[:key] if headers.index(insert_code[:key]) == nil
				end
			end
			csv.puts headers
			@to.each do |to|
				lines = [to[:email]]
				headers.each do |header|
					next if header == "email"
					insert_code = to[:insert_code].find{|insert_code| insert_code[:key] == header}
					lines << insert_code[:value] if insert_code != nil
				end
				csv.puts lines
			end
			csv.close
			job = self.import f.path
			while !job.finish?
				sleep 1
			end
			File.unlink f.path
			@delivery_id
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
			@delivery_id = res["delivery_id"]
			return res["delivery_id"]
		end

		def cancel
			# APIリクエスト用のパス
			path = "/deliveries/#{@delivery_id}/cancel"
			# API実行
			res = @@client.patch path, {}
			return res["delivery_id"]
		end

		def import(file, ignore_errors = false)
			# APIリクエスト用のパス
			path = "/deliveries/#{@delivery_id}/emails/import"
			# API実行
			res = @@client.post path, {ignore_errors: ignore_errors}, [file]
			@job = Blastengine::Job.new res["job_id"]
			return @job
		end
	end

	def email
		Blastengine::Email.new(@delivery_id)
	end
end
