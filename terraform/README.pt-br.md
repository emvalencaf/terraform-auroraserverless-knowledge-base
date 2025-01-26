# Documentação do Projeto Terraform Bedrock Knowledge Base

[![English version](https://img.shields.io/badge/lang-en-red.svg)](/terraform/README.md)
&nbsp;&nbsp;
[![Portuguese version](https://img.shields.io/badge/lang-pt--br-green.svg)](/terraform/README.pt-br.md)

![Diagram Terraform Flow](/docs/terraform_flow.png)
![Diagrama do Fluxo do Terraform](/docs/terraform_flow.png)

Este projeto Terraform automatiza a criação da infraestrutura para uma Base de Conhecimento AWS Bedrock. Facilitando a sua implementação como um módulo a projetos mais complexos para a aceleração. Ele inclui:
- **Base de Conhecimento**: Configurada com RDS para armazenamento e S3 para fontes de dados.
- **Funções e Políticas IAM**: Garantem acesso seguro aos serviços da AWS.
- **Funções Lambda**: Automatizam a inicialização do banco de dados.
- **RDS Aurora Serverless**: Hospeda dados estruturados para a configuração da base de conhecimento vetorial.
- **Bucket S3**: Armazena dados para ingestão na base de conhecimento.

![Diagrama da Arquitetura AWS da Knowledge Base com o Aurora Serverless](/docs/aws_architecture.png)

## Sumário

- [README Inicial](/README.md)
- [README do Terraform](/terraform/README.md)
- [README da Função Lambda de Inicialização do Banco de Dados](/app/database_init_lambda/README.md)

## Estrutura do Projeto

```
|__ artifacts/
|__ modules/
|    |__ bedrock/
|    |     |__ main.py
|    |     |__ output.py
|    |     |__ variables.py
|    |__ iam/
|    |     |__ main.py
|    |     |__ output.py
|    |     |__ variables.py
|    |__ lambda/
|    |    |__ main.py
|    |    |__ output.py
|    |    |__ variables.py
|    |__ rds/
|         |__ main.py
|         |__ output.py
|         |__ variables.py     
|__ main.tf
|__ variables.tf
```

## Requerimentos
![Terraform](https://img.shields.io/badge/terraform-1.10.0-blue.svg?logo=terraform)
&nbsp;&nbsp;
![AWS CLI](https://img.shields.io/badge/aws&nbsp;cli-2.22.7-blue.svg?logo=data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCEtLSBVcGxvYWRlZCB0bzogU1ZHIFJlcG8sIHd3dy5zdmdyZXBvLmNvbSwgR2VuZXJhdG9yOiBTVkcgUmVwbyBNaXhlciBUb29scyAtLT4KPHN2ZyB3aWR0aD0iODAwcHgiIGhlaWdodD0iODAwcHgiIHZpZXdCb3g9IjAgLTUxLjUgMjU2IDI1NiIgdmVyc2lvbj0iMS4xIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiBwcmVzZXJ2ZUFzcGVjdFJhdGlvPSJ4TWlkWU1pZCI+CgkJPGc+CgkJCQk8cGF0aCBkPSJNNzIuMzkyMDUzLDU1LjQzODQxMDYgQzcyLjM5MjA1Myw1OC41NzQ4MzQ0IDcyLjczMTEyNTgsNjEuMTE3ODgwOCA3My4zMjQ1MDMzLDYyLjk4Mjc4MTUgQzc0LjAwMjY0OSw2NC44NDc2ODIxIDc0Ljg1MDMzMTEsNjYuODgyMTE5MiA3Ni4wMzcwODYxLDY5LjA4NjA5MjcgQzc2LjQ2MDkyNzIsNjkuNzY0MjM4NCA3Ni42MzA0NjM2LDcwLjQ0MjM4NDEgNzYuNjMwNDYzNiw3MS4wMzU3NjE2IEM3Ni42MzA0NjM2LDcxLjg4MzQ0MzcgNzYuMTIxODU0Myw3Mi43MzExMjU4IDc1LjAxOTg2NzUsNzMuNTc4ODA3OSBMNjkuNjc5NDcwMiw3Ny4xMzkwNzI4IEM2OC45MTY1NTYzLDc3LjY0NzY4MjEgNjguMTUzNjQyNCw3Ny45MDE5ODY4IDY3LjQ3NTQ5NjcsNzcuOTAxOTg2OCBDNjYuNjI3ODE0Niw3Ny45MDE5ODY4IDY1Ljc4MDEzMjUsNzcuNDc4MTQ1NyA2NC45MzI0NTAzLDc2LjcxNTIzMTggQzYzLjc0NTY5NTQsNzUuNDQzNzA4NiA2Mi43Mjg0NzY4LDc0LjA4NzQxNzIgNjEuODgwNzk0Nyw3Mi43MzExMjU4IEM2MS4wMzMxMTI2LDcxLjI5MDA2NjIgNjAuMTg1NDMwNSw2OS42Nzk0NzAyIDU5LjI1Mjk4MDEsNjcuNzI5ODAxMyBDNTIuNjQxMDU5Niw3NS41Mjg0NzY4IDQ0LjMzMzc3NDgsNzkuNDI3ODE0NiAzNC4zMzExMjU4LDc5LjQyNzgxNDYgQzI3LjIxMDU5Niw3OS40Mjc4MTQ2IDIxLjUzMTEyNTgsNzcuMzkzMzc3NSAxNy4zNzc0ODM0LDczLjMyNDUwMzMgQzEzLjIyMzg0MTEsNjkuMjU1NjI5MSAxMS4xMDQ2MzU4LDYzLjgzMDQ2MzYgMTEuMTA0NjM1OCw1Ny4wNDkwMDY2IEMxMS4xMDQ2MzU4LDQ5Ljg0MzcwODYgMTMuNjQ3NjgyMSw0My45OTQ3MDIgMTguODE4NTQzLDM5LjU4Njc1NSBDMjMuOTg5NDA0LDM1LjE3ODgwNzkgMzAuODU1NjI5MSwzMi45NzQ4MzQ0IDM5LjU4Njc1NSwzMi45NzQ4MzQ0IEM0Mi40Njg4NzQyLDMyLjk3NDgzNDQgNDUuNDM1NzYxNiwzMy4yMjkxMzkxIDQ4LjU3MjE4NTQsMzMuNjUyOTgwMSBDNTEuNzA4NjA5MywzNC4wNzY4MjEyIDU0LjkyOTgwMTMsMzQuNzU0OTY2OSA1OC4zMjA1Mjk4LDM1LjUxNzg4MDggTDU4LjMyMDUyOTgsMjkuMzI5ODAxMyBDNTguMzIwNTI5OCwyMi44ODc0MTcyIDU2Ljk2NDIzODQsMTguMzk0NzAyIDU0LjMzNjQyMzgsMTUuNzY2ODg3NCBDNTEuNjIzODQxMSwxMy4xMzkwNzI4IDQ3LjA0NjM1NzYsMTEuODY3NTQ5NyA0MC41MTkyMDUzLDExLjg2NzU0OTcgQzM3LjU1MjMxNzksMTEuODY3NTQ5NyAzNC41MDA2NjIzLDEyLjIwNjYyMjUgMzEuMzY0MjM4NCwxMi45Njk1MzY0IEMyOC4yMjc4MTQ2LDEzLjczMjQ1MDMgMjUuMTc2MTU4OSwxNC42NjQ5MDA3IDIyLjIwOTI3MTUsMTUuODUxNjU1NiBDMjAuODUyOTgwMSwxNi40NDUwMzMxIDE5LjgzNTc2MTYsMTYuNzg0MTA2IDE5LjI0MjM4NDEsMTYuOTUzNjQyNCBDMTguNjQ5MDA2NiwxNy4xMjMxNzg4IDE4LjIyNTE2NTYsMTcuMjA3OTQ3IDE3Ljg4NjA5MjcsMTcuMjA3OTQ3IEMxNi42OTkzMzc3LDE3LjIwNzk0NyAxNi4xMDU5NjAzLDE2LjM2MDI2NDkgMTYuMTA1OTYwMywxNC41ODAxMzI1IEwxNi4xMDU5NjAzLDEwLjQyNjQ5MDEgQzE2LjEwNTk2MDMsOS4wNzAxOTg2OCAxNi4yNzU0OTY3LDguMDUyOTgwMTMgMTYuNjk5MzM3Nyw3LjQ1OTYwMjY1IEMxNy4xMjMxNzg4LDYuODY2MjI1MTcgMTcuODg2MDkyNyw2LjI3Mjg0NzY4IDE5LjA3Mjg0NzcsNS42Nzk0NzAyIEMyMi4wMzk3MzUxLDQuMTUzNjQyMzggMjUuNiwyLjg4MjExOTIxIDI5Ljc1MzY0MjQsMS44NjQ5MDA2NiBDMzMuOTA3Mjg0OCwwLjc2MjkxMzkwNyAzOC4zMTUyMzE4LDAuMjU0MzA0NjM2IDQyLjk3NzQ4MzQsMC4yNTQzMDQ2MzYgQzUzLjA2NDkwMDcsMC4yNTQzMDQ2MzYgNjAuNDM5NzM1MSwyLjU0MzA0NjM2IDY1LjE4Njc1NSw3LjEyMDUyOTggQzY5Ljg0OTAwNjYsMTEuNjk4MDEzMiA3Mi4yMjI1MTY2LDE4LjY0OTAwNjYgNzIuMjIyNTE2NiwyNy45NzM1MDk5IEw3Mi4yMjI1MTY2LDU1LjQzODQxMDYgTDcyLjM5MjA1Myw1NS40Mzg0MTA2IFogTTM3Ljk3NjE1ODksNjguMzIzMTc4OCBDNDAuNzczNTA5OSw2OC4zMjMxNzg4IDQzLjY1NTYyOTEsNjcuODE0NTY5NSA0Ni43MDcyODQ4LDY2Ljc5NzM1MSBDNDkuNzU4OTQwNCw2NS43ODAxMzI1IDUyLjQ3MTUyMzIsNjMuOTE1MjMxOCA1NC43NjAyNjQ5LDYxLjM3MjE4NTQgQzU2LjExNjU1NjMsNTkuNzYxNTg5NCA1Ny4xMzM3NzQ4LDU3Ljk4MTQ1NyA1Ny42NDIzODQxLDU1Ljk0NzAxOTkgQzU4LjE1MDk5MzQsNTMuOTEyNTgyOCA1OC40OTAwNjYyLDUxLjQ1NDMwNDYgNTguNDkwMDY2Miw0OC41NzIxODU0IEw1OC40OTAwNjYyLDQ1LjAxMTkyMDUgQzU2LjAzMTc4ODEsNDQuNDE4NTQzIDUzLjQwMzk3MzUsNDMuOTA5OTMzOCA1MC42OTEzOTA3LDQzLjU3MDg2MDkgQzQ3Ljk3ODgwNzksNDMuMjMxNzg4MSA0NS4zNTA5OTM0LDQzLjA2MjI1MTcgNDIuNzIzMTc4OCw0My4wNjIyNTE3IEMzNy4wNDM3MDg2LDQzLjA2MjI1MTcgMzIuODkwMDY2Miw0NC4xNjQyMzg0IDMwLjA5MjcxNTIsNDYuNDUyOTgwMSBDMjcuMjk1MzY0Miw0OC43NDE3MjE5IDI1LjkzOTA3MjgsNTEuOTYyOTEzOSAyNS45MzkwNzI4LDU2LjIwMTMyNDUgQzI1LjkzOTA3MjgsNjAuMTg1NDMwNSAyNi45NTYyOTE0LDYzLjE1MjMxNzkgMjkuMDc1NDk2Nyw2NS4xODY3NTUgQzMxLjEwOTkzMzgsNjcuMzA1OTYwMyAzNC4wNzY4MjEyLDY4LjMyMzE3ODggMzcuOTc2MTU4OSw2OC4zMjMxNzg4IFogTTEwNi4wNDUwMzMsNzcuNDc4MTQ1NyBDMTA0LjUxOTIwNSw3Ny40NzgxNDU3IDEwMy41MDE5ODcsNzcuMjIzODQxMSAxMDIuODIzODQxLDc2LjYzMDQ2MzYgQzEwMi4xNDU2OTUsNzYuMTIxODU0MyAxMDEuNTUyMzE4LDc0LjkzNTA5OTMgMTAxLjA0MzcwOSw3My4zMjQ1MDMzIEw4MS4xMjMxNzg4LDcuNzk4Njc1NSBDODAuNjE0NTY5NSw2LjEwMzMxMTI2IDgwLjM2MDI2NDksNS4wMDEzMjQ1IDgwLjM2MDI2NDksNC40MDc5NDcwMiBDODAuMzYwMjY0OSwzLjA1MTY1NTYzIDgxLjAzODQxMDYsMi4yODg3NDE3MiA4Mi4zOTQ3MDIsMi4yODg3NDE3MiBMOTAuNzAxOTg2OCwyLjI4ODc0MTcyIEM5Mi4zMTI1ODI4LDIuMjg4NzQxNzIgOTMuNDE0NTY5NSwyLjU0MzA0NjM2IDk0LjAwNzk0NywzLjEzNjQyMzg0IEM5NC42ODYwOTI3LDMuNjQ1MDMzMTEgOTUuMTk0NzAyLDQuODMxNzg4MDggOTUuNzAzMzExMyw2LjQ0MjM4NDExIEwxMDkuOTQ0MzcxLDYyLjU1ODk0MDQgTDEyMy4xNjgyMTIsNi40NDIzODQxMSBDMTIzLjU5MjA1Myw0Ljc0NzAxOTg3IDEyNC4xMDA2NjIsMy42NDUwMzMxMSAxMjQuNzc4ODA4LDMuMTM2NDIzODQgQzEyNS40NTY5NTQsMi42Mjc4MTQ1NyAxMjYuNjQzNzA5LDIuMjg4NzQxNzIgMTI4LjE2OTUzNiwyLjI4ODc0MTcyIEwxMzQuOTUwOTkzLDIuMjg4NzQxNzIgQzEzNi41NjE1ODksMi4yODg3NDE3MiAxMzcuNjYzNTc2LDIuNTQzMDQ2MzYgMTM4LjM0MTcyMiwzLjEzNjQyMzg0IEMxMzkuMDE5ODY4LDMuNjQ1MDMzMTEgMTM5LjYxMzI0NSw0LjgzMTc4ODA4IDEzOS45NTIzMTgsNi40NDIzODQxMSBMMTUzLjM0NTY5NSw2My4yMzcwODYxIEwxNjguMDEwNTk2LDYuNDQyMzg0MTEgQzE2OC41MTkyMDUsNC43NDcwMTk4NyAxNjkuMTEyNTgzLDMuNjQ1MDMzMTEgMTY5LjcwNTk2LDMuMTM2NDIzODQgQzE3MC4zODQxMDYsMi42Mjc4MTQ1NyAxNzEuNDg2MDkzLDIuMjg4NzQxNzIgMTczLjAxMTkyMSwyLjI4ODc0MTcyIEwxODAuODk1MzY0LDIuMjg4NzQxNzIgQzE4Mi4yNTE2NTYsMi4yODg3NDE3MiAxODMuMDE0NTcsMi45NjY4ODc0MiAxODMuMDE0NTcsNC40MDc5NDcwMiBDMTgzLjAxNDU3LDQuODMxNzg4MDggMTgyLjkyOTgwMSw1LjI1NTYyOTE0IDE4Mi44NDUwMzMsNS43NjQyMzg0MSBDMTgyLjc2MDI2NSw2LjI3Mjg0NzY4IDE4Mi41OTA3MjgsNi45NTA5OTMzOCAxODIuMjUxNjU2LDcuODgzNDQzNzEgTDE2MS44MjI1MTcsNzMuNDA5MjcxNSBDMTYxLjMxMzkwNyw3NS4xMDQ2MzU4IDE2MC43MjA1Myw3Ni4yMDY2MjI1IDE2MC4wNDIzODQsNzYuNzE1MjMxOCBDMTU5LjM2NDIzOCw3Ny4yMjM4NDExIDE1OC4yNjIyNTIsNzcuNTYyOTEzOSAxNTYuODIxMTkyLDc3LjU2MjkxMzkgTDE0OS41MzExMjYsNzcuNTYyOTEzOSBDMTQ3LjkyMDUzLDc3LjU2MjkxMzkgMTQ2LjgxODU0Myw3Ny4zMDg2MDkzIDE0Ni4xNDAzOTcsNzYuNzE1MjMxOCBDMTQ1LjQ2MjI1Miw3Ni4xMjE4NTQzIDE0NC44Njg4NzQsNzUuMDE5ODY3NSAxNDQuNTI5ODAxLDczLjMyNDUwMzMgTDEzMS4zOTA3MjgsMTguNjQ5MDA2NiBMMTE4LjMzNjQyNCw3My4yMzk3MzUxIEMxMTcuOTEyNTgzLDc0LjkzNTA5OTMgMTE3LjQwMzk3NCw3Ni4wMzcwODYxIDExNi43MjU4MjgsNzYuNjMwNDYzNiBDMTE2LjA0NzY4Miw3Ny4yMjM4NDExIDExNC44NjA5MjcsNzcuNDc4MTQ1NyAxMTMuMzM1MDk5LDc3LjQ3ODE0NTcgTDEwNi4wNDUwMzMsNzcuNDc4MTQ1NyBaIE0yMTQuOTcyMTg1LDc5Ljc2Njg4NzQgQzIxMC41NjQyMzgsNzkuNzY2ODg3NCAyMDYuMTU2MjkxLDc5LjI1ODI3ODEgMjAxLjkxNzg4MSw3OC4yNDEwNTk2IEMxOTcuNjc5NDcsNzcuMjIzODQxMSAxOTQuMzczNTEsNzYuMTIxODU0MyAxOTIuMTY5NTM2LDc0Ljg1MDMzMTEgQzE5MC44MTMyNDUsNzQuMDg3NDE3MiAxODkuODgwNzk1LDczLjIzOTczNTEgMTg5LjU0MTcyMiw3Mi40NzY4MjEyIEMxODkuMjAyNjQ5LDcxLjcxMzkwNzMgMTg5LjAzMzExMyw3MC44NjYyMjUyIDE4OS4wMzMxMTMsNzAuMTAzMzExMyBMMTg5LjAzMzExMyw2NS43ODAxMzI1IEMxODkuMDMzMTEzLDY0IDE4OS43MTEyNTgsNjMuMTUyMzE3OSAxOTAuOTgyNzgxLDYzLjE1MjMxNzkgQzE5MS40OTEzOTEsNjMuMTUyMzE3OSAxOTIsNjMuMjM3MDg2MSAxOTIuNTA4NjA5LDYzLjQwNjYyMjUgQzE5My4wMTcyMTksNjMuNTc2MTU4OSAxOTMuNzgwMTMyLDYzLjkxNTIzMTggMTk0LjYyNzgxNSw2NC4yNTQzMDQ2IEMxOTcuNTA5OTM0LDY1LjUyNTgyNzggMjAwLjY0NjM1OCw2Ni41NDMwNDY0IDIwMy45NTIzMTgsNjcuMjIxMTkyMSBDMjA3LjM0MzA0Niw2Ny44OTkzMzc3IDIxMC42NDkwMDcsNjguMjM4NDEwNiAyMTQuMDM5NzM1LDY4LjIzODQxMDYgQzIxOS4zODAxMzIsNjguMjM4NDEwNiAyMjMuNTMzNzc1LDY3LjMwNTk2MDMgMjI2LjQxNTg5NCw2NS40NDEwNTk2IEMyMjkuMjk4MDEzLDYzLjU3NjE1ODkgMjMwLjgyMzg0MSw2MC44NjM1NzYyIDIzMC44MjM4NDEsNTcuMzg4MDc5NSBDMjMwLjgyMzg0MSw1NS4wMTQ1Njk1IDIzMC4wNjA5MjcsNTMuMDY0OTAwNyAyMjguNTM1MDk5LDUxLjQ1NDMwNDYgQzIyNy4wMDkyNzIsNDkuODQzNzA4NiAyMjQuMTI3MTUyLDQ4LjQwMjY0OSAyMTkuOTczNTEsNDcuMDQ2MzU3NiBMMjA3LjY4MjExOSw0My4yMzE3ODgxIEMyMDEuNDk0MDQsNDEuMjgyMTE5MiAxOTYuOTE2NTU2LDM4LjQgMTk0LjExOTIwNSwzNC41ODU0MzA1IEMxOTEuMzIxODU0LDMwLjg1NTYyOTEgMTg5Ljg4MDc5NSwyNi43MDE5ODY4IDE4OS44ODA3OTUsMjIuMjk0MDM5NyBDMTg5Ljg4MDc5NSwxOC43MzM3NzQ4IDE5MC42NDM3MDksMTUuNTk3MzUxIDE5Mi4xNjk1MzYsMTIuODg0NzY4MiBDMTkzLjY5NTM2NCwxMC4xNzIxODU0IDE5NS43Mjk4MDEsNy43OTg2NzU1IDE5OC4yNzI4NDgsNS45MzM3NzQ4MyBDMjAwLjgxNTg5NCwzLjk4NDEwNTk2IDIwMy42OTgwMTMsMi41NDMwNDYzNiAyMDcuMDg4NzQyLDEuNTI1ODI3ODEgQzIxMC40Nzk0NywwLjUwODYwOTI3MiAyMTQuMDM5NzM1LDAuMDg0NzY4MjExOSAyMTcuNzY5NTM2LDAuMDg0NzY4MjExOSBDMjE5LjYzNDQzNywwLjA4NDc2ODIxMTkgMjIxLjU4NDEwNiwwLjE2OTUzNjQyNCAyMjMuNDQ5MDA3LDAuNDIzODQxMDYgQzIyNS4zOTg2NzUsMC42NzgxNDU2OTUgMjI3LjE3ODgwOCwxLjAxNzIxODU0IDIyOC45NTg5NCwxLjM1NjI5MTM5IEMyMzAuNjU0MzA1LDEuNzgwMTMyNDUgMjMyLjI2NDkwMSwyLjIwMzk3MzUxIDIzMy43OTA3MjgsMi43MTI1ODI3OCBDMjM1LjMxNjU1NiwzLjIyMTE5MjA1IDIzNi41MDMzMTEsMy43Mjk4MDEzMiAyMzcuMzUwOTkzLDQuMjM4NDEwNiBDMjM4LjUzNzc0OCw0LjkxNjU1NjI5IDIzOS4zODU0Myw1LjU5NDcwMTk5IDIzOS44OTQwNCw2LjM1NzYxNTg5IEMyNDAuNDAyNjQ5LDcuMDM1NzYxNTkgMjQwLjY1Njk1NCw3Ljk2ODIxMTkyIDI0MC42NTY5NTQsOS4xNTQ5NjY4OSBMMjQwLjY1Njk1NCwxMy4xMzkwNzI4IEMyNDAuNjU2OTU0LDE0LjkxOTIwNTMgMjM5Ljk3ODgwOCwxNS44NTE2NTU2IDIzOC43MDcyODUsMTUuODUxNjU1NiBDMjM4LjAyOTEzOSwxNS44NTE2NTU2IDIzNi45MjcxNTIsMTUuNTEyNTgyOCAyMzUuNDg2MDkzLDE0LjgzNDQzNzEgQzIzMC42NTQzMDUsMTIuNjMwNDYzNiAyMjUuMjI5MTM5LDExLjUyODQ3NjggMjE5LjIxMDU5NiwxMS41Mjg0NzY4IEMyMTQuMzc4ODA4LDExLjUyODQ3NjggMjEwLjU2NDIzOCwxMi4yOTEzOTA3IDIwNy45MzY0MjQsMTMuOTAxOTg2OCBDMjA1LjMwODYwOSwxNS41MTI1ODI4IDIwMy45NTIzMTgsMTcuOTcwODYwOSAyMDMuOTUyMzE4LDIxLjQ0NjM1NzYgQzIwMy45NTIzMTgsMjMuODE5ODY3NSAyMDQuOCwyNS44NTQzMDQ2IDIwNi40OTUzNjQsMjcuNDY0OTAwNyBDMjA4LjE5MDcyOCwyOS4wNzU0OTY3IDIxMS4zMjcxNTIsMzAuNjg2MDkyNyAyMTUuODE5ODY4LDMyLjEyNzE1MjMgTDIyNy44NTY5NTQsMzUuOTQxNzIxOSBDMjMzLjk2MDI2NSwzNy44OTEzOTA3IDIzOC4zNjgyMTIsNDAuNjAzOTczNSAyNDAuOTk2MDI2LDQ0LjA3OTQ3MDIgQzI0My42MjM4NDEsNDcuNTU0OTY2OSAyNDQuODk1MzY0LDUxLjUzOTA3MjggMjQ0Ljg5NTM2NCw1NS45NDcwMTk5IEMyNDQuODk1MzY0LDU5LjU5MjA1MyAyNDQuMTMyNDUsNjIuODk4MDEzMiAyNDIuNjkxMzkxLDY1Ljc4MDEzMjUgQzI0MS4xNjU1NjMsNjguNjYyMjUxNyAyMzkuMTMxMTI2LDcxLjIwNTI5OCAyMzYuNTAzMzExLDczLjIzOTczNTEgQzIzMy44NzU0OTcsNzUuMzU4OTQwNCAyMzAuNzM5MDczLDc2Ljg4NDc2ODIgMjI3LjA5NDA0LDc3Ljk4Njc1NSBDMjIzLjI3OTQ3LDc5LjE3MzUwOTkgMjE5LjI5NTM2NCw3OS43NjY4ODc0IDIxNC45NzIxODUsNzkuNzY2ODg3NCBaIiBmaWxsPSIjMjUyRjNFIiBmaWxsLXJ1bGU9Im5vbnplcm8iPgoNPC9wYXRoPgoJCQkJPHBhdGggZD0iTTIzMC45OTMzNzcsMTIwLjk2NDIzOCBDMjAzLjEwNDYzNiwxNDEuNTYyOTE0IDE2Mi41ODU0MywxNTIuNDk4MDEzIDEyNy43NDU2OTUsMTUyLjQ5ODAxMyBDNzguOTE5MjA1MywxNTIuNDk4MDEzIDM0LjkyNDUwMzMsMTM0LjQ0MjM4NCAxLjY5NTM2NDI0LDEwNC40MzQ0MzcgQy0wLjkzMjQ1MDMzMSwxMDIuMDYwOTI3IDEuNDQxMDU5Niw5OC44Mzk3MzUxIDQuNTc3NDgzNDQsMTAwLjcwNDYzNiBDNDAuNTE5MjA1MywxMjEuNTU3NjE2IDg0Ljg1Mjk4MDEsMTM0LjE4ODA3OSAxMzAuNzEyNTgzLDEzNC4xODgwNzkgQzE2MS42NTI5OCwxMzQuMTg4MDc5IDE5NS42NDUwMzMsMTI3Ljc0NTY5NSAyMjYuOTI0NTAzLDExNC41MjE4NTQgQzIzMS41ODY3NTUsMTEyLjQwMjY0OSAyMzUuNTcwODYxLDExNy41NzM1MSAyMzAuOTkzMzc3LDEyMC45NjQyMzggWiBNMjQyLjYwNjYyMywxMDcuNzQwMzk3IEMyMzkuMDQ2MzU4LDEwMy4xNjI5MTQgMjE5LjA0MTA2LDEwNS41MzY0MjQgMjA5Ljk3MDg2MSwxMDYuNjM4NDExIEMyMDcuMjU4Mjc4LDEwNi45Nzc0ODMgMjA2LjgzNDQzNywxMDQuNjAzOTc0IDIwOS4yOTI3MTUsMTAyLjgyMzg0MSBDMjI1LjIyOTEzOSw5MS42MzQ0MzcxIDI1MS40MjI1MTcsOTQuODU1NjI5MSAyNTQuNDc0MTcyLDk4LjU4NTQzMDUgQzI1Ny41MjU4MjgsMTAyLjQgMjUzLjYyNjQ5LDEyOC41OTMzNzcgMjM4LjcwNzI4NSwxNDEuMTM5MDczIEMyMzYuNDE4NTQzLDE0My4wODg3NDIgMjM0LjIxNDU3LDE0Mi4wNzE1MjMgMjM1LjIzMTc4OCwxMzkuNTI4NDc3IEMyMzguNjIyNTE3LDEzMS4xMzY0MjQgMjQ2LjE2Njg4NywxMTIuMjMzMTEzIDI0Mi42MDY2MjMsMTA3Ljc0MDM5NyBaIiBmaWxsPSIjRkY5OTAwIj4KDTwvcGF0aD4KCQk8L2c+Cjwvc3ZnPg==)

## Arquitetura

### Componentes
1. **Base de Conhecimento (Bedrock)**: 
   - Configurada com armazenamento baseado em vetores utilizando um modelo de embeddings.
   - Utiliza RDS Aurora Serverless para armazenamento de dados.
   - Ingere dados do S3 com chunking semântico.

2. **Funções e Políticas do IAM**:
   - Funções para operações do Bedrock, Lambda e Base de Conhecimento.
   - Políticas para acesso ao RDS, Secrets Manager e S3.

3. **RDS Aurora Serverless**:
   - Banco de dados PostgreSQL com alta disponibilidade e escalabilidade.
   - Gerenciamento de credenciais via Secrets Manager.

4. **Função Lambda**:
   - Inicializa o esquema do banco de dados e as tabelas necessárias para a base de conhecimento.

5. **Bucket S3**:
   - Fonte de dados para a base de conhecimento.
   - Configurável para upload de arquivos de dados.

## Módulos

### Base de Conhecimento Bedrock
**Caminho**: `modules/bedrock`

**Recursos**:
- `aws_bedrockagent_knowledge_base`
- `aws_bedrockagent_data_source`

**Entradas**:
- `knowledge_name`: Nome da base de conhecimento.
- `role_arn`: ARN da função IAM para operações do Bedrock.
- `embedding_model_arn`: ARN do modelo de embeddings.
- `database_name`, `table_name`: Nomes do banco de dados e da tabela no RDS.
- `primary_key`, `text_field`, `metadata_field`, `vector_field`: Mapeamentos de campos no RDS.
- `bucket_s3_arn`: ARN do bucket S3 como fonte de dados.
- `breakpoint_threshold`, `buffer_size`, `max_token`: Configuração de chunking semântico.

**Saídas**:
- `knowledge_base_id`: ID da base de conhecimento.
- `data_source_id`: ID da fonte de dados.

---

### IAM
**Caminho**: `modules/iam`

**Recursos**:
- `aws_iam_role`
- `aws_iam_policy`
- `aws_iam_role_policy_attachment`

**Entradas**:
- `role_name`: Nome da função IAM.
- `assume_role_services`: Serviços AWS que assumem a função.
- `policy_name`, `policy_description`, `policy_statements`: Configurações de política.

**Saídas**:
- `role_arn`: ARN da função IAM.

---

### Lambda
**Caminho**: `modules/lambda`

**Recursos**:
- `aws_lambda_function`

**Entradas**:
- `file_name`: Nome do pacote de implantação da Lambda.
- `function_name`: Nome da função Lambda.
- `role_arn`: ARN da função IAM para a Lambda.
- `environment_vars`: Variáveis de ambiente para a função Lambda.
- `timeout`, `memory_size`: Configuração de execução da função.

**Saídas**:
- `lambda_function_name`: Nome da função Lambda.
- `lambda_function_arn`: ARN da função Lambda.
- `lambda_function_role`: ARN da função IAM para a Lambda.

---

### RDS
**Caminho**: `modules/rds`

**Recursos**:
- `aws_rds_cluster`
- `aws_rds_cluster_instance`
- `aws_secretsmanager_secret`
- `aws_secretsmanager_secret_version`
- `random_password`

**Entradas**:
- `cluster_name`: Nome do cluster Aurora Serverless.
- `database_name`: Nome do banco de dados.
- `min_capacity`, `max_capacity`: Configuração de escalabilidade do cluster.
- `secret_manager_name`: Nome do segredo no Secrets Manager.

**Saídas**:
- `db_credentials_secret_arn`: ARN do segredo de credenciais do banco de dados.
- `aurora_cluster_endpoint`: Endpoint do cluster Aurora.
- `aurora_cluster_arn`: ARN do cluster Aurora.
- `aurora_cluster_id`: ID do cluster Aurora.
- `aurora_database_name`: Nome do banco de dados Aurora.

---

## Configuração Principal
**Caminho**: `main.tf`

### Provedores
- **AWS**: Região e perfil configuráveis via variáveis `region` e `profile`.
- **Null**: Para executar comandos AWS CLI localmente.

### Módulos
1. **RDS**:
   - Implanta o cluster Aurora Serverless com integração ao Secrets Manager.
2. **IAM**:
   - Configura funções e políticas para Bedrock e Lambda.
3. **Lambda**:
   - Implanta uma função Lambda para inicialização do banco de dados.
4. **Base de Conhecimento**:
   - Configura a base de conhecimento Bedrock com integração ao RDS e S3.

## Variáveis
### Variáveis Globais
- `region`: Região AWS (padrão: `us-east-1`).
- `profile`: Perfil do CLI da AWS (padrão: `default`).

### Variáveis da Base de Conhecimento
- `knowledge_name`, `role_arn`, `embedding_model_arn`: Configurações da base de conhecimento e do Bedrock.
- `database_name`, `table_name`: Configurações do RDS.
- `bucket_name`, `data_source_dir`: Configurações do bucket S3.
- `breakpoint_threshold`, `buffer_size`, `max_token`: Configurações de chunking.

## Saídas Globais
- ``knowledge_base_id``: ID da base de conhecimento criada.
- ``data_source_id``: ID da fonte de dados criada para a base de conhecimento.
- ``aurora_cluster_endpoint``: Endpoint do cluster Aurora Serverless.
- ``aurora_cluster_arn``: ARN do cluster Aurora Serverless.
- ``aurora_cluster_id``: ID do cluster Aurora Serverless.
- ``aurora_database_name``: Nome do banco de dados Aurora Serverless.

## Deploy da Base de Conhecimento

1. Abra o terminal na raiz do projeto e execute `cd ./terraform`.
2. Inicialize o projeto Terraform:
```bash
terraform init
```
3. Crie um diretório para armazenar os documentos que serão enviados para o S3 e preencha a variável ``data_source_dir``.
4. Comprima o código de ``app/database_init_lambda`` em um arquivo zip e crie um diretório na raiz do projeto Terraform (``/terraform/artifacts``) para mover o arquivo zip para o diretório ``terraform/artifacts/``.
5. Planeje a implantação da infraestrutura:
```bash
terraform plan
```
6. Aplique a configuração:
```bash
terraform apply
```

## Como deletar a infraestrutura

Não esqueça de deletar limpar seu ambiente da nuvem após o uso para evitar cobranças surpresas:

Abra o seu terminal em `terraform/` e digite o comando `terraform destroy`.

## Notas

- Certifique-se de que todas as variáveis de entrada estão devidamente definidas em um arquivo ``terraform/.tfvars`` ou passadas durante a execução.
- As credenciais do banco de dados RDS são armazenadas com segurança no AWS Secrets Manager.
- O bucket S3 deve conter arquivos de dados que serão ingeridos na base de conhecimento.

## Fontes
As seguintes fontes foram consultadas para a criação desse projeto:
- Documentação de Projeto similar da AWS:
    - Como criar uma Base de Conhecimento no Aurora Serverless: [clique aqui](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.VectorDB.html)
    - Como criar uma Base de Conhecimento no Aurora Serverless no console: [clique aqui](https://aws.amazon.com/pt/blogs/database/accelerate-your-generative-ai-application-development-with-amazon-bedrock-knowledge-bases-quick-create-and-amazon-aurora-serverless/)
    - Como criar uma Base de Conhecimento pelo Terraform: [clique aqui](https://aws.amazon.com/pt/blogs/infrastructure-and-automation/build-an-automated-deployment-of-generative-ai-with-agent-lifecycle-changes-using-terraform/)
- Documentação do Terraform para o recurso `aws_bedrockagent_knowledge_base`: [clique aqui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_knowledge_base)
- Documentação do Terraform para o recurso `aws_bedrockagent_data_source`: [clique aqui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_data_source)
- Documentação do Terraform para o recurso `aws_rds_cluster`: [clique aqui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster)
- Documentação do Terraform para o recurso `aws_rds_cluster_instance`: [clique aqui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance)