# frozen_string_literal: true
require "base64"
require "digest/sha2"
require "faraday"
require "faraday/multipart"
require "json"
require "mini_mime"

#
# Blastengine SDKのモジュール
#
module Blastengine
	# APIエンドポイント
	DOMAIN = "app.engn.jp"
	# APIのベースパス
	BASE_PATH = "/api/v1"
	# APIリクエストエラーが入る変数
	@@last_error = nil
	# APIクライアントが入る変数
	@@client = nil

	#
	# Blastengine SDKを初期化する
	#
	def Blastengine.initialize(api_key:, user_name:)
		@@client = Client.new api_key, user_name
	end

	#
	# Blastengine SDKクライアント
	# 基本的に各メール機能から呼ばれる
	#
	class Client
		include Blastengine
		# APIキー
		@api_key = nil
		# ユーザー名
		@user_name = nil
		# トークン
		@token = nil

		#
		# コンストラクター
		# APIキー、ユーザー名の設定とトークンの生成を行う
		#
		def initialize(api_key, user_name)
			self.api_key = api_key
			self.user_name = user_name
			self.generate_token
		end
		# アクセッサー
		attr_accessor :token, :api_key, :user_name

		#
		# トークンを生成する
		#
		def generate_token
			return @token unless @token.nil?
			str = "#{@user_name}#{@api_key}";
			@token = Base64.urlsafe_encode64 Digest::SHA256.hexdigest(str).downcase
		end
		
		#
		# APIリクエストを行うFaradayのインスタンスを返す
		# 添付ファイルの有無によって返すオブジェクトが異なる
		#
		def conn(attachment_count = 0)
			# 共通の設定
			url = "https://#{DOMAIN}"
			headers = {
				"Authorization": "Bearer #{@token}"
			}
			# 添付ファイルがある場合
			if attachment_count > 0
				# MultiPartの設定をして返す
				Faraday.new(
					url: url,
					headers: headers
				) do |faraday|
					faraday.request :multipart, flat_encode: true
				end
			else
				# 添付ファイルがない場合
				# JSONの設定をして返す
				headers["Content-Type"] = "application/json"
				Faraday.new(
					url: url,
					headers: headers
				)
			end
		end

		#
		# POSTリクエスト用のデータを生成する
		#
		def post_data(data, attachments = [])
			# 添付ファイルがない場合は、データをJSONに変換して返す
			return data.to_json if attachments.length == 0
			# 添付ファイルがある場合はファイルを読み込んで返す
			return {
				data: Faraday::Multipart::ParamPart.new(data.to_json, "application/json"),
				file: attachments.map{|a| Faraday::Multipart::FilePart.new(
					File.open(a),
					MiniMime.lookup_by_filename(a) ? MiniMime.lookup_by_filename(a).content_type : "application/octet-stream",
					File.basename(a)
				)}
			}
		end

		#
		# POSTリクエストを行う
		#
		def post(path, data, attachments = [])
			# リクエストボディの生成
			params = self.post_data data, attachments
			# リクエスト実行
			res = self.conn(attachments.size).post("#{BASE_PATH}#{path}", params)
			# レスポンスを処理
			return self.handle_response res
		end

		#
		# PUTリクエストを行う
		#
		def put(path, data)
			# リクエスト実行
			res = self.conn.put("#{BASE_PATH}#{path}", data.to_json)
			# レスポンスを処理
			return self.handle_response res
		end

		#
		# PATCHリクエストを行う
		#
		def patch(path, data)
			# リクエスト実行
			res = self.conn.patch("#{BASE_PATH}#{path}", data.to_json)
			# レスポンスを処理
			return self.handle_response res
		end

		def delete(path)
			# リクエスト実行
			res = self.conn.delete("#{BASE_PATH}#{path}")
			# レスポンスを処理
			return self.handle_response res
		end

		#
		# レスポンスのハンドリング用
		# 
		def handle_response(res)
			# レスポンスをJSONパース
			json = JSON.parse res.body
			# 200または201なら、レスポンスを返す
			return json if res.status == 200 or res.status == 201
			# それ以外はエラーを生成して例外処理
			message = json["error_messages"].map{|key, value| "Error in #{key} (#{value})"}.join("\n")
			@@last_error = Blastengine::Error.new message
			raise @@last_error
		end
	end
end