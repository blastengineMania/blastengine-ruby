require 'date'

module Blastengine
	class Mail < Base
		include Blastengine
		attr_accessor :to, :cc, :bcc, :subject, :text_part, :encode, :html_part, :attachments, :delivery_id, :list_unsubscribe

		def initialize
			@to = []
			@cc = []
			@bcc = []
			@attachments = []
			@encode = "UTF-8"
			@list_unsubscribe = {
				url: "",
				email: ""
			}
		end

		#
		# 送信主の追加
		#
		def from(email:, name: "")
			@_from = {email: email, name: name}
		end

		#
		# 受信者の追加
		#
		def addTo(email:, insert_code: {})
			@to << {
				email: email,
				insert_code: insert_code
			}
		end
		
		def send(date = nil)
			# CCまたはBCCがある場合はTransaction × Toの分
			# Toが複数の場合はBulk、Toが1つの場合はTransaction
			if @cc.size > 0 || @bcc.size > 0
				# CCまたはBCCがある場合は、指定時刻送信はできない
				raise "CC or BCC is not supported when sending at a specified time." if date != nil
				raise "CC or BCC is not supported when sending to multiple recipients." if @to.size > 1
			end
			if date != nil || @to.size == 1
				return self.sendTransaction();
			end
			return self.sendBulk(date)
		end

		def sendBulk(date = nil)
			bulk = Bulk.new
			bulk.from email: @_from[:email], name: @_from[:name]
			bulk.subject = @subject
			bulk.encode = @encode
			bulk.text_part = @text_part
			bulk.html_part = @html_part
			bulk.unsubscribe url: @list_unsubscribe[:url], email: @list_unsubscribe[:email]
			if @attachments.size > 0
				bulk.attachments = @attachments
			end
			bulk.register
			@to.each do |to|
				bulk.addTo(to[:email], to[:insert_code])
			end
			bulk.update
			bulk.send date
			@delivery_id = bulk.delivery_id
			return true;
		end

		def sendTransaction
			transaction = Transaction.new
			transaction.from email: @_from[:email], name: @_from[:name]
			transaction.subject = @subject
			transaction.encode = @encode
			transaction.text_part = @text_part
			transaction.html_part = @html_part
			transaction.to = @to[0][:email]
			transaction.insert_code = @to[0][:insert_code] if @to[0][:insert_code].size > 0
			transaction.cc = @cc if @cc.size > 0
			transaction.bcc = @bcc if @bcc.size > 0
			transaction.unsubscribe url: @list_unsubscribe[:url], email: @list_unsubscribe[:email]
			if @attachments.size > 0
				transaction.attachments = @attachments
			end
			transaction.send
			@delivery_id = transaction.delivery_id
			return true;
		end

		def self.from_hash(params)
			mail = params["delivery_type"] == "TRANSACTION" ? Transaction.new : Bulk.new
			mail.sets(params);
			mail
		end

		def self.find(params = {})
			Hash[ params.map{|k,v| [k.to_sym, v] } ]
			if params[:delivery_start] != nil
				params[:delivery_start] = params[:delivery_start].iso8601
			end
			if params[:delivery_end] != nil
				params[:delivery_end] = params[:delivery_end].iso8601
			end
			query_string = URI.encode_www_form(params)
			url = "/deliveries?#{query_string}";
			res = Mail.client.get url
			return res['data'].map {|params| Mail.from_hash params }
		end

		def self.all(params = {})
			Hash[ params.map{|k,v| [k.to_sym, v] } ]
			if params[:delivery_start] != nil
				params[:delivery_start] = params[:delivery_start].iso8601
			end
			if params[:delivery_end] != nil
				params[:delivery_end] = params[:delivery_end].iso8601
			end
			query_string = URI.encode_www_form(params)
			url = "/deliveries/all?#{query_string}";
			res = Mail.client.get url
			return res['data'].map {|params| Mail.from_hash params }
		end
	end
end
