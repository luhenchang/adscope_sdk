import Foundation

/// The native SDK initializes once per process. Only in-flight initialization is shared;
/// each waiting engine keeps its own completion and can detach independently.
final class AMPSInitializationCoordinator {
    static let shared = AMPSInitializationCoordinator()
    private var waiters: [UUID: (Int) -> Void] = [:]
    private var generation: UUID?
    private var poll: Timer?

    func initialize(
        requester: UUID,
        currentStatus: @escaping () -> Int,
        start: (@escaping (Int) -> Void) -> Void,
        completion: @escaping (Int) -> Void
    ) {
        if currentStatus() == 2 {
            completion(4) // already initialized
            return
        }
        waiters[requester] = completion
        if generation != nil {
            completion(1) // still waiting for the same native initialization
            return
        }
        let token = UUID()
        generation = token
        if currentStatus() != 1 {
            start { [weak self] status in
                self?.receive(status, token: token, currentStatus: currentStatus)
            }
        }
        // Also handles initialization started by a native host outside this plugin.
        if generation == token {
            poll = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                let status = currentStatus()
                if status == 2 || status == 3 {
                    self.receive(status, token: token, currentStatus: currentStatus)
                }
            }
        }
    }

    func cancel(requester: UUID) {
        waiters.removeValue(forKey: requester)
        if waiters.isEmpty {
            poll?.invalidate()
            poll = nil
            generation = nil
        }
    }

    private func receive(_ status: Int, token: UUID, currentStatus: @escaping () -> Int) {
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.receive(status, token: token, currentStatus: currentStatus)
            }
            return
        }
        guard generation == token else { return }
        guard status == 2 || status == 3 || (status == 4 && currentStatus() == 2) else { return }
        generation = nil
        poll?.invalidate()
        poll = nil
        let callbacks = Array(waiters.values)
        waiters.removeAll()
        callbacks.forEach { $0(status) }
    }

    deinit { poll?.invalidate() }
}
