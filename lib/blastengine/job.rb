require "time"
require "zip"
require "tempfile"

module Blastengine
	class Job < Base
		include Blastengine
		attr_accessor :job_id, :percentage, :status, :error_file_url, :success_count, :failed_count, :total_count
		def initialize id
			@job_id = id
		end

		def finish?
			# APIリクエスト用のパス
			path = "/deliveries/-/emails/import/#{@job_id}"
			res = @@client.get path
			@percentage = res["percentage"]
			@status = res["status"]
			@error_file_url = res["error_file_url"] unless res["error_file_url"].nil?
			@success_count = res["success_count"] unless res["success_count"].nil?
			@failed_count = res["failed_count"] unless res["failed_count"].nil?
			@total_count = res["total_count"] unless res["total_count"].nil?
			return @percentage == 100
		end

		def error_message
			return @error_message unless @error_message.nil?
			return nil if @error_file_url.nil?
			path = "/deliveries/-/emails/import/#{@job_id}/errorinfo/download"
			res = @@client.get path, true
			f = Tempfile.create("blastengine")
			f.binmode
			f.write res
			f.flush
			path = f.path
			input = Zip::File.open path
			@error_message = input.read input.entries[0].to_s
			@error_message
		end
	end
end
