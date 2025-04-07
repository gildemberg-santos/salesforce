# Salesforce Ruby Gem

[![Build Status](https://github.com/gildemberg-santos/salesforce/actions/workflows/main.yml/badge.svg)](https://github.com/gildemberg-santos/salesforce/actions)

Uma gem Ruby para facilitar a integração com a API do Salesforce.

Este projeto tem como objetivo fornecer uma interface simples e eficiente para autenticação, consultas e manipulação de dados via Salesforce.

---

## 📦 Instalação

### Adicionando ao Gemfile

```ruby
gem 'salesforce'
```

Depois, execute:

```bash
bundle install
```

### Ou instalação manual

```bash
gem install salesforce
```

### Dependência do sistema

> **Importante:** Para sistemas baseados em Debian/Ubuntu, é necessário instalar o `ruby-dev`:

```bash
sudo apt install ruby-dev
```

---

## 🚀 Uso

### Console Interativo

Execute o seguinte comando para iniciar um prompt interativo com a gem carregada:

```bash
bin/console
```

### Exemplo de utilização

```ruby
require 'salesforce'

client = Salesforce::Client.new(
  client_id: ENV['SALESFORCE_CLIENT_ID'],
  client_secret: ENV['SALESFORCE_CLIENT_SECRET'],
  username: ENV['SALESFORCE_USERNAME'],
  password: ENV['SALESFORCE_PASSWORD']
)

# Exemplo de query
result = client.query("SELECT Id, Name FROM Account LIMIT 10")
puts result
```

> Mais exemplos de uso estarão disponíveis em breve.

---

## 🛠 Desenvolvimento

### Clonando e configurando o projeto

Após clonar o repositório, execute:

```bash
bin/setup
```

Para iniciar um console interativo com o ambiente carregado:

```bash
bin/console
```

### Instalando localmente

Para instalar a gem localmente:

```bash
bundle exec rake install
```

### Publicando nova versão

1. Atualize a versão em `lib/salesforce/version.rb`
2. Execute:

```bash
bundle exec rake release
```

Este comando:
- Cria uma nova tag no Git
- Envia os commits e a tag para o GitHub
- Publica a nova versão no [RubyGems.org](https://rubygems.org)

---

## 🤝 Contribuindo

Relatórios de bugs e pull requests são bem-vindos no [repositório do GitHub](https://github.com/gildemberg-santos/salesforce).

Este projeto segue um ambiente de colaboração saudável e respeitosa. Consulte o nosso [Código de Conduta](https://github.com/gildemberg-santos/salesforce/blob/master/CODE_OF_CONDUCT.md) para mais informações.

---

## 📄 Licença

Este projeto é licenciado sob a licença [MIT](https://opensource.org/licenses/MIT).
