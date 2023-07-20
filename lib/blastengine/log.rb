module Blastengine
	class Log < Base
		include Blastengine
		attr_accessor :cc, :bcc, :subject, :text_part, :encode, :html_part, :attachments, :delivery_id, :job

		def self.from_hash(params)
			log = Log.new
			log.sets(params)
			log
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
			url = "/logs/mails/results?#{query_string}";
			res = Mail.client.get url
			return res['data'].map {|params| Log.from_hash params }
		end
	end
end
