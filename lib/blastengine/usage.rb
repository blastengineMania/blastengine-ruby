require 'date'

module Blastengine
	class Usage < Base
		include Blastengine
		attr_accessor :month, :current, :remaining, :updated_time, :plan_id
		def initialize params
			@month = params["month"]
			@current = params["current"]
			@remaining = params["remaining"]
			@updated_time = params["updated_time"]
			@plan_id = params["plan_id"]
		end

		def self.all month_ago = 1
			# APIリクエスト用のパス
			path = "/usages?month_ago=#{month_ago}"
			res = @@client.get path
			res["data"].map do |params|
				self.new params
			end
		end

		def self.get month = Date.today.strftime("%Y%m")
			# APIリクエスト用のパス
			path = "/usages/#{month}"
			res = @@client.get path
			self.new res
		end

		def self.latest
			# APIリクエスト用のパス
			path = "/usages/latest"
			res = @@client.get path
			self.new res
		end
	end
end