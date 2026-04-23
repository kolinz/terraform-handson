# Terraformで、さくらのクラウドに仮想マシンをつくる手順

## テンプレートのダウンロードとVisual Studio Codeでの読み込み

### テンプレートのダウンロード
すでにダウンロード済みの場合は飛ばしてください。

git cloneが使える人は、git clone を使ってください。下記をZIP形式でダウンロードした場合です。

1. https://github.com/kolinz/terraform-handson/archive/refs/heads/main.zip にアクセスし、本ハンズオン用のTerraform定義ファイルをダウンロードします。
2. terraform-handson-main.zipがダウンロードされます。
3. terraform-handson-main.zipを解凍（例 ダウンロードフォルダで、terraform-handson-main.zipを選び、すべて展開 >> 展開をクリック）
4. terraform-handson-main フォルダができます。

### Visual Studio Codeの起動
1. terraform-handson-main フォルダをダブルクリックします。
2. 同名のterraform-handson-main フォルダを右クリックして、「Codeで開く」をクリックします。
3. Visual Studioが起動し、「このフォルダー内のファイルの作成者を信頼しますか?」と表示されます。
4. 「はい、作成者を信頼します。」をクリックします。
5. Visual Studio Codeが起動し、画面左側に「aws」フォルダと「sakura」フォルダがあることが確認できます。
6. 「sakura」フォルダをダブルクリックし、「Terraform-Sakura-README.md」をクリックして画面中央部分に表示します。「Terraform-Sakura-README.md」はAWS さくらのクラウドで、Terraformを使う際の手順がかかれているファイルです。

## さくらのクラウドに作成するサーバの構成概要
さくらのクラウドでは、VMをサーバと言う。

| 項目 | 設定値 |
|------|--------|
| ゾーン | is1b（石狩第2） |
| CPU | 1コア |
| メモリ | 1GB |
| OS | Ubuntu 24.04 LTS |
| ディスク | SSD 20GB |
| ネットワーク | 共有グローバルIP |
| Webサーバ | Nginx（自動インストール） |

## ファイル構成

| 要作成 | 自動生成 | ファイル | 説明 |
|:---:|:---:|---|---|
| | | `main.tf` | メインのTerraformコード。サーバ・ディスク・SSHキー・パケットフィルタを定義 |
| | | `variables.tf` | 変数の定義。ゾーン・サーバ名・パスワード・タグ |
| | | `outputs.tf` | `terraform apply` 完了後に表示される出力値（IPアドレス・SSH接続コマンド等） |
| | | `terraform.tfvars.example` | 変数の設定例。コピーして `terraform.tfvars` として使用する |
| ✅ | | `terraform.tfvars` | 実際の変数値を記載するファイル（Gitに含めないこと） |
| | ✅ | `web-server.pem` | SSH秘密鍵（`terraform apply` 時に自動生成。Gitに含めないこと） |
| | ✅ | `.terraform/` | プロバイダのバイナリ等（`terraform init` で自動生成。Gitに含めないこと） |
| | ✅ | `terraform.tfstate` | Terraformが管理するインフラの状態ファイル（自動生成。Gitに含めないこと） |

## 事前準備

### 1. SSH秘密鍵について

SSHキーペアは `terraform apply` 時に **さくらのクラウド側で自動生成** されます。
生成された秘密鍵は `web-server.pem` としてこのディレクトリに自動保存されます。

> ⚠️ `web-server.pem` は再取得できません。`terraform destroy` 前に必ずバックアップしてください。

### 2. APIキーの設定（環境変数推奨）

#### APIキーの作成手順

1. ブラウザで以下のURLを開く
   - https://secure.sakura.ad.jp/cloud/
   - もし英語表示された場合は、画面下にある「日本語」をクリックすると、日本語表示に切り替わる。

2.画面左側の「APIキー」をクリック

3. 「APIキーの作成」をクリック

4. 以下の通り設定して「作成」をクリック

   | 項目 | 設定値 |
   |---|---|
   | APIキーの種類 | リソース操作APIキー |
   | APIキー名 | Terraform-sakura（任意） |
   | アクセスレベル | 作成・削除 |
   | サービスへのアクセス権 | チェックなし |

5. 作成後の画面に **アクセストークン** と **アクセストークンシークレット** が表示される
   > ⚠️ アクセストークンシークレットはこの画面でしか確認できません。必ずコピーしてください。

6. 「CSVのダウンロード」をクリック。

#### Visual Studio Codeでターミナルの呼び出し
Visual Studio Codeで、画面上部のメニューバーで、「ターミナル」>>「新しいターミナル」の順にクリックします。
画面中央下部に「ターミナル」タブが表示され、コマンドを打つことができるようになります。
「sakura」フォルダに移動します。

terraform-handson-main\aws> と表示されている場合の実行すべき移動コマンド
```
terraform-handson-main\aws> cd ../sakura
```
terraform-handson-main> と表示されている場合の実行すべき移動コマンド
```
terraform-handson-main> cd sakura
```

#### 環境変数にセット

さくらのクラウド コントロールパネル → **APIキー** からトークンを発行し、環境変数にセットします。
- your-access-token を取得した、Access Token の値に置き換え。
- your-secret を取得した、Access Token Secret の値に置き換え。

**Visual Studio Codeのターミナル(PowerShell）**
```powershell
$env:SAKURACLOUD_ACCESS_TOKEN = "your-access-token"
$env:SAKURACLOUD_ACCESS_TOKEN_SECRET = "your-secret"
```

**Git Bash / macOS・Linux**
```bash
export SAKURACLOUD_ACCESS_TOKEN="your-access-token"
export SAKURACLOUD_ACCESS_TOKEN_SECRET="your-secret"
```

### 3. tfvars の準備
terraform.tfvars内の値は、ハンズオンではとりあえず良いものの、基本的には server_password を必ず変更する（緊急時のコンソールログイン用）

**PowerShell**
```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

**Git Bash / macOS・Linux**
```bash
cp terraform.tfvars.example terraform.tfvars
```

## デプロイ手順

`terraform` コマンド自体はOS問わず共通です。

初期化の実行
```
terraform init
```

実行結果例
```
Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

実行計画の確認
```
terraform plan
```

VM作成（完了後にIPアドレスとSSHコマンドが表示されます）
```
terraform apply
```

SSH接続確認
```
ssh -i web-server.pem ubuntu@<表示されたIPアドレス>
```

SSH接続後、以下を実行してNginxをインストールしてください。

```
sudo apt update
sudo apt install nginx
```

VMから離脱するには `exit` を実行してください。

```
exit
```

`terraform apply` 実行時に以下の確認プロンプトが表示されます。`yes` と入力してEnterを押してください（`y` だけでは受け付けられません）。

```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

## 削除
⚠️ 実行前に web-server.pem をバックアップすること
```
terraform destroy
```

`terraform destroy` でも同様に `yes` の入力が求められます。

## 作成されるリソース

- `sakuracloud_server` : サーバ本体
- `sakuracloud_disk` : SSDディスク（Ubuntu 24.04）
- `sakuracloud_ssh_key_gen` : SSHキーペア（自動生成）
- `sakuracloud_note` : スタートアップスクリプト（Nginx導入）
- `sakuracloud_packet_filter` : パケットフィルタ（22/80/443のみ許可）
- `local_sensitive_file` : SSH秘密鍵（.pem）をローカル保存

## Windows での SSH 接続補足

`terraform apply` 完了後、Windowsでは秘密鍵のパーミッション設定が必要です。
これをしないと `Permissions are too open` エラーが出て接続できません。
```
icacls web-server.pem /inheritance:r /grant:r "$($env:USERNAME):(R)"
```

設定後、以下のコマンドで接続できます：
```
ssh -i web-server.pem ubuntu@<サーバのIPアドレス>
```

初回接続時は以下のメッセージが表示されます。`yes` と入力してEnterを押してください（ホスト鍵が `known_hosts` に登録されます）。
```
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
```

## VM内で sudo を実行した際のパスワードについて

`sudo apt install` などの実行時にパスワードを求められた場合は、`terraform.tfvars` の `server_password` に設定した値を入力してください。

```
# terraform.tfvars
server_password = "YourStr0ngPassw0rd!"  # ← これ
```

## ⚠️ SSH接続時に "REMOTE HOST IDENTIFICATION HAS CHANGED" が出た場合

`terraform destroy` → `terraform apply` でサーバを作り直すと、同じIPアドレスに異なるホスト鍵のサーバが割り当てられることがあります。その場合、`known_hosts` に残った古いホスト鍵と一致せずエラーになります。

以下のコマンドで古いエントリを削除してください：

```
ssh-keygen -R <サーバのIPアドレス>
```

削除後に再接続すると `Are you sure you want to continue connecting (yes/no)?` と聞かれるので `yes` と入力してください。
