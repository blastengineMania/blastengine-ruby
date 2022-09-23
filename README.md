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
transaction.to << "user@example.jp"
transaction.subject = "Test subject"
transaction.text_part = "This is a test email"
transaction.html_part = "<H1>Hello, world!</h1>"
delivery_id = transaction.send
```

#### 添付ファイル付きメール

```ruby
transaction = Blastengine::Transaction.new
transaction.from "admin@example.com", "Administrator"
transaction.to << "user@example.jp"
transaction.subject = "Test subject"
transaction.text_part = "This is a test email"
transaction.html_part = "<H1>Hello, world!</h1>"
transaction.attachments << "README.md"
transaction.attachments << "./spec/test.jpg"
delivery_id = transaction.send
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Blastengine project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/blastengineMania/blastengine/blob/main/CODE_OF_CONDUCT.md).
