# terraform-handson
## Windows環境で、VSCodeを使って、TerraformでAWS Lightsail上でVM起動のハンズオン資料
### インストール
#### Windows用ソフトウェアパッケージマネージャー Chocolatey 
##### 管理者権限でPowerShellを起動
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

#### Terraform
##### 管理者権限でPowerShellを起動
choco install terraform

Do you want to run the script?([Y]es/[A]ll - yes to all/[N]o/[P]rint): Y

#### AWS CLI
##### 管理者権限でPowerShellを起動
choco install awscli

Do you want to run the script?([Y]es/[A]ll - yes to all/[N]o/[P]rint): Y

#### Visual Studio Code のインストール
https://code.visualstudio.com/ からVSCodeをインストール

#### Visual Studio Code 拡張機能 のインストール
HashiCorp Terraform を入れておく

Terraform Provider for SakuraCloudは、VM作成時にインストールするので、事前インストールはいらない。

### TerraformでVM作成のドキュメント
| ドキュメント | 説明 |
|---|---|
| [AWS LightsailでVM作成](aws/Terraform-AWS-README.md) | Terraformを使って、AWS LighsailでVMを作成する資料 |
| [さくらのクラウドでVM作成](sakura/Terraform-Sakura-README.md) | Terraformを使って、さくらのクラウドで最小構成のVMを作成する資料 |

