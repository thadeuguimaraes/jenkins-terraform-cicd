### WEBSITE STATICO USANDO S3 COM TERRAFORM NA AWS

![JENKINSCICD1](https://github.com/thadeuguimaraes/jenkins-terraform-cicd/assets/52017205/d14dc8c5-60fa-4312-a563-316e8d214cc2)

## Web site Static no S3
![s3](https://github.com/thadeuguimaraes/jenkins-terraform-cicd/assets/52017205/eae6c5a3-c3ce-41ef-846d-6c2b94dd3658)

No atual mundo acelerado da computação em nuvem, a capacidade de provisionar infraestrutura de forma rápida e eficiente é uma virada de jogo. É aqui que entra a Infraestrutura como Código (IaC), permitindo-nos definir e gerenciar nossa infraestrutura de maneira baseada em código. Nesta postagem do blog, exploraremos como aproveitar o poder do IaC usando duas ferramentas essenciais: Terraform e Jenkins, em conjunto com Amazon Web Services (AWS).

Terraform é uma ferramenta IaC de código aberto que nos permite definir, criar e gerenciar nossa infraestrutura usando arquivos de configuração declarativos. Jenkins, por outro lado, é um servidor de automação amplamente adotado que ajuda a agilizar o processo de desenvolvimento e implantação de software.

Nossa jornada abrangerá vários objetivos principais:

1.**Configurando o Terraform e o Jenkins**: começaremos garantindo que você tenha todos os pré-requisitos em vigor, incluindo uma conta AWS, Terraform, Jenkins e Docker. Orientaremos você na instalação e configuração dessas ferramentas essenciais.

2.**Criando os scripts do Terraform:** Iremos nos aprofundar no coração do IaC criando scripts do Terraform para provisionar recursos da AWS. Ao longo do caminho, apresentaremos o conceito de dados do usuário, um recurso poderoso que nos permite automatizar tarefas como lançar contêineres em nossas instâncias.

3.**Executando dois contêineres de aplicativos** com dados do usuário: para demonstrar a aplicação prática dos dados do usuário, orientaremos você na inicialização não apenas de um, mas de dois contêineres de aplicativos em suas instâncias da AWS. Esta etapa mostra a versatilidade e os recursos de automação do IaC.

4.No projeto DevOps, usaremos Terraform e AWS Cloud para configurar hospedagem estática de sites totalmente automatizada em segundos. Este projeto Terraform ajudará os iniciantes a entender o conceito e o funcionamento do Terraform com AWS e como você pode criar uma solução automatizada com um clique usando Terraform em DevOps

5.**Configurando o gerenciamento de estado de infraestrutura:**

- **Bucket S3 para estado do Terraform**: criaremos um bucket AWS S3 dedicado a armazenar com segurança seus arquivos de estado do Terraform. Isto é essencial para manter o estado da sua infraestrutura num local central.

- **Tabela DynamoDB para bloqueio**: além do bucket S3, configuraremos uma tabela AWS DynamoDB para habilitar recursos de bloqueio. Isso garante que sua infraestrutura permaneça em um estado consistente quando vários usuários estiverem trabalhando simultaneamente.

6.**Integrando Jenkins e Terraform:** Para unir tudo, demonstraremos como integrar Jenkins com Terraform. Essa integração permitirá que você automatize o processo de provisionamento, aumente a eficiência do gerenciamento de sua infraestrutura e garanta que seu estado do Terraform seja armazenado e bloqueado com segurança quando necessário.

## Pré-requisitos:
Antes de embarcar na jornada de provisionamento de recursos da AWS usando Terraform e Jenkins, é crucial garantir que você tenha todos os componentes e configurações necessários em vigor. Aqui estão os pré-requisitos que você deve ter antes de iniciar este tutorial:

1.**Conta AWS**: você deve ter uma conta AWS ativa com privilégios administrativos ou as permissões necessárias para criar e gerenciar recursos AWS.

2.**S3 Bucket for Terraform State:**

- Objetivo: armazenar remotamente com segurança seus arquivos de estado do Terraform.

Steps:

   - Faça login no Console de gerenciamento da AWS.

   - Navegue até o serviço S3.

   - Crie um bucket S3 com um nome exclusivo na região AWS desejada.

   - Anote o nome do bucket, pois você o usará nos scripts do Terraform.

3.**DynamoDB Table for Locking Capability:**

  - Objetivo: habilitar o bloqueio para gerenciamento de estado do Terraform.

Steps:

- Acesse o Console de gerenciamento da AWS.

- Acesse o serviço DynamoDB.

- Crie uma tabela do DynamoDB com um nome exclusivo e uma chave primária.

- Configure as configurações de capacidade de leitura e gravação da tabela conforme necessário.

- Anote o nome da tabela para referência.

4.**Jenkins Setup:**

- Certifique-se de que o Jenkins esteja instalado e funcionando em seu ambiente.

- Configure o Jenkins com os plug-ins necessários para integração AWS e Terraform.

5. **Instalação do Terraform no Jenkins:**

O Terraform deve ser instalado no servidor Jenkins para executar scripts do Terraform como parte do seu pipeline de CI/CD.

6.**Arquivos Terraform no gerenciamento de código-fonte (SCM):**

Seus arquivos de configuração do Terraform já devem estar disponíveis em seu sistema de gerenciamento de código-fonte (por exemplo, Git). Certifique-se de ter os direitos de acesso necessários ao repositório.

7.**Função IAM para instância Jenkins EC2:**

- Objetivo: conceder à instância Jenkins EC2 as permissões necessárias para interagir com os recursos da AWS.

Steps:

- Crie uma função IAM na AWS.

- Anexe a política apropriada que concede permissões para provisionamento de recursos da AWS, acesso ao DynamoDB, operações de bucket S3 e quaisquer outras permissões necessárias.

- Associe a função IAM à instância Jenkins EC2.

8.**Repositório GitHub (opcional)**:

- Se estiver usando um repositório público como exemplo, você pode bifurcar o repositório e começar a fazer alterações em seu próprio repositório bifurcado. Certifique-se de ter o acesso necessário ao repositório.

Com esses pré-requisitos implementados, você estará bem preparado para mergulhar no tutorial e aprender como aproveitar Terraform, Jenkins, AWS S3 e DynamoDB para automatizar o provisionamento e o gerenciamento de estado de seus recursos da AWS. Esses componentes fundamentais são essenciais para uma implementação bem-sucedida de IaC e um pipeline de CI/CD para infraestrutura.

## Launch an Ubuntu(22.04) T2 Large Instance

Inicie uma instância grande do AWS T2. Use a imagem como Ubuntu. Você pode criar um novo par de chaves ou usar um existente. Habilite as configurações de HTTP e HTTPS no grupo de segurança e abra todas as portas (não é o melhor caso para abrir todas as portas, mas apenas para fins de aprendizagem, tudo bem).

## Instale o Jenkins, Docker e Trivy

**Para instalar o Jenkins**
```sh
vim jenkins.sh
```

```sh
#!/bin/bash
sudo apt update -y
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc
echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
sudo apt update -y
sudo apt install temurin-17-jdk -y
/usr/bin/java --version
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
                  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
                  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
                              /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install jenkins -y
sudo systemctl start jenkins
sudo systemctl status jenkins
```

```sh
sudo chmod 777 jenkins.sh
./jenkins.sh
```
Depois que o Jenkins estiver instalado, você precisará ir ao seu grupo de segurança AWS EC2 e abrir a porta de entrada 8080, já que o Jenkins funciona na porta 8080.

Agora, pegue seu endereço IP público
```sh
<EC2 Public IP Address:8080>
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
Desbloqueie o Jenkins usando uma senha administrativa e instale os plugins sugeridos.

Em seguida o jenkins instalará todas as bibliotecas.

Crie um usuário, clique em salvar e continuar.

**Instalando o Docker**

```sh
sudo apt-get update
sudo apt-get install docker.io -y
sudo usermod -aG docker $USER   #my case is ubuntu
newgrp docker
sudo chmod 777 /var/run/docker.sock
```
Após a instalação do docker, criamos um contêiner sonarqube (lembre-se de adicionar 9.000 portas no grupo de segurança).
```sh
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
```

Now our sonarqube is up and running

Enter username and password, click on login and change password

```sh
username admin
password admin
```
Atualize a nova senha, este é o Sonar Dashboard.

**Instalando o Triv**
```sh
vim trivy.sh
```

```sh
sudo apt-get install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy -y
```
A seguir, faremos login no Jenkins e começaremos a configurar nosso Pipeline no Jenkins

## Instale plug-ins como JDK, Sonarqube Scanner, Terraform

1.Eclipse Temurin Installer (Install without restart)
2.SonarQube Scanner (Install without restart)
3. Terraform

## vamos instalar o Terraform em nossa máquina Jenkins EC2.
```sh
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```
check terraform version
```sh
terraform --version
```
vamos encontrar o caminho para nosso terraform (usaremos na seção de ferramentas do Terraform)
```sh
which terraform
```
## Configurar Java e Terraform na configuração de ferramenta global

Goto Manage Jenkins → Tools → Install JDK(17) → Click on Apply and Save
Tools --> Terraform
Apply and save.

## Configurar o servidor Sonar em Manage Jenkins
Pegue o endereço IP público da sua instância EC2, o Sonarqube funciona na porta 9000, então <IP público>:9000. Vá para o seu servidor Sonarqube. Clique em Administração → Segurança → Usuários → Clique em Tokens e Token de Atualização → Dê um nome → e clique em Gerar Token

- click on update Token
- Create a token with a name and generate
- copy Token

Goto Jenkins Dashboard → Manage Jenkins → Credentials → Add Secret Text

Agora vá para Dashboard → Gerenciar Jenkins → Sistema e Adicionar como na imagem abaixo.

Clique em Aplly e Save

**A opção Configurar Sistema** é usada no Jenkins para configurar diferentes servidores

**A configuração global da ferramenta** é usada para configurar diferentes ferramentas que instalamos usando plug-ins

Instalaremos um scanner sonar nas ferramentas.

In the Sonarqube Dashboard add a quality gate also

Administration--> Configuration-->Webhooks

Click on Create

Add details
```sh
#in url section of quality gate
<http://jenkins-public-ip:8080>/sonarqube-webhook/
```
## crie um bucket IAM, S3 e uma tabela Dynamodb.

Navegue até o CONSOLE AWS

Clique no campo "Search field".

Type "IAM enter"

Click "Roles"

Click "Create role"

Click "AWS service"

Click "Choose a service or use case"

Click "EC2"

Click "Next"

Click the "Search" field.

Add permissions policies

AmazonEC2FullAccess

Click the "Search" field.

AmazonS3FullAccess

**Search**

AmazonDynamoDBFullAccess

click Next

Click the "Role name" field.

Type "Jenkins-cicd"

Click "Create role"

Click "EC2"

vá para a instância Jenkins e adicione esta função à instância Ec2.

select Jenkins instance --> Actions --> Security --> Modify IAM role

Add a newly created Role and click on Update IAM role.

Search for S3 in console

Click "Create bucket"

Click the "Bucket name" field.

Nada a alterar, mantenha o padrão restante.

Click "Create bucket", Bucket will be created.

Click the "Search" field. Search for DynamoDB and click on it.

Click "Create table"

Click the "Table name" field. enter "dynamodb_table = "mrcloudbook-dynamo-db-table""

Click the "Enter the partition key name" field.

Type "LockID"

Click "Create table"

## Docker Plugin setup

Precisamos instalar a ferramenta Docker em nosso sistema, vá para  Dashboard → Manage Plugins → Available plugins → Search for Docker and install these plugins

`Docker`

`Docker Commons`

`Docker Pipeline`

`Docker API`

`docker-build-step`

click em  install e restart

Agora vá para Dashboard → Manage Jenkins → Tools →
Adicione nome de usuário e senha do DockerHub em credenciais globais

Vamos verificar o código do Terraform agora.

Backend.tf
```sh
terraform {
  backend "s3" {
    bucket         = "ajay-mrcloudbook777"   #change name
    key            = "my-terraform-environment/main"
    region         = "ap-south-1"
    dynamodb_table = "mrcloudbook-dynamo-db-table"
  }
}
```
provider.tf
```sh
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}
```
main.tf
```sh
resource "aws_instance" "Ajay" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  user_data              = base64encode(file("website.sh"))
  tags = {
    Name = "Aj-EC2"
  }
}

resource "aws_security_group" "ec2_security_group" {
  name        = "ec2 security group"
  description = "allow access on ports 80 and 22 and 443"

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0    # Allow all ports
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "https"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Aj_sg"
  }
}
```
s3.tf
```sh
#create s3 bucket
resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucketname
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.mybucket.id
  acl    = "public-read"
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.mybucket.id
  key = "index.html"
  source = "index.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.mybucket.id
  key = "error.html"
  source = "error.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "style" {
  bucket = aws_s3_bucket.mybucket.id
  key = "style.css"
  source = "style.css"
  acl = "public-read"
  content_type = "text/css"
}

resource "aws_s3_object" "script" {
  bucket = aws_s3_bucket.mybucket.id
  key = "script.js"
  source = "script.js"
  acl = "public-read"
  content_type = "text/javascript"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.mybucket.id
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [ aws_s3_bucket_acl.example.id ]
}
```

variables.tf
```sh
variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "ap-south-1"
}
variable "key_name" {
  description = " SSH keys to connect to ec2 instance"
  default     = "Mumbai"     #change key name here
}
variable "instance_type" {
  description = "instance type for ec2"
  default     = "t2.medium"
}
variable "ami_id" {
  description = "AMI for Ubuntu Ec2 instance"
  default     = "ami-0f5ee92e2d63afc18"
}
variable "bucketname" {
  description = "The name of the S3 bucket to create"
  type        = string
  default     = "ajaykumar-yegireddi-cloud"  #change Bucket name also
}
```
Dados do usuário para instância

website.sh
```sh
#!/bin/bash

# Update the package manager and install Docker
sudo apt-get update -y
sudo apt-get install -y docker.io

# Start the Docker service
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Pull and run a simple Nginx web server container
sudo docker run -d --name zomato -p 3000:3000 sevenajay/zomato:latest
sudo docker run -d --name netflix -p 8081:80 sevenajay/netflix:latest
```
index.html
```sh
HTML CSS JSResult Skip Results Iframe
<!DOCTYPE html>
<html lang="en" >
<head>
  <meta charset="UTF-8">
  <title> Login Page Form | Nothing4us</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/meyer-reset/2.0/reset.min.css">
<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css'><link rel="stylesheet" href="./style.css">

</head>
<body>
<!-- partial:index.partial.html -->
<div class="center">
  <div class="ear ear--left"></div>
  <div class="ear ear--right"></div>
  <div class="face">
    <div class="eyes">
      <div class="eye eye--left">
        <div class="glow"></div>
      </div>
      <div class="eye eye--right">
        <div class="glow"></div>
      </div>
    </div>
    <div class="nose">
      <svg width="38.161" height="22.03">
        <path d="M2.017 10.987Q-.563 7.513.157 4.754C.877 1.994 2.976.135 6.164.093 16.4-.04 22.293-.022 32.048.093c3.501.042 5.48 2.081 6.02 4.661q.54 2.579-2.051 6.233-8.612 10.979-16.664 11.043-8.053.063-17.336-11.043z" fill="#243946"></path>
      </svg>
      <div class="glow"></div>
    </div>
    <div class="mouth">
      <svg class="smile" viewBox="-2 -2 84 23" width="84" height="23">
        <path d="M0 0c3.76 9.279 9.69 18.98 26.712 19.238 17.022.258 10.72.258 28 0S75.959 9.182 79.987.161" fill="none" stroke-width="3" stroke-linecap="square" stroke-miterlimit="3"></path>
      </svg>
      <div class="mouth-hole"></div>
      <div class="tongue breath">
        <div class="tongue-top"></div>
        <div class="line"></div>
        <div class="median"></div>
      </div>
    </div>
  </div>
  <div class="hands">
    <div class="hand hand--left">
      <div class="finger">
        <div class="bone"></div>
        <div class="nail"></div>
      </div>
      <div class="finger">
        <div class="bone"></div>
        <div class="nail"></div>
      </div>
      <div class="finger">
        <div class="bone"></div>
        <div class="nail"></div>
      </div>
    </div>
    <div class="hand hand--right">
      <div class="finger">
        <div class="bone"></div>
        <div class="nail"></div>
      </div>
      <div class="finger">
        <div class="bone"></div>
        <div class="nail"></div>
      </div>
      <div class="finger">
        <div class="bone"></div>
        <div class="nail"></div>
      </div>
    </div>
  </div>
  <div class="login">
    <label>
      <div class="fa fa-phone"></div>
      <input class="username" type="text" autocomplete="on" placeholder="Username"/>
    </label>
    <label>
      <div class="fa fa-commenting"></div>
      <input class="password" type="password" autocomplete="off" placeholder="Password"/>
      <button class="password-button">Show</button>
    </label>
    <button class="login-button">Login</button>
  </div>
  <div class="social-buttons">
    <div class="social">
      <div class="fa fa-wechat"></div>
    </div>
    <div class="social">
      <div class="fa fa-weibo"></div>
    </div>
    <div class="social">
      <div class="fa fa-paw"></div>
    </div>
  </div>
  <div class="footer">Mr.Cloud Book</div>

  <script src='https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.17.5/lodash.min.js'></script><script  src="./script.js"></script>

</body>
</html>
```
error.html
```sh
<!DOCTYPE html>
<html lang="en" >
<head>
  <meta charset="UTF-8">
  <title> 404 page | Nothing4us </title>
  <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.7/css/bootstrap.min.css'>
<link rel='stylesheet' href='https://fonts.googleapis.com/css?family=Arvo'><link rel="stylesheet" href="./style.css">

</head>
<body>
<!-- partial:index.partial.html -->
<section class="page_404">
    <div class="container">
        <div class="row">    
        <div class="col-sm-12 ">
        <div class="col-sm-10 col-sm-offset-1  text-center">
        <div class="four_zero_four_bg">
            <h1 class="text-center ">404</h1>


        </div>

        <div class="contant_box_404">
        <h3 class="h2">
        Look like you're lost
        </h3>

        <p>the page you are looking for not avaible!</p>

        <a href="" class="link_404">Go to Home</a>
    </div>
        </div>
        </div>
        </div>
    </div>
</section>
<!-- partial -->  
</body>
</html>
```
style.css
```sh
* {
    box-sizing: border-box;
  }
  body {
    width: 100vw;
    height: 100vh;
    background-color: rgb(41, 0, 75);
    overflow: hidden;
    font-size: 12px;
  }
  .inspiration {
    position: fixed;
    bottom: 0;
    right: 0;
    padding: 10px;
    text-align: center;
    text-decoration: none;
    font-family: 'Gill Sans', sans-serif;
    font-size: 12px;
    color: #969696;
  }
  .inspiration img {
    width: 60px;
  }
  .center {
    position: relative;
    top: 50%;
    left: 50%;
    display: inline-block;
    width: 275px;
    height: 490px;
    border-radius: 3px;
    transform: translate(-50%, -50%);
    overflow: hidden;
    background-image: linear-gradient(to top right, rgb(0 168 255), rgb(249 95 230));
  }
  @media screen and (max-height: 500px) {
    .center {
      transition: transform 0.5s;
      transform: translate(-50%, -50%) scale(0.8);
    }
  }
  .center .ear {
    position: absolute;
    top: -110px;
    width: 200px;
    height: 200px;
    border-radius: 50%;
    background-color: rgb(50 22 22);
  }
  .center .ear.ear--left {
    left: -135px;
  }
  .center .ear.ear--right {
    right: -135px;
  }
  .center .face {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 200px;
    height: 150px;
    margin: 80px auto 10px;
    --rotate-head: 0deg;
    transform: rotate(var(--rotate-head));
    transition: transform 0.2s;
    transform-origin: center 20px;
  }
  .center .eye {
    display: inline-block;
    width: 25px;
    height: 25px;
    border-radius: 50%;
    background-color: #243946;
  }
  .center .eye.eye--left {
    margin-right: 40px;
  }
  .center .eye.eye--right {
    margin-left: 40px;
  }
  .center .eye .glow {
    position: relative;
    top: 3px;
    right: -12px;
    width: 12px;
    height: 6px;
    border-radius: 50%;
    background-color: #fff;
    transform: rotate(38deg);
  }
  .center .nose {
    position: relative;
    top: 30px;
    transform: scale(1.1);
  }
  .center .nose .glow {
    position: absolute;
    top: 3px;
    left: 32%;
    width: 15px;
    height: 8px;
    border-radius: 50%;
    background-color: #476375;
  }
  .center .mouth {
    position: relative;
    margin-top: 45px;
  }
  .center svg.smile {
    position: absolute;
    left: -28px;
    top: -19px;
    transform: scaleX(1.1);
    stroke: #243946;
  }
  .center .mouth-hole {
    position: absolute;
    top: 0;
    left: -50%;
    width: 60px;
    height: 15px;
    border-radius: 50%/100% 100% 0% 0;
    transform: rotate(180deg);
    background-color: #243946;
    z-index: -1;
  }
  .center .tongue {
    position: relative;
    top: 5px;
    width: 30px;
    height: 20px;
    background-color: #ffd7dd;
    transform-origin: top;
    transform: rotateX(60deg);
  }
  .center .tongue.breath {
    -webkit-animation: breath 0.3s infinite linear;
            animation: breath 0.3s infinite linear;
  }
  .center .tongue-top {
    position: absolute;
    bottom: -15px;
    width: 30px;
    height: 30px;
    border-radius: 15px;
    background-color: #ffd7dd;
  }
  .center .line {
    position: absolute;
    top: 0;
    width: 30px;
    height: 5px;
    background-color: #fcb7bf;
  }
  .center .median {
    position: absolute;
    top: 0;
    left: 50%;
    transform: translateX(-50%);
    width: 4px;
    height: 25px;
    border-radius: 5px;
    background-color: #fcb7bf;
  }
  .center .hands {
    position: relative;
  }
  .center .hands .hand {
    position: absolute;
    top: -6px;
    display: flex;
    transition: transform 0.5s ease-in-out;
    z-index: 1;
  }
  .center .hands .hand--left {
    left: 50px;
  }
  .center .hands .hand--left.hide {
    transform: translate(2px, -155px) rotate(-160deg);
  }
  .center .hands .hand--left.peek {
    transform: translate(0px, -120px) rotate(-160deg);
  }
  .center .hands .hand--right {
    left: 170px;
  }
  .center .hands .hand--right.hide {
    transform: translate(-6px, -155px) rotate(160deg);
  }
  .center .hands .hand--right.peek {
    transform: translate(-4px, -120px) rotate(160deg);
  }
  .center .hands .finger {
    position: relative;
    z-index: 0;
  }
  .center .hands .finger .bone {
    width: 20px;
    height: 20px;
    border: 2px solid #243946;
    border-bottom: none;
    border-top: none;
    background-color: rgb(255 211 11);
  }
  .center .hands .finger .nail {
    position: absolute;
    left: 0;
    top: 10px;
    width: 20px;
    height: 18px;
    border-radius: 50%;
    border: 2px solid #243946;
    background-color: #fac555;
    z-index: -1;
  }
  .center .hands .finger:nth-child(1),
  .center .hands .finger:nth-child(3) {
    left: 4px;
    z-index: 1;
  }
  .center .hands .finger:nth-child(1) .bone,
  .center .hands .finger:nth-child(3) .bone {
    height: 10px;
  }
  .center .hands .finger:nth-child(3) {
    left: -4px;
  }
  .center .hands .finger:nth-child(2) {
    top: -5px;
    z-index: 2;
  }
  .center .hands .finger:nth-child(1) .nail,
  .center .hands .finger:nth-child(3) .nail {
    top: 0px;
  }
  .center .login {
    position: relative;
    display: flex;
    flex-direction: column;
  }
  .center .login label {
    position: relative;
    padding: 0 20px;
  }
  .center .login label .fa {
    position: absolute;
    top: 40%;
    left: 35px;
    color: #bbb;
  }
  .center .login label .fa:before {
    position: relative;
    left: 1px;
  }
  .center .login input,
  .center .login .login-button {
    width: 100%;
    height: 35px;
    border: none;
    border-radius: 30px;
  }
  .center .login input {
    padding: 0 20px 0 40px;
    margin: 5px 0;
    box-shadow: none;
    outline: none;
  }
  .center .login input::-moz-placeholder {
    color: #ccc;
  }
  .center .login input:-ms-input-placeholder {
    color: #ccc;
  }
  .center .login input::placeholder {
    color: #ccc;
  }
  .center .login input.password {
    padding: 0 90px 0 40px;
  }
  .center .login .password-button {
    position: absolute;
    top: 9px;
    right: 25px;
    display: flex;
    justify-content: center;
    align-items: center;
    width: 80px;
    height: 27px;
    border-radius: 30px;
    border: none;
    outline: none;
    background-color: #243946;
    color: #fff;
  }
  .center .login .password-button:active {
    transform: scale(0.95);
  }
  .center .login .login-button {
    width: calc(100% - 40px);
    margin: 20px 20px 0;
    outline: none;
    background-color: #243946;
    color: #fff;
    transition: transform 0.1s;
  }
  .center .login .login-button:active {
    transform: scale(0.95);
  }
  .center .social-buttons {
    display: flex;
    justify-content: center;
    margin-top: 25px;
  }
  .center .social-buttons .social {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 35px;
    height: 35px;
    margin: 0 10px;
    border-radius: 50%;
    background-color: #243946;
    color: #fff;
    font-size: 18px;
  }
  .center .social-buttons .social:active {
    transform: scale(0.95);
  }
  .center .footer {
    text-align: center;
    margin-top: 15px;
  }
  @-webkit-keyframes breath {
    0%, 100% {
      transform: rotateX(0deg);
    }
    50% {
      transform: rotateX(60deg);
    }
  }
  @keyframes breath {
    0%, 100% {
      transform: rotateX(0deg);
    }
    50% {
      transform: rotateX(60deg);
    }
  }
```
script.js
```sh
let usernameInput = document.querySelector('.username');
let passwordInput = document.querySelector('.password');
let showPasswordButton = document.querySelector('.password-button');
let face = document.querySelector('.face');

passwordInput.addEventListener('focus', event => {
  document.querySelectorAll('.hand').forEach(hand => {
    hand.classList.add('hide');
  });
  document.querySelector('.tongue').classList.remove('breath');
});

passwordInput.addEventListener('blur', event => {
  document.querySelectorAll('.hand').forEach(hand => {
    hand.classList.remove('hide');
    hand.classList.remove('peek');
  });
  document.querySelector('.tongue').classList.add('breath');
});

usernameInput.addEventListener('focus', event => {
  let length = Math.min(usernameInput.value.length - 16, 19);
  document.querySelectorAll('.hand').forEach(hand => {
    hand.classList.remove('hide');
    hand.classList.remove('peek');
  });

  face.style.setProperty('--rotate-head', `${-length}deg`);
});

usernameInput.addEventListener('blur', event => {
  face.style.setProperty('--rotate-head', '0deg');
});

usernameInput.addEventListener('input', _.throttle(event => {
  let length = Math.min(event.target.value.length - 16, 19);

  face.style.setProperty('--rotate-head', `${-length}deg`);
}, 100));

showPasswordButton.addEventListener('click', event => {
  if (passwordInput.type === 'text') {
    passwordInput.type = 'password';
    document.querySelectorAll('.hand').forEach(hand => {
      hand.classList.remove('peek');
      hand.classList.add('hide');
    });
  } else {
    passwordInput.type = 'text';
    document.querySelectorAll('.hand').forEach(hand => {
      hand.classList.remove('hide');
      hand.classList.add('peek');
    });
  }
});
```
Agora vamos criar um Job no jnekins
defina um nome do job e adicione este na pipeline

```sh
pipeline{
    agent any
    tools{
        jdk 'jdk17'
        terraform 'terraform'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
    }
    stages {
        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout from Git'){
            steps{
                git branch: 'main', url: 'https://github.com/Aj7Ay/TERRAFORM-JENKINS-CICD.git'
            }
        }
        stage('Terraform version'){
             steps{
                 sh 'terraform --version'
                }
        }
        stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Terraform \
                    -Dsonar.projectKey=Terraform '''
                }
            }
        }
        stage("quality gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token' 
                }
            } 
        }
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
    }
}
```
temos que fornecer permissões executáveis para nossos dados de usuário, caso contrário eles não serão executados.

Se executarmos o sudo diretamente, obteremos o erro

Para conceder permissões sudo a um usuário em um sistema Ubuntu, você precisa adicionar o usuário ao grupo sudo ou conceder-lhe acesso sudo específico editando o arquivo sudoers. Aqui estão duas maneiras comuns de conceder permissões sudo a um usuário:

### Método 1: Adicionar usuário ao grupo sudo

1.Faça login em seu sistema Ubuntu como um usuário com privilégios sudo ou faça login como usuário root.

2.Abra um terminal.

3.Execute o seguinte comando para adicionar um usuário (substitua <username> pelo nome de usuário real) ao grupo `sudo`:
```sh
 sudo usermod -aG sudo ubuntu
```
4.Após executar o comando, o usuário terá privilégios sudo. Agora eles podem executar comandos com privilégios de superusuário usando `sudo`.

### Método 2: edite o arquivo sudoers

Em alguns casos, você pode querer um controle mais refinado sobre as permissões sudo de um usuário. Para fazer isso, você pode editar o arquivo sudoers usando o comando visudo:

1.Faça login em seu sistema Ubuntu como um usuário com privilégios sudo ou faça login como usuário root.

2.Abra um terminal.

3.Execute o seguinte comando para editar o arquivo sudoers:
```sh
 sudo visudo
```
4.Isso abrirá o arquivo sudoers em um editor de texto. Não use um editor de texto comum para editar este arquivo; sempre use visudo para evitar erros de sintaxe.

5.Role para baixo até a seção que define os privilégios do usuário. Normalmente você encontrará uma linha parecida com esta:

6.Abaixo dessa linha, você pode conceder privilégios sudo a um usuário específico. Para conceder acesso sudo completo a um usuário, adicione a seguinte linha (substitua <username> pelo nome de usuário real):

```sh
 <username> ALL=(ALL:ALL) ALL
```
Se quiser limitar o acesso sudo a comandos específicos, você pode especificar esses comandos em vez de TODOS.

7.Salve e saia do editor de texto. Na maioria dos sistemas, você pode salvar e sair do` visudo` pressionando `Ctrl + X`, seguido de` Y` e depois `Enter`.

Depois de concluir um desses métodos, o usuário deverá ter permissões sudo e poderá executar comandos com privilégios de superusuário usando `sudo`. Tenha cuidado ao conceder acesso sudo aos usuários, pois isso pode fornecer a eles um controle significativo sobre o sistema.

Depois de conceder permissões `sudo` a um usuário em um sistema Ubuntu, você não precisa reiniciar o sistema para que as alterações tenham efeito. O usuário pode começar imediatamente a usar o sudo para executar comandos com privilégios de superusuário.

Para testar se o usuário pode usar o `sudo`, basta abrir um terminal e fazer com que o usuário execute um comando com o `sudo`. Por exemplo:

```sh
sudo apt update
```
Se for solicitada a senha do usuário e o comando for executado sem erros, significa que as permissões sudo foram concedidas e aplicadas com sucesso.

Não há necessidade de reiniciar o sistema para aplicar alterações nas permissões sudo.

Agora adicione os estágios abaixo a sua pipeline
```sh
       stage('Excutable permission to userdata'){
            steps{
                sh 'chmod 777 website.sh'
            }
        }
        stage('Terraform init'){
            steps{
                sh 'terraform init'
            }
        }
        stage('Terraform plan'){
            steps{
                sh 'terraform plan'
            }
        }
```
você deseja adicionar uma verificação de segurança para arquivos `terraform` que também funcione bem, mas se usarmos isso agora, obteremos muitos erros. porque acabamos de escrever arquivos terraform simples e é por isso que gera erros. temos` aqua` `tfsec` e `checkov` para varredura de `terraform`.

install aqua security `tfsec`
```sh
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
```
Adicione este estágio. Para este projeto, nosso propósito de aprendizagem não é recomendado.

```sh
stage('Trivy terraform scan'){
    steps{
        sh 'tfsec . --no-color'
       }
   }
```
Vamos continuar sem essa etapa.

Adicione este estágio ao pipeline
```sh
stage('Terraform apply'){
            steps{
                sh 'terraform apply --auto-approve'
            }
        }
```
você terá sucesso, mas quero fazer isso com parâmetros de construção para aplicar e destruir apenas durante a construção.

você tem que adicionar este trabalho interno como a imagem abaixo
```sh
stage('Terraform apply'){
            steps{
                sh 'terraform ${action} --auto-approve'
            }
        }
```
Enquanto estiver no estágio de aplicação, ele automaticamente pega a opção de aplicação e cria infraestrutura na AWS e executa contêineres

Agora copie o endereço IP da instância recém-criado
```sh
<instance-ip:3000> #zomato app container
```
```sh
<instance-ip:8081> #netflix container
```

Confira se o bucket S3 foi criado ou não
Verifique seu bucket s3 em busca do arquivo de state.tf com o nome main

Vamos destruir tudo
enquanto está na fase de aplicação, ele automaticamente pega a opção destruir e exclui tudo o que criamos até agora.

## pipeline completa:
```sh
pipeline{
    agent any
    tools{
        jdk 'jdk17'
        terraform 'terraform'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
    }
    stages {
        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout from Git'){
            steps{
                git branch: 'main', url: 'https://github.com/Aj7Ay/TERRAFORM-JENKINS-CICD.git'
            }
        }
        stage('Terraform version'){
             steps{
                 sh 'terraform --version'
                }
        }
        stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Terraform \
                    -Dsonar.projectKey=Terraform '''
                }
            }
        }
        stage("quality gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token' 
                }
            } 
        }
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
        stage('Excutable permission to userdata'){
            steps{
                sh 'chmod 777 website.sh'
            }
        }
        stage('Terraform init'){
            steps{
                sh 'terraform init'
            }
        }
        stage('Terraform plan'){
            steps{
                sh 'terraform plan'
            }
        }
        stage('Terraform apply'){
            steps{
                sh 'terraform ${action} --auto-approve'
            }
        }
    }
}
```
