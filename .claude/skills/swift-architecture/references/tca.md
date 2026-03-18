# TCA — Guía de referencia

## Cuándo elegirlo
Apps grandes con flujos complejos, muchos estados intermedios, navegación profunda,
o cuando la testabilidad total es un requisito. Requiere que el equipo conozca el
paradigma — tiene curva de aprendizaje.

Dependencia: `github.com/pointfreeco/swift-composable-architecture`

---

## Estructura por feature

```
Features/
└── NombreFeature/
    ├── NombreFeature.swift        # State, Action, Reducer en un solo archivo
    ├── NombreFeatureView.swift    # Vista que consume el Store
    └── Dependencies/
        └── NombreClient.swift     # @DependencyClient del feature
```

---

## Anatomía del Reducer

```swift
@Reducer
struct NombreFeature {

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var items: [Item] = []
        var isLoading = false
        var errorMensaje: String?
    }

    // MARK: - Action
    enum Action {
        case cargarItems
        case itemsCargados(Result<[Item], Error>)
        case eliminarItem(id: UUID)
    }

    // MARK: - Dependencies
    @Dependency(\.itemClient) var itemClient

    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cargarItems:
                state.isLoading = true
                return .run { send in
                    await send(.itemsCargados(
                        Result { try await itemClient.obtenerTodos() }
                    ))
                }

            case let .itemsCargados(.success(items)):
                state.isLoading = false
                state.items = items
                return .none

            case let .itemsCargados(.failure(error)):
                state.isLoading = false
                state.errorMensaje = error.localizedDescription
                return .none

            case let .eliminarItem(id):
                state.items.removeAll { $0.id == id }
                return .none
            }
        }
    }
}
```

---

## Definir un DependencyClient

```swift
@DependencyClient
struct ItemClient {
    var obtenerTodos: @Sendable () async throws -> [Item]
    var guardar: @Sendable (Item) async throws -> Void
}

extension ItemClient: DependencyKey {
    static let liveValue = ItemClient(
        obtenerTodos: { try await ItemAPIService().fetchAll() },
        guardar: { item in try await ItemAPIService().save(item) }
    )

    // Para tests: implementación controlada
    static let testValue = ItemClient()
}

extension DependencyValues {
    var itemClient: ItemClient {
        get { self[ItemClient.self] }
        set { self[ItemClient.self] = newValue }
    }
}
```

---

## Vista con Store

```swift
struct NombreFeatureView: View {
    @Bindable var store: StoreOf<NombreFeature>

    var body: some View {
        List(store.items) { item in
            ItemRowView(item: item)
                .swipeActions {
                    Button(role: .destructive) {
                        store.send(.eliminarItem(id: item.id))
                    } label: {
                        Label("Eliminar", systemImage: "trash")
                    }
                }
        }
        .task { store.send(.cargarItems) }
        .overlay { if store.isLoading { ProgressView() } }
    }
}
```

---

## Composición de features hijo

```swift
@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var lista = ListaFeature.State()
        var detalle: DetalleFeature.State?
    }

    enum Action {
        case lista(ListaFeature.Action)
        case detalle(DetalleFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.lista, action: \.lista) {
            ListaFeature()
        }
        .ifLet(\.detalle, action: \.detalle) {
            DetalleFeature()
        }
    }
}
```

---

## Reglas estrictas de TCA

- Todo efecto pasa por `.run` o `.send` — nunca side effects directos en el reducer.
- El reducer es siempre una función pura: mismo input → mismo output.
- Dependencias SIEMPRE por `@Dependency`, nunca instanciadas dentro del reducer.
- State siempre `Equatable` — TCA lo necesita para optimizar actualizaciones.
- Nunca compartir Store entre features — componer con `Scope`.
