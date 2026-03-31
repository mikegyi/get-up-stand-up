import AppKit
import Combine
import SwiftUI

@MainActor
final class StatusBarController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let popover = NSPopover()
    private let reminderEngine: ReminderEngine
    private var cancellables = Set<AnyCancellable>()

    init(settings: AppSettings, reminderEngine: ReminderEngine) {
        self.reminderEngine = reminderEngine
        super.init()

        popover.behavior = .transient
        popover.contentSize = NSSize(width: 320, height: 360)
        popover.contentViewController = NSHostingController(
            rootView: MenuBarView(reminderEngine: reminderEngine, settings: settings)
        )

        if let button = statusItem.button {
            button.target = self
            button.action = #selector(togglePopover(_:))
        }

        reminderEngine.objectWillChange
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.refreshLabel()
                }
            }
            .store(in: &cancellables)

        refreshLabel()
    }

    @objc private func togglePopover(_ sender: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(sender)
            return
        }

        popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
    }

    private func refreshLabel() {
        statusItem.button?.title = reminderEngine.menuBarLabelText()
    }
}
