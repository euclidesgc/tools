# 📄 Read this in: [English](#english-version) | [Português](#versão-em-português)

# English Version

## boti_lints

A package of custom lint rules for Dart/Flutter projects using Cubit/Bloc.

### Purpose

The goal of this package is to provide a lint rule that prevents the use of the `emit()` method after an `await` without properly checking if the Cubit has been closed. This helps avoid exceptions and unexpected behaviors in applications using the Cubit/Bloc pattern.

The main rule implemented is:
- **avoid_emit_without_guard**: Ensures that after an `await`, the `emit()` method is only called if there is a prior check for `isClosed`.

### How to use in other projects

1. Add the package to your project (`pubspec.yaml`):

```yaml
dependencies:
  boti_lints:
    git:
      url: https://github.com/euclidesgc/tools.git
      path: lint/boti_lints
```

2. In your project's `analysis_options.yaml` file, add:

```yaml
analyzer:
  plugins:
    - boti_lints
```

3. Run the custom_lint command to analyze your project:

```sh
flutter pub run custom_lint
```

### Limitations

#### Limitations of custom_lint_builder
- `custom_lint_builder` currently does not allow selecting which rules from the plugin will be enabled or disabled individually via `analysis_options.yaml`. All plugin rules are applied automatically.
- This can cause conflicts or inconvenience if you want to use only a specific rule.

#### Why not use the bloc_lint approach?
- The [bloc_lint](https://pub.dev/packages/bloc_lint) package uses a different approach, implementing lints directly as an analyzer plugin, which allows greater granularity in rule configuration.
- We chose to use `custom_lint_builder` because it is simpler to implement and maintain, even with the current limitations.
- If `custom_lint_builder` evolves to allow granular configuration, we intend to adopt this feature.

### References
- [custom_lint (pub.dev)](https://pub.dev/packages/custom_lint)
- [custom_lint_builder (pub.dev)](https://pub.dev/packages/custom_lint_builder)
- [custom_lint issues](https://github.com/invertase/dart_custom_lint/issues)
- [bloc_lint](https://pub.dev/packages/bloc_lint)
- [Discussion about emit after await and isClosed (issue avoid_async_emit)](https://github.com/felangel/bloc/issues/4490)

---

Feel free to contribute or suggest improvements!

# Versão em Português

# boti_lints

Um pacote de regras de lint personalizadas para projetos Dart/Flutter que utilizam Cubit/Bloc.

## Objetivo

O objetivo deste pacote é fornecer uma regra de lint que previne o uso do método `emit()` após um `await` sem a devida verificação se o Cubit foi fechado. Isso ajuda a evitar exceções e comportamentos inesperados em aplicações que utilizam o padrão Cubit/Bloc.

A regra principal implementada é:
- **avoid_emit_without_guard**: Garante que, após um `await`, o método `emit()` só seja chamado se houver uma verificação prévia de `isClosed`.

## Como utilizar em outros projetos

1. Adicione o pacote ao seu projeto (no `pubspec.yaml`):

```yaml
dependencies:
  boti_lints:
    git:
      url: https://github.com/euclidesgc/tools.git
      path: lint/boti_lints
```

2. No arquivo `analysis_options.yaml` do seu projeto, adicione:

```yaml
analyzer:
  plugins:
    - boti_lints
```

3. Rode o comando do custom_lint para analisar seu projeto:

```sh
flutter pub run custom_lint
```

## Limitações

### Limitações do custom_lint_builder
- O `custom_lint_builder` não permite, atualmente, selecionar quais regras do plugin serão ativadas ou desativadas individualmente via `analysis_options.yaml`. Todas as regras do plugin são aplicadas automaticamente.
- Isso pode causar conflitos ou incômodos caso você queira utilizar apenas uma regra específica.

### Por que não usamos abordagem do bloc_lint?
- O pacote [bloc_lint](https://pub.dev/packages/bloc_lint) utiliza uma abordagem diferente, implementando lints diretamente como um analyzer plugin, o que permite maior granularidade na configuração das regras.
- Optamos por usar o `custom_lint_builder` por ser mais simples de implementar e manter, mesmo com as limitações atuais.
- Caso o `custom_lint_builder` evolua para permitir configuração granular, pretendemos adotar essa funcionalidade.

## Referências
- [custom_lint (pub.dev)](https://pub.dev/packages/custom_lint)
- [custom_lint_builder (pub.dev)](https://pub.dev/packages/custom_lint_builder)
- [Issues do custom_lint](https://github.com/invertase/dart_custom_lint/issues)
- [bloc_lint](https://pub.dev/packages/bloc_lint)
- [Discussão sobre emit após await e isClosed (issue avoid_async_emit)](https://github.com/felangel/bloc/issues/4490)

---

Sinta-se à vontade para contribuir ou sugerir melhorias!
