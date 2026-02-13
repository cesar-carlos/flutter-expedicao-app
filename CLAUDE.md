# Coding Rules for Claude

This project follows **Clean Architecture** and **Domain Driven Design (DDD)** principles, prioritizing **SOLID** principles to organize code in a clear, scalable, and testable way.

## Fundamental Principles

### SOLID

- **S**ingle Responsibility Principle (SRP): Each class should have a single responsibility
- **O**pen/Closed Principle (OCP): Open for extension, closed for modification
- **L**iskov Substitution Principle (LSP): Objects should be substitutable by instances of their subtypes
- **I**nterface Segregation Principle (ISP): Many specific interfaces are better than one general interface
- **D**ependency Inversion Principle (DIP): Depend on abstractions, not concrete implementations

### Clean Architecture

Dependencies point inward: **Presentation → Application → Domain ← Infrastructure**

- **Domain is independent**: Does not depend on frameworks, libraries, or implementation details
- **Testability**: Business logic can be tested without external dependencies

## Folder Structure

```
lib/
├── domain/              # Domain Layer (Pure Business Logic)
│   ├── entities/        # Domain entities (business objects)
│   ├── value_objects/   # Value objects (immutable, compared by value)
│   ├── repositories/    # Repository interfaces (contracts)
│   ├── use_cases/       # Use cases (pure application logic)
│   └── errors/          # Domain exceptions and errors
│
├── application/         # Application Layer (Orchestration)
│   ├── services/        # Application services (coordinate use cases)
│   ├── dtos/            # Data Transfer Objects (transfer between layers)
│   └── mappers/         # Converters between entities and DTOs
│
├── infrastructure/      # Infrastructure Layer (Implementations)
│   ├── datasources/     # Data sources (API, Local DB, etc.)
│   ├── repositories/    # Repository implementations
│   ├── external_services/  # External services (APIs, etc.)
│   │   └── interceptors/  # HTTP interceptors (dio)
│   └── models/          # Data models for serialization
│
├── presentation/        # Presentation Layer (UI)
│   ├── pages/          # Application screens
│   ├── widgets/        # Reusable UI components
│   ├── controllers/    # State controllers
│   └── providers/      # Providers (state management with Provider)
│
├── core/               # Core Components (Shared)
│   ├── constants/      # Application constants
│   ├── utils/          # Utility functions
│   ├── extensions/     # Class extensions
│   ├── theme/          # Application theme
│   ├── routes/         # Routes and navigation (go_router)
│   ├── di/             # Dependency injection (get_it)
│   └── validation/     # Validation schemas (zard)
│
└── shared/             # Shared Components
    ├── widgets/        # Shared widgets
    └── utils/          # Shared utilities
```

## Architecture Layers - Dependency Rules

### Domain Layer

- ✅ Can import only from `core` and `shared`
- ❌ NEVER import from `application`, `infrastructure` or `presentation`
- ❌ NEVER import Flutter, HTTP, or any external framework
- ✅ Pure Dart classes only
- ✅ Abstract interfaces for external dependencies

### Application Layer

- ✅ Can import from `domain` and `core`
- ❌ NEVER import from `infrastructure` or `presentation`
- ✅ Uses Domain interfaces, not implementations

### Infrastructure Layer

- ✅ Can import from `domain` and `core`
- ❌ NEVER import from `application` or `presentation`
- ✅ Implements interfaces defined in Domain

### Presentation Layer

- ✅ Can import from `domain`, `application` and `core`
- ❌ NEVER import from `infrastructure`
- ✅ Uses Application services or Domain use cases

## Standard Libraries - ALWAYS use these specific libraries

### Routes - `go_router`

- ✅ ALWAYS use `go_router` for navigation and routes
- ❌ NEVER use `Navigator.push()`, `auto_route` or other route libraries
- ✅ Configure routes in `core/routes/`
- ✅ Use `context.go()` or `context.push()` for navigation

### HTTP Client - `dio`

- ✅ ALWAYS use `dio` for HTTP/API requests
- ❌ NEVER use `http` package or other HTTP libraries
- ✅ Configure `Dio` in `infrastructure/external_services/`
- ✅ Use interceptors for error handling and authentication

### Service Locator - `get_it`

- ✅ ALWAYS use `get_it` for dependency injection
- ❌ NEVER use `Provider` for DI, `injectable` or other DI libraries
- ✅ Configure `GetIt` in `core/di/`
- ✅ Use `get_it` to register and resolve dependencies

### State Management - `Provider`

- ✅ ALWAYS use `Provider` for state management
- ❌ NEVER use `BLoC`, `Riverpod`, `GetX` or other state libraries
- ✅ Use `ChangeNotifierProvider` for local state
- ✅ Use `MultiProvider` for multiple providers

### BR Formatting - `brasil_fields`

- ✅ ALWAYS use `brasil_fields` for Brazilian field formatting
- ✅ Use for CPF, CNPJ, CEP, phone formatting
- ✅ Use validators from library

### Environment Variables - `flutter_dotenv`

- ✅ ALWAYS use `flutter_dotenv` for environment variables
- ✅ Create `.env` file at project root
- ✅ Load variables in `main.dart`
- ✅ Use `dotenv.env['KEY']` to access variables

### UUID - `uuid`

- ✅ ALWAYS use `uuid` for generating unique identifiers
- ✅ Use `Uuid().v4()` to generate UUIDs v4

### Error Handling - `result_dart`

- ✅ ALWAYS use `result_dart` for error handling
- ❌ NEVER use `Either` (dartz) or other error handling libraries
- ✅ Use `Result<T>` for returns that may fail
- ✅ Use `Success(value)` for success and `Failure(exception)` for failure

### Validation - `zard`

- ✅ ALWAYS use `zard` for type validation and schemas
- ✅ Use for API data validation
- ✅ Use for form validation

## Naming Conventions

### Classes and Types

- **Entities**: Singular nouns, PascalCase
  - `User`, `Product`, `Order`
- **Value Objects**: Descriptive nouns, PascalCase
  - `Email`, `Money`, `CPF`, `Address`
- **Use Cases**: Infinitive verbs, PascalCase
  - `GetUserById`, `CreateProduct`, `UpdateOrder`
- **Repositories (Interfaces)**: Prefix `I` + singular name, PascalCase
  - `IUserRepository`, `IProductRepository`
- **Repositories (Implementations)**: Singular name + `Repository`, PascalCase
  - `UserRepository`, `ProductRepository`
- **Services**: Singular name + `Service`, PascalCase
  - `UserService`, `ProductService`
- **DTOs**: Singular name + `DTO`, PascalCase
  - `UserDTO`, `ProductDTO`

### Variables and Methods

- **Variables**: camelCase
  - `userName`, `productList`, `isLoading`
- **Methods**: camelCase, verbs
  - `getUser()`, `createProduct()`, `isValid()`
- **Constants**: camelCase with `const` or `static const`
  - `const maxRetries = 3`
- **Private parameters**: Prefix `_` + camelCase
  - `_repository`, `_userService`

### Files

- **Files**: snake_case, same naming as main class
  - `user.dart` → `class User`
  - `get_user_by_id.dart` → `class GetUserById`
  - `i_user_repository.dart` → `abstract class IUserRepository`

## Dart Style Guide

### Naming

- ✅ Use **PascalCase** for classes, types, and enums
- ✅ Use **camelCase** for variables, methods, and parameters
- ✅ Use **lowercase_with_underscores** for file and folder names
- ✅ Use **underscore prefix** for private members

### Types and Null Safety

- ✅ Prefer explicit types for public APIs
- ✅ Use null safety: avoid `null` when possible
- ✅ Use `?` only when necessary
- ✅ Use `!` only when absolutely safe
- ✅ Prefer `late` for late initialization over nullable `null`

### Const and Final

- ✅ Use `const` for values known at compile time
- ✅ Use `const` constructors when possible for better performance
- ✅ Use `const` in immutable widgets
- ✅ Use `final` for variables that won't be reassigned

### Functions and Methods

- ✅ Use positional parameters for required and clear semantics
- ✅ Use named parameters for optional and better readability
- ✅ Use arrow functions for simple one-line functions
- ✅ NEVER return Widget from a function - use tear-off instead

### Tear-off for Widgets

- ✅ NEVER return Widget from a function - use tear-off instead
- ✅ Use tear-off to pass widget constructors directly
- ✅ This improves performance and code clarity

## Component Creation and Reusability

### Priority: Always Create Reusable Components

- ✅ ALWAYS prioritize creating reusable components over inline code duplication
- ✅ ALWAYS check for existing components before creating new ones
- ✅ ALWAYS extract repeated UI patterns into reusable widgets
- ✅ ALWAYS place reusable components in `lib/shared/widgets/` or feature-specific widget folders
- ❌ NEVER duplicate UI code - extract to components instead

### Visual Style Standardization

- ✅ ALWAYS use centralized theme (`core/theme/`)
- ✅ ALWAYS use consistent spacing from theme constants
- ✅ ALWAYS use consistent colors from theme
- ✅ ALWAYS use consistent typography from theme
- ✅ ALWAYS use consistent border radius from theme constants
- ❌ NEVER use hardcoded colors, sizes, or spacing - always use theme constants

### Component Structure

- ✅ ALWAYS create small, focused components (Single Responsibility)
- ✅ ALWAYS make components configurable via constructor parameters
- ✅ ALWAYS use `const` constructors when possible for performance
- ✅ ALWAYS extract complex layouts into separate widget components
- ❌ NEVER create components that do too much - split into smaller components

## Error Handling

### Use Result Pattern (result_dart)

```dart
// domain/errors/errors.dart
abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}

// Usage
Future<Result<User>> getUser(String id) async {
  if (id.isEmpty) {
    return Failure(ValidationFailure('ID cannot be empty'));
  }

  try {
    final result = await repository.getById(id);
    return result;
  } catch (e) {
    return Failure(ServerFailure(e.toString()));
  }
}

// Handle Result
final result = await getUser('123');
result.fold(
  (success) {
    // Handle success
    print('User: ${success.name}');
  },
  (failure) {
    // Handle failure
    print('Error: ${failure.message}');
  },
);
```

## Dependency Injection

### Via Constructor

```dart
// ✅ Correct: Constructor injection
class UserService {
  final IUserRepository repository;

  UserService(this.repository);
}
```

## Import Organization

### Import Order

1. Dart SDK imports
2. Flutter imports
3. External package imports
4. Relative imports (same package)

### Example

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. External packages
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

// 4. Relative
import '../models/user.dart';
import 'user_service.dart';
```

## Domain Layer Specific Rules

### Entities

- ✅ Represent main domain objects with unique identity
- ✅ Contain business logic related to object
- ✅ Be immutable when possible (final fields)
- ✅ Compare by identity (id), not by value
- ❌ NEVER import Flutter, HTTP, or frameworks
- ❌ NEVER import from other business layers

### Value Objects

- ✅ Always be immutable (all fields `final`)
- ✅ Validate values in constructor
- ✅ Implement `==` and `hashCode` based on value
- ✅ Throw domain-specific exceptions for invalid values
- ❌ NEVER have identity (id)

### Use Cases

- ✅ Have a single responsibility (SRP)
- ✅ Receive dependencies via constructor (DIP)
- ✅ Depend only on interfaces (repositories)
- ✅ Implement method `call()` for execution
- ✅ Return `Result<T>` for error handling
- ❌ NEVER contain presentation logic
- ❌ NEVER depend on frameworks

### Repositories (Interfaces)

- ✅ Only interfaces/abstract classes
- ✅ Methods return domain entities or `Result<T>`
- ✅ NEVER have concrete implementations in Domain
- ✅ NEVER depend on frameworks or technologies
- ✅ Prefix `I` for interfaces (ex: `IUserRepository`)

## Flutter Widgets Best Practices

### Stateless vs Stateful

- ✅ Use `StatelessWidget` when widget doesn't need to manage state
- ✅ Use `const` constructor when possible for better performance
- ✅ Use `StatefulWidget` only when necessary to manage state

### Performance

- ✅ Use `const` constructor for immutable widgets
- ✅ Use `const` child widgets when possible
- ✅ Extract widgets that change frequently
- ✅ Use `RepaintBoundary` for complex widgets
- ✅ Use `Key` only when necessary (lists, animations)

### Widget Composition

- ✅ Extract widgets when they get too large (>100 lines in build)
- ✅ Extract reusable widgets
- ✅ Use small, focused widgets
- ✅ Prefer composition over inheritance

### Layout

- ✅ Use `MediaQuery` for responsive dimensions
- ✅ Use `LayoutBuilder` for adaptive layouts
- ✅ Avoid hardcoded dimension values

### Theming

- ✅ Define centralized theme in `core/theme`
- ✅ Use `Theme.of(context)` to access theme
- ✅ Use `Theme.of(context).textTheme` for text styles

### Navigation

- ✅ Define centralized routes in `core/routes`
- ✅ Use named routes for navigation
- ✅ Use `go_router` for complex routes

### State Management

- ✅ Use `StatefulWidget` for simple local state
- ✅ Use `Provider` for global state (project standard)
- ✅ Separate business logic from UI state
- ✅ Use `ChangeNotifierProvider` for providers that extend `ChangeNotifier`

## General Project Rules

### Documentation and Comments

- ❌ **DO NOT create documentation automatically** (`///`, `README.md`, etc.)
- ❌ **DO NOT create documentation files** without explicit request
- ❌ **DO NOT add unnecessary comments** to code
- ✅ **ONLY create documentation when explicitly requested** by user
- ✅ **Code should be self-explanatory** through clear naming

### When to Document (Only if Requested)

- ✅ Document only complex public APIs when requested
- ✅ Use `///` for public API documentation (only when necessary and explicitly requested)
- ✅ Use `//` for internal comments (only when necessary)
- ✅ Document only when code is not self-explanatory

### Comments

- ✅ Use comments only to explain "why", not "what"
- ✅ Keep comments updated with code
- ✅ Prefer clear code over comments

## Commits and Documentation

- ❌ **NEVER make git commits** unless explicitly requested by user
- ❌ **NEVER create documentation** (README.md, comments, etc.) unless explicitly requested
- ❌ **NEVER push to repository** unless explicitly requested
- ✅ **ONLY commit/push/document** when user explicitly asks for it
- ✅ Always ask for confirmation before committing or pushing changes

## Code Quality

### Avoid Dead Code

- ✅ Remove unused commented code
- ✅ Remove unused imports
- ✅ Remove unused variables

### Readability

- ✅ Keep functions small and focused
- ✅ Use descriptive names
- ✅ Avoid excessive nesting depth
- ✅ Break long lines (maximum ~80 characters)

### Single Responsibility

- ✅ Each class should have a single responsibility
- ✅ Extract repeated patterns into utility functions or widgets
- ✅ Reuse existing services, repositories, and use cases

## When Creating Components

Before creating a new component, check:

1. [ ] Does a similar component already exist? (`lib/shared/widgets/`, feature widgets)
2. [ ] Can I extend/modify an existing component instead?
3. [ ] Will this component be reused in multiple places?
4. [ ] Are visual styles consistent with existing components?
5. [ ] Are colors, spacing, and typography from theme?

## Testing Patterns

### AAA Pattern (Arrange, Act, Assert)

```dart
test('should do something', () {
  // Arrange - Prepare data and dependencies
  final user = User(/* ... */);
  final repository = MockRepository();

  // Act - Execute action
  final result = useCase(user);

  // Assert - Verify result
  expect(result, isNotNull);
});
```

### Test Naming

- Describe expected behavior
- Use format: `should [verb] when [condition]`
- Examples:
  - `should return User when repository succeeds`
  - `should return Failure when id is empty`
  - `should throw exception when email is invalid`

## Checklist for New Code

- [ ] Uses standard libraries (go_router, dio, get_it, Provider, result_dart)
- [ ] Follows naming conventions
- [ ] Uses Result<T> for error handling
- [ ] Uses dependency injection via constructor
- [ ] Domain doesn't import application/infrastructure/presentation
- [ ] Application doesn't import infrastructure/presentation
- [ ] Infrastructure doesn't import application/presentation
- [ ] Presentation doesn't import infrastructure
- [ ] Creates reusable components for repeated UI patterns
- [ ] Uses theme constants instead of hardcoded values
- [ ] Uses const constructors when possible
- [ ] Code is self-explanatory (no unnecessary comments)
- [ ] Follows SOLID principles
