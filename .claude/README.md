# Claude AI Coding Rules

This folder contains coding rules and guidelines for Claude AI when working on this Flutter project.

## Files

- **`coding_rules.md`**: Main coding rules document containing all project conventions, architecture principles, and best practices.

## Rules Overview

### Architecture

- **Clean Architecture** with Domain Driven Design (DDD)
- **SOLID** principles
- Layer structure: Domain, Application, Infrastructure, Presentation, Core, Shared

### Standard Libraries

- **go_router** - Routes and navigation
- **dio** - HTTP client
- **get_it** - Dependency injection
- **Provider** - State management
- **result_dart** - Error handling
- **zard** - Type validation
- **brasil_fields** - BR formatting
- **flutter_dotenv** - Environment variables
- **uuid** - UUID generation

### Key Rules

- ✅ Always use the specified standard libraries
- ✅ Follow naming conventions (PascalCase for classes, camelCase for variables/methods)
- ✅ Use Result<T> for error handling
- ✅ Create reusable components
- ✅ Use centralized theme constants
- ✅ Keep code self-explanatory (no unnecessary documentation)
- ❌ Never create documentation automatically
- ❌ Never make git commits unless explicitly requested
- ❌ Never use alternative libraries to the standards

## Usage

Claude AI automatically applies these rules when working on project files. The rules ensure code consistency and quality across the codebase.

## Folder Structure

```
lib/
├── domain/              # Domain Layer (Pure Business Logic)
│   ├── entities/        # Domain entities
│   ├── value_objects/   # Value objects
│   ├── repositories/    # Repository interfaces
│   ├── use_cases/       # Use cases
│   └── errors/          # Domain exceptions
│
├── application/         # Application Layer (Orchestration)
│   ├── services/        # Application services
│   ├── dtos/            # Data Transfer Objects
│   └── mappers/         # Converters
│
├── infrastructure/      # Infrastructure Layer (Implementations)
│   ├── datasources/     # Data sources
│   ├── repositories/    # Repository implementations
│   ├── external_services/  # External services (APIs)
│   │   └── interceptors/  # HTTP interceptors
│   └── models/          # Data models
│
├── presentation/        # Presentation Layer (UI)
│   ├── pages/          # Application screens
│   ├── widgets/        # Reusable UI components
│   ├── controllers/    # State controllers
│   └── providers/      # Providers (state management)
│
├── core/               # Core Components (Shared)
│   ├── constants/      # Application constants
│   ├── utils/          # Utility functions
│   ├── extensions/     # Class extensions
│   ├── theme/          # Application theme
│   ├── routes/         # Routes (go_router)
│   ├── di/             # Dependency injection (get_it)
│   └── validation/     # Validation schemas (zard)
│
└── shared/             # Shared Components
    ├── widgets/        # Shared widgets
    └── utils/          # Shared utilities
```

## Dependency Rules

- **Domain**: Only imports from `core` and `shared`
- **Application**: Imports from `domain` and `core`
- **Infrastructure**: Imports from `domain` and `core`
- **Presentation**: Imports from `domain`, `application` and `core`

For complete details, see [coding_rules.md](coding_rules.md).
