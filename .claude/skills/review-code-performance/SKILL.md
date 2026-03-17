Optimiza y refactoriza código Swift con problemas de performance. Usar siempre que el usuario comparta código Swift y mencione lentitud, lag, jank, memory leak, retain cycle, re-renders innecesarios, alto consumo de CPU o memoria, deadlock, o problemas de concurrencia. También activar cuando diga "optimiza esto", "refactoriza para que vaya más rápido", "hay un leak aquí", "cómo evito estos re-renders", o simplemente pegue código Swift pidiendo que mejore su performance.

# Swift Performance — Diagnóstico y Refactorización

## Objetivo
Analizar código Swift, identificar problemas de performance y producir un diagnóstico
claro. La refactorización es **opcional** — entregarla solo si el usuario la pide
explícitamente o da señales claras de quererla. Si el usuario pregunta "qué está mal"
o "qué mejorarías", entregar diagnóstico sin tocar el código. Las cuatro áreas de
análisis son: memoria, CPU/algoritmos, concurrencia y SwiftUI re-renders.

---

## Proceso

1. Leer el código completo antes de tocar nada.
2. Identificar todos los problemas de performance, clasificarlos por área y severidad.
3. **¿Refactorizar?** — Decidir según la intención del usuario:
   - "refactoriza", "corrígelo", "arréglalo", "optimiza el código" → entregar código refactorizado.
   - "qué hay mal", "qué mejorarías", "analiza", "revisa" → solo diagnóstico.
   - Ambiguo → entregar diagnóstico y ofrecer refactorizar al final.
4. Si hay decisiones de diseño ambiguas (e.g. `actor` vs `@MainActor`), mencionar el
   trade-off y preguntar antes de aplicar.

---

## Plantillas de output

Usar la plantilla según el modo elegido en el Proceso.

### Modo A — Solo diagnóstico

```
## ⚡ Swift Performance — Diagnóstico

**Archivo / Fragmento:** <nombre o descripción>
**Framework:** <SwiftUI | UIKit | Foundation | otro>
**Problemas encontrados:** <N> (<ej. "2 retain cycles, 1 O(n²), 1 re-render innecesario">)

---

### Hallazgos
<secciones por área, igual que en Modo B pero sin código refactorizado>

### Instrumentos recomendados para validar
<herramientas relevantes>

---
¿Quieres que refactorice el código aplicando estas correcciones?
```

---

### Modo B — Diagnóstico + refactorización

```
## ⚡ Swift Performance — Código Refactorizado

**Archivo / Fragmento:** <nombre o descripción>
**Framework:** <SwiftUI | UIKit | Foundation | otro>
**Problemas encontrados:** <N> (<ej. "2 retain cycles, 1 O(n²), 1 re-render innecesario">)

---

### Código refactorizado

```swift
<código completo corregido, con comentarios // ⚡ en cada línea modificada>
```

---

### Cambios realizados

#### 🧠 Memoria
<Omitir sección si no hubo cambios.>

**[MEM-1] <Título corto>**
- **Problema:** <qué había mal>
- **Solución:** <qué se cambió y por qué funciona>
- **Antes:**
  ```swift
  <fragmento original>
  ```
- **Después:**
  ```swift
  <fragmento corregido>
  ```

#### ⚙️ CPU / Algoritmos
<Omitir sección si no hubo cambios.>

**[CPU-1] <Título corto>**
- **Problema:** <complejidad original, cuello de botella>
- **Solución:** <nueva estrategia o complejidad>
- **Antes / Después:** <igual que arriba>

#### 🔀 Concurrencia
<Omitir sección si no hubo cambios.>

**[CON-1] <Título corto>**
- **Problema:** <race condition, main thread bloqueado, actor hop innecesario, etc.>
- **Solución:** <patrón aplicado y por qué>
- **Antes / Después:** <igual que arriba>

#### 🖼 SwiftUI Re-renders
<Omitir sección si el código no es SwiftUI o no hubo cambios.>

**[SWU-1] <Título corto>**
- **Problema:** <qué disparaba el rebuild innecesario>
- **Solución:** <Equatable, split de view, @StateObject, etc.>
- **Antes / Después:** <igual que arriba>

---

### Instrumentos recomendados para validar
<1-3 herramientas de Xcode Instruments para confirmar que los cambios tuvieron efecto.>
```

---

## Reglas de refactorización

**Comentarios inline:** Marcar cada línea modificada con `// ⚡` y una nota breve:
```swift
weak var delegate: MyDelegate?          // ⚡ weak rompe retain cycle
let ids: Set<String> = Set(rawIDs)      // ⚡ Set para búsqueda O(1)
async let user = fetchUser(id: id)      // ⚡ async let paraleliza llamadas independientes
```

**Preservar intención:** Nunca cambiar lógica de negocio. Si un cambio de performance
requiere alterar el comportamiento, mencionarlo y pedir confirmación antes de aplicarlo.

**Mínimo cambio necesario:** Refactorizar solo lo que impacta performance. El código
sin problemas debe quedar idéntico.

---

## Patrones de corrección por área

### 🧠 Memoria

**Retain cycles en closures:**
```swift
// ❌
viewModel.onUpdate = { self.updateUI() }

// ✅
viewModel.onUpdate = { [weak self] in   // ⚡ weak evita retain cycle
    self?.updateUI()
}
```

**Delegate como strong reference:**
```swift
// ❌
var delegate: MyDelegate?

// ✅
weak var delegate: (AnyObject & MyDelegate)?  // ⚡ weak delegate
```

**Boxing innecesario:**
```swift
// ❌
let items: [Any] = values.map { $0 as Any }

// ✅
let items: [MyType] = values            // ⚡ tipo concreto, sin boxing
```

---

### ⚙️ CPU / Algoritmos

**Búsqueda O(n) → O(1):**
```swift
// ❌
let isValid = validIDs.contains(where: { $0 == id })

// ✅
let validIDSet = Set(validIDs)
let isValid = validIDSet.contains(id)   // ⚡ Set: O(1) vs O(n)
```

**Cálculo repetido en loop:**
```swift
// ❌
for item in items {
    if item.value > threshold.calculate() { ... }  // N llamadas
}

// ✅
let limit = threshold.calculate()       // ⚡ calcular una sola vez
for item in items {
    if item.value > limit { ... }
}
```

**lazy para colecciones grandes:**
```swift
// ❌
let result = items.filter { $0.isActive }.map { $0.name }.first  // 2 arrays intermedios

// ✅
let result = items.lazy                 // ⚡ lazy: sin arrays intermedios
    .filter { $0.isActive }
    .map { $0.name }
    .first
```

---

### 🔀 Concurrencia

**Main thread bloqueado:**
```swift
// ❌
func loadData() {
    let data = heavySync()
    updateUI(data)
}

// ✅
func loadData() async {
    let data = await fetchData()        // ⚡ no bloquea main thread
    await MainActor.run { updateUI(data) }  // ⚡ UI en main actor
}
```

**Llamadas independientes en serie:**
```swift
// ❌
let user     = await fetchUser(id: id)
let settings = await fetchSettings()

// ✅
async let user     = fetchUser(id: id)  // ⚡ paralelo con async let
async let settings = fetchSettings()
let (u, s) = await (user, settings)
```

**Race condition en estado compartido:**
```swift
// ❌
class Cache {
    var data: [String: Data] = [:]      // acceso concurrente sin protección
}

// ✅
actor Cache {                           // ⚡ actor serializa el acceso
    var data: [String: Data] = [:]
}
```

---

### 🖼 SwiftUI Re-renders

**@ObservedObject vs @StateObject:**
```swift
// ❌
@ObservedObject var vm = MyViewModel()  // puede recrearse en cada rebuild del padre

// ✅
@StateObject private var vm = MyViewModel()  // ⚡ persiste el ciclo de vida
```

**Equatable para skip de rebuild:**
```swift
// ❌
struct ItemView: View {
    let item: Item                      // SwiftUI no puede comparar → siempre redibuja
}

// ✅
struct ItemView: View, Equatable {      // ⚡ SwiftUI omite rebuild si item no cambió
    let item: Item                      // Item también debe ser Equatable
}
```

**Aislar estado dinámico en subview:**
```swift
// ❌
var body: some View {
    VStack {
        HeavyStaticContent()            // se reevalúa aunque no cambia nada
        DynamicCounter(count: $count)
    }
}

// ✅
var body: some View {
    VStack {
        HeavyStaticContent()            // ⚡ struct separado: SwiftUI lo diffea solo
        DynamicCounter(count: $count)
    }
}
// HeavyStaticContent como struct independiente con sus propios @State
```

---

## Instrumentos de Xcode por problema

Mencionar solo los relevantes al caso:

| Problema detectado | Instrumento |
|---|---|
| Retain cycles / leaks | **Leaks** + **Allocations** en Instruments |
| Alto consumo CPU | **Time Profiler** en Instruments |
| Main thread bloqueado | **Main Thread Checker** (Runtime Issues en Xcode) |
| SwiftUI re-renders | **SwiftUI View Body** en Instruments (Xcode 15+) |
| Data races | **Thread Sanitizer** (TSan) en el esquema de Xcode |
| Memoria general | **Memory Graph Debugger** en la barra de debug de Xcode |