# AGENTS.md — ExcalidrawX

## Objectif

ExcalidrawX est une application Flutter desktop de dessin basée sur le format Excalidraw.

Plateformes cibles :

- macOS
- Windows
- Linux

Les modifications doivent privilégier la maintenabilité, la portabilité desktop et la cohérence avec l’architecture existante.

## Architecture

Le projet suit une Clean Architecture organisée par fonctionnalité.

Flux obligatoire :

```text
Screen
→ Event
→ Bloc
→ UseCase
→ Repository
→ Repository Implementation
→ Local ou Remote DataSource
```

### Responsabilités

- `Screen` : affichage et déclenchement d’événements uniquement.
- `Event` : représente une intention utilisateur.
- `Bloc` : orchestre les UseCases et expose les états.
- `UseCase` : contient la logique métier applicative.
- `Repository` : définit un contrat métier.
- `Repository Implementation` : implémente le contrat et coordonne les DataSources.
- `DataSource` : accède aux fichiers, APIs, préférences ou services externes.

Un Bloc ne doit jamais appeler directement un Repository.

Un Screen ne doit pas contenir de logique métier ou d’accès aux données.

## Organisation des fichiers

Les nouvelles fonctionnalités doivent être organisées par fonctionnalité :

```text
lib/
└── feature_name/
    ├── data/
    │   ├── datasource/
    │   └── repository/
    ├── domain/
    │   ├── entities/
    │   ├── repository/
    │   └── usecase/
    └── presentation/
        ├── bloc/
        │   └── feature/
        ├── screen/
        └── widget/
```

La structure actuelle doit être conservée pendant la migration. Ne pas effectuer de refactor global sans validation préalable.

## BLoC et gestion d’état

Les conventions BLoC existantes sont prioritaires :

```text
feature_bloc.dart
feature_event.dart
feature_state.dart
```

Les événements utilisent la convention `On<Action>` :

```dart
OnLoadSavedFolders
OnCreateFolder
OnOpenFile
```

Les états doivent rester immuables et suivre le style déjà utilisé dans le projet.

Les opérations asynchrones doivent exposer clairement leurs états de chargement, réussite et erreur lorsque cela est pertinent.

## Gestion des résultats et erreurs

Les UseCases retournent préférentiellement :

```dart
Either<Failure, Result>
```

Les exceptions techniques doivent rester confinées aux couches `data`.

Les erreurs doivent être converties progressivement :

```text
Exception technique
→ erreur Data
→ Failure métier
→ état d’erreur du Bloc
```

Les Screens ne doivent pas dépendre d’exceptions techniques provenant des DataSources.

## Injection des dépendances

L’injection des dépendances est stricte.

- `get_it` est utilisé dans le wiring ou la composition root.
- Les Blocs reçoivent leurs UseCases par constructeur.
- Les UseCases reçoivent leurs Repositories par constructeur.
- Les Repository Implementations reçoivent leurs DataSources par constructeur.
- Les DataSources reçoivent leurs dépendances par constructeur.
- Éviter `getIt<T>()` dans les Blocs, UseCases, Repositories et Screens.
- Aucun composant ne doit créer lui-même ses dépendances.

## DataSources et logging

Les logs d’accès aux données doivent être réalisés dans les DataSources.

Logger uniquement :

- les erreurs ;
- les ouvertures et sauvegardes importantes ;
- les suppressions ;
- les opérations pouvant aider au diagnostic.

Ne jamais logger :

- tokens ou mots de passe ;
- contenu complet d’un fichier de dessin ;
- données sensibles ;
- informations privées inutiles.

Utiliser le logger centralisé du projet. Éviter `print()`.

## APIs plateforme

Les APIs spécifiques à macOS, Windows ou Linux doivent être isolées.

- `dart:io` doit rester dans `core` ou `data`.
- Le domaine ne doit dépendre ni de Flutter ni d’une plateforme.
- La présentation ne doit pas gérer directement les APIs système.
- Les différences de plateforme doivent passer par des abstractions injectées.
- Les implementations spécifiques doivent être séparées lorsque nécessaire.
- Une fonctionnalité indisponible doit retourner une erreur métier explicite.

## Version Flutter et FVM

Le projet utilise FVM pour gérer la version de Flutter et du Dart SDK.

Toutes les commandes Flutter et Dart doivent être exécutées avec `fvm`.

Ne pas utiliser directement :

```bash
flutter ...
dart ...
```

Utiliser :

```bash
fvm flutter ...
fvm dart ...
```

La version Flutter utilisée doit être définie dans la configuration FVM du projet.

## Code généré

Les fichiers générés, notamment les fichiers `*.mapper.dart`, ne doivent jamais être modifiés manuellement.

Après modification des modèles ou annotations, utiliser :

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

Les fichiers générés doivent être vérifiés après génération.

## Nommage

- Fichiers et dossiers : `snake_case`
- Classes : `PascalCase`
- Variables et méthodes : `camelCase`
- UseCases : `VerbNounUseCase`
- Repositories : `NounRepository`
- Implementations : `NounRepositoryImplementation`
- DataSources : `NounLocalDataSource` ou `NounRemoteDataSource`
- Screens : `NounScreen`
- Widgets : `NounWidget`
- Blocs : `noun_bloc.dart`, `noun_event.dart`, `noun_state.dart`

## Git et Conventional Commits

Les commits doivent respecter le format :

```text
type(scope): description
```

Exemples :

```text
feat: add drawing workspace
feat(storage): save excalidraw files locally
fix: restore opened drawer correctly
refactor(home): move file loading into a use case
docs: update architecture guide
test: add drawer use case tests
chore: update dependencies
build: update Flutter configuration
ci: update validation workflow
perf: improve file loading
style: format Dart sources
revert: revert drawing workspace
```

Types recommandés :

- `feat` : nouvelle fonctionnalité
- `fix` : correction de bug
- `refactor` : modification interne sans changement fonctionnel
- `docs` : documentation
- `test` : tests
- `chore` : maintenance
- `build` : système de build ou dépendances
- `ci` : intégration continue
- `perf` : amélioration des performances
- `style` : formatage ou style sans changement de comportement
- `revert` : annulation d’un commit précédent

Les descriptions doivent être courtes, impératives et explicites.

## Règles de modification

Avant toute modification :

1. Lire les fichiers concernés.
2. Identifier les conventions existantes.
3. Vérifier les changements déjà présents.
4. Proposer un plan court pour toute modification non triviale.
5. Attendre la validation avant d’éditer.

Pendant la modification :

- Préserver les changements utilisateur existants.
- Faire le plus petit changement cohérent possible.
- Éviter les refactorings hors périmètre.
- Ne pas ajouter de dépendance sans justification.
- Ne pas modifier l’architecture sans validation explicite.
- Ne pas deviner en cas d’ambiguïté importante.

Après la modification :

- Indiquer les fichiers modifiés.
- Indiquer les commandes de validation exécutées.
- Signaler les problèmes restants.
- Mentionner les risques ou compromis éventuels.

## Tests

La stratégie de tests sera définie ultérieurement.

En attendant, ne pas ajouter de règle obligatoire supplémentaire concernant les tests sans validation explicite.

## Commandes

Toutes les commandes doivent utiliser FVM :

```bash
fvm install
fvm flutter pub get
fvm dart format .
fvm flutter analyze
fvm flutter test
fvm dart run build_runner build --delete-conflicting-outputs
```

Toute commande de validation exécutée doit être rapportée avec son résultat.
