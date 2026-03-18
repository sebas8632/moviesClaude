import Combine
import Foundation

protocol CoordinatorProtocol: AnyObject {
    func navigate(to route: AppRoute)
    func pop()
    func popToRoot()
}

final class AppCoordinator: ObservableObject, CoordinatorProtocol {
    @Published var path: [AppRoute] = []

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}
