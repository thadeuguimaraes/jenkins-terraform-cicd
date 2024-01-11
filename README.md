### WEBSITE STATICO USANDO S3 COM TERRAFORM NA AWS

![JENKINSCICD1](https://github.com/thadeuguimaraes/jenkins-terraform-cicd/assets/52017205/d14dc8c5-60fa-4312-a563-316e8d214cc2)

## Web site Static no S3
![s3](https://github.com/thadeuguimaraes/jenkins-terraform-cicd/assets/52017205/eae6c5a3-c3ce-41ef-846d-6c2b94dd3658)

No atual mundo acelerado da computação em nuvem, a capacidade de provisionar infraestrutura de forma rápida e eficiente é uma virada de jogo. É aqui que entra a Infraestrutura como Código (IaC), permitindo-nos definir e gerenciar nossa infraestrutura de maneira baseada em código. Nesta postagem do blog, exploraremos como aproveitar o poder do IaC usando duas ferramentas essenciais: Terraform e Jenkins, em conjunto com Amazon Web Services (AWS).

Terraform é uma ferramenta IaC de código aberto que nos permite definir, criar e gerenciar nossa infraestrutura usando arquivos de configuração declarativos. Jenkins, por outro lado, é um servidor de automação amplamente adotado que ajuda a agilizar o processo de desenvolvimento e implantação de software.

Nossa jornada abrangerá vários objetivos principais:

1.Setting up Terraform and Jenkins: We'll start by ensuring you have all the prerequisites in place, including an AWS account, Terraform, Jenkins, and Docker. We'll walk you through the installation and configuration of these essential tools.

Creating the Terraform Scripts: We'll delve into the heart of IaC by crafting Terraform scripts to provision AWS resources. Along the way, we'll introduce the concept of user data, a powerful feature that allows us to automate tasks like launching containers within our instances.

Running Two Application Containers with User Data: To demonstrate the practical application of user data, we'll guide you through launching not just one but two application containers within your AWS instances. This step showcases the versatility and automation capabilities of IaC.

DevOps project we will be using Terraform and AWS Cloud to set up static website hosting fully automated in seconds. This Terraform project will help beginners understand the concept and working of Terraform with AWS and how you can create a one-click automated solution using Terraform in DevOps
