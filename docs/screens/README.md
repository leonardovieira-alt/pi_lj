# Documentacao das Telas

Este arquivo descreve as telas atuais do app L&J, o objetivo de cada uma, componentes principais e integracao com a API.

## Arquivos de referencia

- [screen_01.png](screen_01.png)
- [screen_02.png](screen_02.png)
- [screen_03.png](screen_03.png)
- [screen_04.png](screen_04.png)
- [screen_05.png](screen_05.png)

## Mapa rapido de telas

1. Splash
2. Login
3. Registro
4. Home (Catalogo)
5. Perfil

## 1. Splash

- Objetivo: tela inicial de carregamento e transicao para autenticacao.
- Comportamento:
  - Exibe a imagem loader com animacao de pop.
  - Aguarda alguns segundos e redireciona para login.
- Arquivo:
  - [lib/features/splash/presentation/splash_screen.dart](../../lib/features/splash/presentation/splash_screen.dart)

## 2. Login

- Objetivo: autenticar o usuario com email e senha.
- Componentes:
  - Botao de entrada com Google (placeholder visual).
  - Campo de email.
  - Campo de senha com mostrar/ocultar.
  - Checkbox "Lembre de mim".
  - Link "Esqueceu a senha?".
  - Botao principal "Entrar".
  - Link para tela de registro.
- Integracao API:
  - Endpoint: `POST /auth/login`
  - Em sucesso, salva token JWT localmente e abre a Home.
- Arquivos:
  - [lib/features/auth/presentation/login_screen.dart](../../lib/features/auth/presentation/login_screen.dart)
  - [lib/features/auth/data/auth_service.dart](../../lib/features/auth/data/auth_service.dart)
  - [lib/core/network/api_client.dart](../../lib/core/network/api_client.dart)

## 3. Registro

- Objetivo: criar nova conta de usuario.
- Componentes:
  - Campos de nome, email, aniversario, telefone e senha.
  - Validacao basica de dados obrigatorios.
  - Botao principal "Registrar-se".
  - Link de retorno para login.
- Integracao API:
  - Endpoint: `POST /auth/register`
- Arquivos:
  - [lib/features/auth/presentation/register_screen.dart](../../lib/features/auth/presentation/register_screen.dart)
  - [lib/features/auth/data/auth_service.dart](../../lib/features/auth/data/auth_service.dart)

## 4. Home (Catalogo)

- Objetivo: exibir os produtos disponiveis.
- Componentes:
  - Lista de cards de produto com nome, descricao e preco.
  - Estados de loading, erro e lista vazia.
  - Barra de navegacao inferior para alternar entre Catalogo e Perfil.
- Integracao API:
  - Endpoint: `GET /produtos`
- Arquivos:
  - [lib/features/home/presentation/home_shell.dart](../../lib/features/home/presentation/home_shell.dart)
  - [lib/features/catalog/presentation/catalog_screen.dart](../../lib/features/catalog/presentation/catalog_screen.dart)
  - [lib/features/catalog/data/product_service.dart](../../lib/features/catalog/data/product_service.dart)
  - [lib/shared/widgets/app_bottom_nav.dart](../../lib/shared/widgets/app_bottom_nav.dart)

## 5. Perfil

- Objetivo: visualizar dados da conta e realizar acoes de sessao/seguranca.
- Componentes:
  - Campos de perfil (nome, email, aniversario, telefone).
  - Email como somente leitura.
  - Botao "Trocar senha" com dialog.
  - Botao principal "Salvar".
  - Botao "Sair" em vermelho com confirmacao.
- Integracao API:
  - Endpoint: `GET /auth/perfil`
  - Endpoint: `POST /auth/logout`
- Arquivos:
  - [lib/features/profile/presentation/profile_screen.dart](../../lib/features/profile/presentation/profile_screen.dart)
  - [lib/features/auth/data/auth_service.dart](../../lib/features/auth/data/auth_service.dart)

## Configuracao da API

A URL base da API esta centralizada em:

- [lib/core/config/api_config.dart](../../lib/core/config/api_config.dart)

Prioridade da URL:

1. `--dart-define=API_BASE_URL=...`
2. URL padrao configurada no arquivo de config

Exemplo:

```bash
flutter run --dart-define=API_BASE_URL=https://apiserverlj.up.railway.app/api
```

## Fluxo de navegacao atual

1. Splash -> Login
2. Login -> Home (Catalogo)
3. Login -> Registro
4. Home <-> Perfil (via barra inferior)
5. Perfil -> Sair (com confirmacao) -> Login

## Observacoes

- O botao "Entrar com Google" ainda esta como placeholder.
- O dialog "Trocar senha" esta pronto no front e pode ser conectado ao endpoint quando definido na API.
