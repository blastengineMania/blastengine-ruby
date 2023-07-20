require 'date'
require "zip"
require "tempfile"

module Blastengine
	class Download < Base
		include Blastengine

		def download res
			f = Tempfile.create("blastengine")
			f.binmode
			f.write res
			f.flush
			path = f.path
			input = Zip::File.open path
			data = input.read input.entries[0].to_s
			f.close
			return data
		end
	end
end
