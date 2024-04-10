![Logo da Unique Bundle Store](app/assets/images/admin/logo.png)

# Painel Administrativo
Este é o painel administrativo para a Unique Bundle Store. Este painel é construído na arquitetura monolítica do Rails 7.1.3 e usa Ruby 3.2.0 como linguagem de programação. Ele também faz uso de recursos do Hotwire para uma experiência de usuário interativa e responsiva.

Requisitos
Certifique-se de ter as seguintes dependências instaladas antes de executar o projeto:

Ruby 3.2.0
Rails 7.1.3
Docker e Docker Compose

Configuração e Execução com Docker
Siga estas etapas para configurar e executar o projeto localmente usando Docker:

1. Clone este repositório em sua máquina local:

```bash
  git clone https://github.com/seu-usuario/unique_bundle_store_painel.git
```
2. Navegue até o diretório do projeto:
  
```bash
  cd unique_bundle_store_painel
```

3. Construa a imagem Docker:

```bash
  docker build --network=host -t unique-bundle-store .
```

4. Execute o contêiner Docker:

```bash
  docker-compose up --build -d
```

Acesse o painel administrativo em seu navegador da web:

```bash
  http://localhost:3000
```

# Contribuição
Este projeto é de código aberto e as contribuições são bem-vindas! Se você encontrar problemas ou tiver sugestões de melhorias, sinta-se à vontade para abrir uma issue ou enviar um pull request.

# Licença
Este projeto é licenciado sob a MIT License.

