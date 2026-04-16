# インストール
## Windows用ソフトウェアパッケージマネージャー Chocolatey 
### 理者権限でPowerShellを起動
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

## Terraform
### 理者権限でPowerShellを起動
choco install terraform

Do you want to run the script?([Y]es/[A]ll - yes to all/[N]o/[P]rint): Y

## AWS CLI
### 理者権限でPowerShellを起動
choco install awscli

Do you want to run the script?([Y]es/[A]ll - yes to all/[N]o/[P]rint): Y

## Visual Studio Code のインストール
https://code.visualstudio.com/ からVSCodeをインストール

## Visual Studio Code 拡張機能 のインストール
HashiCorp Terraform を入れておく

Terraform Provider for SakuraCloudは、VM作成時にインストールするので、事前インストールはいらない。

# 作業
## AWS環境変数の設定
### PowerShell で実行
aws configure
AWS Access Key ID [None]: AWSマネジメントコンソールでダウンロードしたCSVファイル表示のAWSアクセスキーIDを入力
AWS Secret Access Key [None]: AWSマネジメントコンソールでダウンロードしたCSVファイル表示のAWSシークレットアクセスキーを入力
Default region name [None]: ap-northeast-1
Default output format [None]: 空欄でOK

## bluepintIDを調べる
### PowerShell で実行
aws lightsail get-blueprints --region ap-northeast-1 --query 'blueprints[].{blueprintId:blueprintId,name:name,group:group,productUrl:productUrl,platform:platform}' --output table

## TerraformでAWS LightsailのVMを作るために必要なファイルをつくる
lightsail-vmフォルダをワークスペースとして読み込み、下に３つのファイルを、Visual Studio Code で作成
- main.tf
- variables.tf
- outputs.tf

# Visual Studio Code で、lightsail-vmのワークスペース内で、ターミナルを起動、Terraformコマンドを実行
## Visual Studio Code のターミナルから実行
### TerraformによるVM作成
####  初期化
terraform init

#### 実行計画の確認
terraform plan

#### デプロイ
terraform apply

Enter a value: yes と入力してEnterキーを押す
完了後、SSH接続コマンドが出力される

#### 実行結果（例）
Outputs:

instance_name = "my-lightsail-vm"
private_key_path = "./my-lightsail-vm-key.pem"
public_ip = "52.195.96.254"
ssh_command = "ssh -i my-lightsail-vm-key.pem ubuntu@52.195.96.254"

### SSHを使って、VMに接続

ssh -i my-lightsail-vm-key.pem ubuntu@52.195.96.254 

Are you sure you want to continue connecting (yes/no/[fingerprint])? yes を入力してEnterキーを押す

下記のように表示されれば、AWS Lightsaill上のVMに接続。
ubuntu@ip-172-26-14-235:~$ 　

VM上でコマンドを実行してみる
ubuntu@ip-172-26-14-235:~$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 24.04.4 LTS
Release:        24.04
Codename:       noble

VMから抜ける
exit

#### VMの削除
terraform destroy