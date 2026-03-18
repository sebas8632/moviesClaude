# Clean Architecture — Guía de referencia

## Cuándo elegirlo
Apps con dominio de negocio complejo que debe ser independiente de la UI, apps
multi-plataforma (iOS + macOS + watchOS), o proyectos de larga vida donde la
lógica de negocio debe poder testearse sin framework alguno.

---

## Estructura del proyecto

```
AppName/
├── Domain/                          # Capa interna — cero dependencias externas
│   ├── Entities/                    # Modelos de negocio puros
│   ├── UseCases/                    # Casos de uso: una acción = un archivo
│   └── Interfaces/                  # Protocolos que Infrastructure implementa
│       ├── Repositories/
│       └── Services/
│
├── Infrastructure/                  # Implementaciones concretas
│   ├── Networking/
│   │   ├── APIClient.swift
│   │   └── Endpoints/
│   ├── Persistence/
│   │   └── SwiftDataRepository.swift
│   └── Repositories/               # Implementan los protocolos de Domain
│       └── UsuarioRepositorioImpl.swift
│
└── Presentation/                    # Capa externa — consume Domain
    ├── ViewModels/
    └── Views/
```

**Regla de dependencias:** Las flechas apuntan siempre hacia adentro.
`Presentation → Domain ← Infrastructure`
Domain no conoce a nadie. Infrastructure y Presentation conocen a Domain.

---

## Domain — Entities

```swift
// Sin imports de frameworks externos
struct Usuario {
    let id: UUID
    var nombre: String
    var email: String
    var fechaRegistro: Date
}

// Errores de dominio — no HTTP, no CoreData, errores de negocio
enum UsuarioError: Error {
    case noEncontrado
    case emailInvalido
    case sinPermiso
}
```

---

## Domain — Interfaces (protocolos)

```swift
// Lo que Infrastructure debe implementar
protocol UsuarioRepositorioProtocolo {
    func obtener(id: UUID) async throws -> Usuario
    func obtenerTodos() async throws -> [Usuario]
    func guardar(_ usuario: Usuario) async throws
    func eliminar(id: UUID) async throws
}
```

---

## Domain — UseCases

Un UseCase = una acción de negocio. Reciben dependencias por protocolo.

```swift
struct ObtenerUsuariosUseCase {
    private let repositorio: UsuarioRepositorioProtocolo

    init(repositorio: UsuarioRepositorioProtocolo) {
        self.repositorio = repositorio
    }

    func ejecutar() async throws -> [Usuario] {
        let usuarios = try await repositorio.obtenerTodos()
        // Lógica de negocio: ordenar, filtrar, validar
        return usuarios.sorted { $0.fechaRegistro > $1.fechaRegistro }
    }
}

struct CrearUsuarioUseCase {
    private let repositorio: UsuarioRepositorioProtocolo

    func ejecutar(nombre: String, email: String) async throws -> Usuario {
        guard email.contains("@") else { throw UsuarioError.emailInvalido }
        let usuario = Usuario(id: UUID(), nombre: nombre, email: email, fechaRegistro: .now)
        try await repositorio.guardar(usuario)
        return usuario
    }
}
```

Reglas:
- Un UseCase no llama a otro UseCase.
- No importa SwiftUI, UIKit, Alamofire ni ningún framework externo.
- La lógica de negocio compleja vive aquí, no en el ViewModel ni en el Repositorio.

---

## Infrastructure — Repositorio (implementación)

```swift
final class UsuarioRepositorioImpl: UsuarioRepositorioProtocolo {
    private let apiClient: APIClientProtocolo
    private let cache: CacheProtocolo

    init(apiClient: APIClientProtocolo, cache: CacheProtocolo) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func obtenerTodos() async throws -> [Usuario] {
        if let cached = await cache.get([Usuario].self, key: "usuarios") {
            return cached
        }
        let dtos = try await apiClient.get([UsuarioDTO].self, endpoint: .usuarios)
        let usuarios = dtos.map { $0.toDomain() }  // DTO → Entity de Domain
        await cache.set(usuarios, key: "usuarios")
        return usuarios
    }
}
```

Reglas:
- El repositorio traduce de DTO/CoreData/SwiftData → Entity de Domain. Nunca exponer
  modelos de infraestructura (DTOs, NSManagedObject) fuera de esta capa.
- Puede importar Alamofire, SwiftData, etc. — eso es su responsabilidad.

---

## Presentation — ViewModel

```swift
@Observable
final class UsuarioListViewModel {
    private let obtenerUsuarios: ObtenerUsuariosUseCase

    var usuarios: [Usuario] = []
    var isLoading = false
    var errorMensaje: String?

    init(obtenerUsuarios: ObtenerUsuariosUseCase) {
        self.obtenerUsuarios = obtenerUsuarios
    }

    func cargar() async {
        isLoading = true
        defer { isLoading = false }
        do {
            usuarios = try await obtenerUsuarios.ejecutar()
        } catch {
            errorMensaje = error.localizedDescription
        }
    }
}
```

El ViewModel solo habla con UseCases, nunca directamente con repositorios o API.

---

## Ensamblado por Composition Root

Toda la inyección de dependencias ocurre en un único punto:

```swift
enum CompositionRoot {
    static func makeUsuarioListView() -> some View {
        let apiClient = APIClient()
        let repositorio = UsuarioRepositorioImpl(apiClient: apiClient, cache: MemoryCache())
        let useCase = ObtenerUsuariosUseCase(repositorio: repositorio)
        let viewModel = UsuarioListViewModel(obtenerUsuarios: useCase)
        return UsuarioListView(viewModel: viewModel)
    }
}
```

---

## Cuándo NO usar Clean Architecture

- App sencilla tipo CRUD sin lógica de negocio compleja → MVVM es suficiente.
- Equipo pequeño sin experiencia previa en el patrón → curva alta, adoptar progresivamente.
- Prototipo o MVP → sobre-ingeniería innecesaria en fase temprana.
