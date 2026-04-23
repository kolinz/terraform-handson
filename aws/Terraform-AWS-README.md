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
5. Visual Studio Codeが起動し、画面左側に「aws」フォルダと「sakura」フォルダがあることが確認できます。
6. 「aws」フォルダをダブルクリックし、「Terraform-AWS-README.md」をクリックして画面中央部分に表示します。「Terraform-AWS-README.md」はAWS LightsailでTerraformを使う際の手順がかかれているファイルです。

## AWS CLIの初期設定
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

### Visual Studio Codeでターミナルの呼び出し 
1. Visual Studio Codeで、画面上部のメニューバーで、「ターミナル」>>「新しいターミナル」の順にクリックします。
2. 画面中央下部に「ターミナル」タブが表示され、コマンドを打つことができるようになります。
3. 「aws」フォルダに移動します。
```
cd aws
```
### AWS CLIの初期設定
```
aws configure
AWS Access Key ID [None]: AWSマネジメントコンソールでダウンロードしたCSVファイル表示のAWSアクセスキーIDを入力
AWS Secret Access Key [None]: AWSマネジメントコンソールでダウンロードしたCSVファイル表示のAWSシークレットアクセスキーを入力
Default region name [None]: ap-northeast-1
Default output format [None]: 空欄でOK
```

## LightsailのbluepintIDを調べる
### Visual studio Codeのターミナルで実行
```
aws lightsail get-blueprints --region ap-northeast-1 --query 'blueprints[].{blueprintId:blueprintId,name:name,group:group,productUrl:productUrl,platform:platform}' --output table
```
実行結果例
```
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|                                                                                       GetBlueprints                                                                                       |
+--------------------------------------+----------------------------+---------------------------------------+-------------+-----------------------------------------------------------------+
|              blueprintId             |           group            |                 name                  |  platform   |                           productUrl                            |
+--------------------------------------+----------------------------+---------------------------------------+-------------+-----------------------------------------------------------------+
|  windows_server_2022                 |  windows_2022              |  Windows Server 2022                  |  WINDOWS    |  https://aws.amazon.com/marketplace/pp/prodview-dq4sxno5vuy7m   |
|  windows_server_2019                 |  windows_2019              |  Windows Server 2019                  |  WINDOWS    |  https://aws.amazon.com/marketplace/pp/B07QZ4XZ8F               |
|  windows_server_2016                 |  windows_2016              |  Windows Server 2016                  |  WINDOWS    |  https://aws.amazon.com/marketplace/pp/B01M7SJEU7               |
|  windows_server_2022_sql_2022_express|  windows_2022_sql_exp_2022 |  SQL Server 2022 Express              |  WINDOWS    |  https://aws.amazon.com/marketplace/pp/prodview-c2jz4lr4h2yc6   |
|  windows_server_2022_sql_2019_express|  windows_2022_sql_exp_2019 |  SQL Server 2019 Express              |  WINDOWS    |  https://aws.amazon.com/marketplace/pp/prodview-xbikutlmywslu   |
|  windows_server_2016_sql_2016_express|  windows_2016_sql_exp      |  SQL Server 2016 Express              |  WINDOWS    |  https://aws.amazon.com/marketplace/pp/B01MAZHH98               |
|  amazon_linux_2023                   |  amazon_linux_2023         |  Amazon Linux 2023                    |  LINUX_UNIX |  https://aws.amazon.com/linux/amazon-linux-2023                 |
|  amazon_linux_2                      |  amazon_linux_2            |  Amazon Linux 2                       |  LINUX_UNIX |  https://aws.amazon.com/amazon-linux-2/                         |
|  ubuntu_24_04                        |  ubuntu_24                 |  Ubuntu                               |  LINUX_UNIX |  https://aws.amazon.com/marketplace/pp/prodview-s4zvkzmlirbga   |
-- More  -- 
```
Moreの表示はEnterキーを押すと進みます。

## TerraformでAWS LightsailのVMを作るために必要なファイルをつくる
「aws」フォルダ内に読み込み済みの３つのファイルを、Visual Studio Code で確認します。画面左側に表示されている各ファイルをクリックすると中身が表示されます（本来は自分でつくるべきもの）。
- main.tf
  - キーペアを自動作成するようにしています。
- variables.tf
- outputs.tf

# Visual Studio Code上でTerraformコマンドを実行し、AWS Lightsail上で動くVMを作成
## Visual Studio Code のターミナルから実行
### TerraformによるVM作成
####  初期化
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

#### 実行計画の確認
```
terraform plan
```
実行結果例
```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_lightsail_instance.main will be created
  + resource "aws_lightsail_instance" "main" {
      + arn                = (known after apply)
      + availability_zone  = "ap-northeast-1a"
      + blueprint_id       = "ubuntu_24_04"
      + bundle_id          = "nano_3_0"
      + cpu_count          = (known after apply)
      + created_at         = (known after apply)
      + id                 = (known after apply)
      + ip_address_type    = "dualstack"
      + ipv6_addresses     = (known after apply)
      + is_static_ip       = (known after apply)
      + key_pair_name      = "my-lightsail-vm-keypair"
      + name               = "my-lightsail-vm"
      + private_ip_address = (known after apply)
      + public_ip_address  = (known after apply)
      + ram_size           = (known after apply)
      + tags               = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
        }
      + tags_all           = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
        }
      + username           = (known after apply)
    }

  # aws_lightsail_instance_public_ports.main will be created
  + resource "aws_lightsail_instance_public_ports" "main" {
      + id            = (known after apply)
      + instance_name = "my-lightsail-vm"

      + port_info {
          + cidr_list_aliases = (known after apply)
          + cidrs             = (known after apply)
          + from_port         = 22
          + ipv6_cidrs        = (known after apply)
          + protocol          = "tcp"
          + to_port           = 22
        }
      + port_info {
          + cidr_list_aliases = (known after apply)
          + cidrs             = (known after apply)
          + from_port         = 443
          + ipv6_cidrs        = (known after apply)
          + protocol          = "tcp"
          + to_port           = 443
        }
      + port_info {
          + cidr_list_aliases = (known after apply)
          + cidrs             = (known after apply)
          + from_port         = 80
          + ipv6_cidrs        = (known after apply)
          + protocol          = "tcp"
          + to_port           = 80
        }
    }

  # aws_lightsail_key_pair.main will be created
  + resource "aws_lightsail_key_pair" "main" {
      + arn                   = (known after apply)
      + encrypted_fingerprint = (known after apply)
      + encrypted_private_key = (known after apply)
      + fingerprint           = (known after apply)
      + id                    = (known after apply)
      + name                  = "my-lightsail-vm-keypair"
      + name_prefix           = (known after apply)
      + private_key           = (known after apply)
      + public_key            = (known after apply)
      + tags_all              = (known after apply)
    }

  # aws_lightsail_static_ip.main will be created
  + resource "aws_lightsail_static_ip" "main" {
      + arn          = (known after apply)
      + id           = (known after apply)
      + ip_address   = (known after apply)
      + name         = "my-lightsail-vm-static-ip"
      + support_code = (known after apply)
    }

  # aws_lightsail_static_ip_attachment.main will be created
  + resource "aws_lightsail_static_ip_attachment" "main" {
      + id             = (known after apply)
      + instance_name  = "my-lightsail-vm"
      + ip_address     = (known after apply)
      + static_ip_name = "my-lightsail-vm-static-ip"
    }

  # local_file.private_key will be created
  + resource "local_file" "private_key" {
      + content              = (known after apply)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0600"
      + filename             = "./my-lightsail-vm-key.pem"
      + id                   = (known after apply)
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + instance_name    = "my-lightsail-vm"
  + private_key_path = "./my-lightsail-vm-key.pem"
  + public_ip        = (known after apply)
  + ssh_command      = (known after apply)
```

#### デプロイ
```
terraform apply
```

Enter a value: yes と入力してEnterキーを押す。

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
VMの割り当てpublic_ipの値が、52.195.96.254 だとして、次のコマンドを実行してSSH接続を実行。
```
ssh -i my-lightsail-vm-key.pem ubuntu@52.195.96.254 
```
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes を入力してEnterキーを押す

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
下記のコマンドを実行
```
terraform destroy
```
Enter a value: yes と入力してEnterキーを押す

実行結果例
```
Destroy complete! Resources: 6 destroyed.
```

#### SSHキーの削除
このサンプルでは、VM削除時にSSHキーが自動削除されないようになっているので、AWS Lightsailの[SSHキー管理画面](https://ap-northeast-1.lightsail.aws.amazon.com/ls/webapp/account/keys)で、不要になったSSHキーのカスタムキーを手動削除してください。

