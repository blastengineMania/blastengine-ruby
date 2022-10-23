# Blastengine SDK

Blastengine SDKは、Rubyを用いて[エンジニア向けメール配信システム「ブラストエンジン」](https://blastengine.jp/)にてメール送信を行うSDKです。

## インストール

Gemfileに以下を追加します。

```ruby
gem 'blastengine'
```

そして下記コマンドを実行します。

    $ bundle install

またはgemコマンドでインストールしてください。

    $ gem install blastengine

## 使い方

### 初期化

APIキーとユーザー名はblastengineのサイトで取得してください。

```ruby
client = Blastengine.initialize api_key: "API_KEY", user_name: "YOUR_USER_NAME"
```

### トランザクションメール

#### テキストメール

```ruby
transaction = Blastengine::Transaction.new
transaction.from "admin@example.com", "Administrator"
transaction.to = "user@example.jp"
transaction.subject = "Test subject"
transaction.text_part = "This is a test email"
transaction.html_part = "<H1>Hello, world!</h1>"
delivery_id = transaction.send
```

#### 添付ファイル付きメール

```ruby
transaction = Blastengine::Transaction.new
transaction.from "admin@example.com", "Administrator"
transaction.to = "user@example.jp"
transaction.subject = "Test subject"
transaction.text_part = "This is a test email"
transaction.html_part = "<H1>Hello, world!</h1>"
transaction.attachments << "README.md"
transaction.attachments << "./spec/test.jpg"
delivery_id = transaction.send
```

### バルクメール

```ruby
bulk = Blastengine::Bulk.new
bulk.from "admin@example.com", "Administrator"
bulk.subject = "Test bulk email"
bulk.text_part = "This is a test email to __name__"
# Register email as template
bulk.register

# Add address
bulk.add "test1@example.jp", {name: "User 1"}
bulk.add "test2@example.jp", {name: "User 2"}
bulk.update

# Send email immediately
bulk.send

# Send email 2 minutes later
bulk.send Time.now + 120
```

### アドレスのCSVアップロード

```ruby
bulk = Blastengine::Bulk.new
bulk.from email: config["from"]["email"], name: config["from"]["name"]
bulk.subject = "Test bulk email, 2 minute later"
bulk.text_part = "This is a test email to __name__"
bulk.register

job = bulk.import "./spec/example.csv"

while !job.finish?
    puts job.percentage
end

# Result of importing email addresses
job.total_count
job.success_count
job.failed_count
job.error_file_url

# Get error if there is it
job.error_message
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Blastengine project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/blastengineMania/blastengine/blob/main/CODE_OF_CONDUCT.md).
