# TerraformでAWS Lightsailに仮想マシンをつくる手順

## テンプレートのダウンロードとVisual Studio Codeでの読み込み
### テンプレートのダウンロード
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
5. Visual Studio Codeが起動し、


## AWS環境変数の設定
### IAMのポリシーの確認
- AWS管理者は、IAMユーザーグループ内の許可ポリシーにおいて作成済みのポリシーに、Lightsailが含まれることを確認してください。含まれていない場合は、Lightsailを追加してください。

### アクセスキーIDとシークレットアクセスキーの取得
1. AWS Management Consoleにアクセスし、ログインします。
2. 画面右上のユーザーをクリックし、表示される「セキュリティ認証情報」をクリックします。
3. 「アクセスキーを作成」をクリックします。
4. 「ユースケース」で、「コマンドラインインタフェース（CLI）」を選びます。
5. 「上記のレコメンデーションを理解し、アクセスキーを作成します。」にチェックを入れます。
6. 「次へ」をクリックします。
7. 「アクセスキーを作成」をクリックします。
8. 「.csvファイルをダウンロード」をクリックします。
9. 「完了」をクリックします。
11. ダウンロードしたCSVファイルを開きます。Access key ID と Secret Access Key が記載されています。

### PowerShell 
```
aws configure
AWS Access Key ID [None]: AWSマネジメントコンソールでダウンロードしたCSVファイル表示のAWSアクセスキーIDを入力
AWS Secret Access Key [None]: AWSマネジメントコンソールでダウンロードしたCSVファイル表示のAWSシークレットアクセスキーを入力
Default region name [None]: ap-northeast-1
Default output format [None]: 空欄でOK
```

## Lightsail用のカスタムSSHキーを作成する
1. Webブラウザ上でLightsailにアクセスします（ https://ap-northeast-1.lightsail.aws.amazon.com/ls/webapp/home/instances ）。
2. 「インスタンスの作成」をクリックします。
3. 少し下に画面をスクロールしまして、「カスタムキーを作成」をクリックします。
4. 「リージョンの選択」と表示されるので、「作成」をクリックします。
5. 「新規 SSH キーペアの作成」と表示されるので、半角英数字でキーペア名を入力（例 niigatalightsail）します。
6. 「キーペアの作成」をクリックします。
7. 「キーペアが作成されました!」が表示されます。
8. 「プライベートキーのダウンロード」をクリックします。
9. PCに、.pem ファイルがダウンロードされていることを確認します。
10. ダウンロードの有無を確認後、ダウンロードできていれば「成功しました」をクリックします。

## LightsailのbluepintIDを調べる
### PowerShell で実行
```
aws lightsail get-blueprints --region ap-northeast-1 --query 'blueprints[].{blueprintId:blueprintId,name:name,group:group,productUrl:productUrl,platform:platform}' --output table
```

## TerraformでAWS LightsailのVMを作るために必要なファイルをつくる
lightsail-vmフォルダをワークスペースとして読み込み、下に３つのファイルを、Visual Studio Code で作成
- main.tf
- variables.tf
- outputs.tf

# Visual Studio Code で、lightsail-vmのワークスペース内で、ターミナルを起動、Terraformコマンドを実行
## Visual Studio Code のターミナルから実行
### TerraformによるVM作成
####  初期化
```
terraform init
```

#### 実行計画の確認
```
terraform plan
```

#### デプロイ
```
terraform apply
```

Enter a value: yes と入力してEnterキーを押す
完了後、SSH接続コマンドが出力される

#### 実行結果（例）
```
Outputs:

instance_name = "my-lightsail-vm"
private_key_path = "./my-lightsail-vm-key.pem"
public_ip = "52.195.96.254"
ssh_command = "ssh -i my-lightsail-vm-key.pem ubuntu@52.195.96.254"
```

### SSHを使って、VMに接続
```
ssh -i my-lightsail-vm-key.pem ubuntu@52.195.96.254 

Are you sure you want to continue connecting (yes/no/[fingerprint])? yes を入力してEnterキーを押す
```

下記のように表示されれば、AWS Lightsaill上のVMに接続。
ubuntu@ip-172-26-14-235:~$ 　

VM上でコマンドを実行してみる
```
ubuntu@ip-172-26-14-235:~$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 24.04.4 LTS
Release:        24.04
Codename:       noble
```

VMから抜ける
```
exit
```

#### VMの削除
terraform destroy
