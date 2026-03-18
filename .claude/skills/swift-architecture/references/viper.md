# VIPER — Guía de referencia

## Cuándo elegirlo
Apps muy grandes, equipos grandes con roles diferenciados, o cuando se necesita
separación estricta de responsabilidades y máxima testeabilidad por capa.
VIPER es verboso — no usarlo en apps pequeñas o con equipos reducidos.

---

## Estructura por feature

```
Features/
└── NombreFeature/
    ├── Protocols/
    │   └── NombreFeatureProtocols.swift   # Todos los contratos del feature
    ├── View/
    │   └── NombreFeatureView.swift        # SwiftUI View o UIViewController
    ├── Interactor/
    │   └── NombreFeatureInteractor.swift  # Lógica de negocio
    ├── Presenter/
    │   └── NombreFeaturePresenter.swift   # Transforma datos para la vista
    ├── Entity/
    │   └── NombreEntity.swift             # Modelos puros del feature
    └── Router/
        └── NombreFeatureRouter.swift      # Navegación
```

---

## Protocolos (definir primero)

```swift
// View → Presenter
protocol NombreFeatureViewProtocolo: AnyObject {
    func mostrarItems(_ items: [NombreViewModel])
    func mostrarError(_ mensaje: String)
    func mostrarCargando(_ cargando: Bool)
}

// Presenter → View
protocol NombreFeaturePresenterProtocolo: AnyObject {
    func viewDidLoad()
    func didSeleccionarItem(id: UUID)
}

// Presenter → Interactor
protocol NombreFeatureInteractorProtocolo: AnyObject {
    func obtenerItems() async throws -> [NombreEntity]
}

// Presenter → Router
protocol NombreFeatureRouterProtocolo: AnyObject {
    func navegarADetalle(id: UUID)
    func volver()
}
```

---

## Interactor — lógica de negocio

```swift
final class NombreFeatureInteractor: NombreFeatureInteractorProtocolo {
    private let repositorio: NombreRepositorioProtocolo

    init(repositorio: NombreRepositorioProtocolo) {
        self.repositorio = repositorio
    }

    func obtenerItems() async throws -> [NombreEntity] {
        try await repositorio.fetchAll()
    }
}
```

Reglas:
- No importa SwiftUI ni UIKit.
- Solo conoce Entities y protocolos de repositorio.
- Toda lógica de negocio vive aquí, nunca en el Presenter.

---

## Presenter — transformación de datos

```swift
final class NombreFeaturePresenter: NombreFeaturePresenterProtocolo {
    weak var view: NombreFeatureViewProtocolo?
    var interactor: NombreFeatureInteractorProtocolo
    var router: NombreFeatureRouterProtocolo

    init(interactor: NombreFeatureInteractorProtocolo,
         router: NombreFeatureRouterProtocolo) {
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {
        Task {
            do {
                view?.mostrarCargando(true)
                let entities = try await interactor.obtenerItems()
                let viewModels = entities.map { NombreViewModel(entity: $0) }
                await MainActor.run {
                    view?.mostrarCargando(false)
                    view?.mostrarItems(viewModels)
                }
            } catch {
                await MainActor.run {
                    view?.mostrarCargando(false)
                    view?.mostrarError(error.localizedDescription)
                }
            }
        }
    }

    func didSeleccionarItem(id: UUID) {
        router.navegarADetalle(id: id)
    }
}
```

Reglas:
- No contiene lógica de negocio — solo transforma datos para mostrarlos.
- La referencia a `view` es siempre `weak` para evitar retain cycles.
- Solo conoce ViewModels (structs de presentación), nunca Entities directamente en la vista.

---

## Entity — modelos puros

```swift
struct NombreEntity {
    let id: UUID
    let titulo: String
    let fecha: Date
}

// ViewModel de presentación (distinto del Entity)
struct NombreViewModel {
    let id: UUID
    let tituloFormateado: String
    let fechaFormateada: String

    init(entity: NombreEntity) {
        self.id = entity.id
        self.tituloFormateado = entity.titulo.capitalized
        self.fechaFormateada = DateFormatter.corto.string(from: entity.fecha)
    }
}
```

---

## Router — navegación

```swift
final class NombreFeatureRouter: NombreFeatureRouterProtocolo {
    weak var navigationController: UINavigationController?
    // O en SwiftUI: referencia al AppRouter con NavigationPath

    func navegarADetalle(id: UUID) {
        let detalle = DetalleFeatureBuilder.construir(id: id)
        navigationController?.pushViewController(detalle, animated: true)
    }

    func volver() {
        navigationController?.popViewController(animated: true)
    }
}
```

Reglas:
- Único componente que conoce UIKit / NavigationStack.
- Usa Builders/Factories para construir otros módulos VIPER.

---

## Builder — ensamblado del módulo

```swift
enum NombreFeatureBuilder {
    static func construir() -> UIViewController {
        let interactor = NombreFeatureInteractor(repositorio: NombreRepositorio())
        let router = NombreFeatureRouter()
        let presenter = NombreFeaturePresenter(interactor: interactor, router: router)
        let view = NombreFeatureViewController()

        view.presenter = presenter
        presenter.view = view
        router.navigationController = view.navigationController

        return view
    }
}
```
