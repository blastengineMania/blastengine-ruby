module Blastengine
	class Report < Download
		include Blastengine
		attr_accessor :job_id, :delivery_id, :percentage, :status, :mail_open_file_url, :total_count, :report
		def initialize delivery_id
			@delivery_id = delivery_id
			create
		end

		def create
			# APIリクエスト用のパス
			path = "/deliveries/#{@delivery_id}/analysis/report"
			res = @@client.post path
			@job_id = res["job_id"]
			return @job_id
		end

		def finish?
			# APIリクエスト用のパス
			path = "/deliveries/-/analysis/report/#{@job_id}"
			res = @@client.get path
			@percentage = res["percentage"]
			@status = res["status"]
			@total_count = res["total_count"] unless res["total_count"].nil?
			@mail_open_file_url = res["mail_open_file_url"] unless res["mail_open_file_url"].nil?
			return @percentage == 100
		end

		def get
			return @report unless @report.nil?
			return nil unless @percentage == 100
			path = "/deliveries/-/analysis/report/#{@job_id}/download"
			res = @@client.get path, true
			@report = download res
			@report
		end
	end
end
