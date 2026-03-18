# L&J App (Flutter)

Aplicativo mobile em Flutter para autenticacao de usuarios, exibicao de catalogo de produtos e gerenciamento basico de perfil, integrado com a API L&J.

## Visao geral

- Login e registro de usuarios
- Splash screen animada
- Catalogo com dados vindos da API
- Perfil com visualizacao de dados e logout com confirmacao

## Documentacao das telas

Para ver os detalhes de cada tela, fluxo de navegacao e referencias visuais, acesse:

- [Documentacao de Telas](docs/screens/README.md)

## Como executar

1. Instale dependencias:

```bash
flutter pub get
```

2. Execute o app:

```bash
flutter run
```

3. Opcional: definir URL da API por ambiente:

```bash
flutter run --dart-define=API_BASE_URL=https://apiserverlj.up.railway.app/api
```
