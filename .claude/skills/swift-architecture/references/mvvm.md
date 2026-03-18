# MVVM — Guía de referencia

## Cuándo elegirlo
Apps medianas, equipos familiarizados con SwiftUI, features con lógica de presentación
moderada. Es el patrón de entrada recomendado para proyectos nuevos.

---

## Estructura por feature

```
Features/
└── NombreFeature/
    ├── Model/
    │   └── NombreModel.swift          # Struct puro, sin dependencias externas
    ├── ViewModel/
    │   └── NombreViewModel.swift      # @Observable, lógica de presentación
    └── View/
        ├── NombreView.swift           # Vista principal
        └── Subviews/
            └── NombreRowView.swift    # Subvistas extraídas
```

---

## Reglas de cada capa

### Model
- Siempre `struct`, nunca `class` salvo que se necesite identidad por referencia.
- Sin imports de SwiftUI, UIKit ni frameworks de red.
- Codable si viene de API.

```swift
struct Usuario: Codable, Identifiable {
    let id: UUID
    var nombre: String
    var email: String
}
```

### ViewModel
- Nunca importa SwiftUI.
- Usa `@Observable` (Swift 5.9+) o `ObservableObject` + `@Published`.
- Toda lógica de negocio y transformación de datos vive aquí.
- Depende de servicios/repositorios por protocolo, nunca por implementación concreta.

```swift
@Observable
final class UsuarioViewModel {
    private let repositorio: UsuarioRepositorioProtocolo

    var usuarios: [Usuario] = []
    var isLoading = false
    var errorMensaje: String?

    init(repositorio: UsuarioRepositorioProtocolo) {
        self.repositorio = repositorio
    }

    func cargarUsuarios() async {
        isLoading = true
        defer { isLoading = false }
        do {
            usuarios = try await repositorio.obtenerTodos()
        } catch {
            errorMensaje = error.localizedDescription
        }
    }
}
```

### View
- Solo bindings, layout y llamadas al ViewModel.
- Sin lógica de negocio ni transformaciones de datos.
- Extraer subviews cuando `body` supera ~30 líneas o 3 niveles de anidación.

```swift
struct UsuarioView: View {
    @State private var viewModel = UsuarioViewModel(
        repositorio: UsuarioRepositorio()
    )

    var body: some View {
        List(viewModel.usuarios) { usuario in
            UsuarioRowView(usuario: usuario)
        }
        .task { await viewModel.cargarUsuarios() }
        .overlay { if viewModel.isLoading { ProgressView() } }
    }
}
```

---

## Contratos esperados (protocolos)

Definir siempre antes de implementar:

```swift
protocol UsuarioRepositorioProtocolo {
    func obtenerTodos() async throws -> [Usuario]
    func guardar(_ usuario: Usuario) async throws
    func eliminar(id: UUID) async throws
}
```

---

## Navegación en MVVM

Usar `NavigationStack` con un `NavigationPath` centralizado en un `AppRouter`:

```swift
@Observable
final class AppRouter {
    var path = NavigationPath()

    func navegar(a destino: Destino) {
        path.append(destino)
    }

    func volver() {
        path.removeLast()
    }
}
```

---

## Cuándo escalar a Clean Architecture

Si el ViewModel empieza a tener más de 200 líneas, o si la lógica de negocio
es la misma en múltiples features, es momento de extraer UseCases y migrar a Clean.
