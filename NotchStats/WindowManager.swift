//
//  WindowManager.swift
//  NotchStats
//
//  Created by Abhigyan Mohanta on 27/10/24.
//

import AppKit

class WindowManager: NSObject {
    static let shared = WindowManager()
    var window: NSWindow?
    var mouseTrackingMonitor: Any?

    // Define the notch area position and size
    private var notchArea: CGRect {
        guard let screen = NSScreen.main else { return .zero }
        let notchWidth: CGFloat = 100
        let notchHeight: CGFloat = 40
        let xPos = (screen.frame.width - notchWidth) / 2
        let yPos = screen.frame.height - notchHeight
        return CGRect(x: xPos, y: yPos, width: notchWidth, height: notchHeight)
    }

    func setupWindow(_ window: NSWindow) {
        self.window = window
        window.level = .statusBar
        window.styleMask = [.borderless]
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false

        if let screen = NSScreen.main {
            let screenRect = screen.frame
            let windowWidth: CGFloat = 500
            let windowHeight: CGFloat = 40

            // Center the window at the top of the screen
            let xPos = (screenRect.width - windowWidth) / 2
            let yPos = screenRect.height - windowHeight
            window.setFrame(NSRect(x: xPos, y: yPos, width: windowWidth, height: windowHeight), display: true)
        }

        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        startMouseTracking()
    }

    private func startMouseTracking() {
        // Remove any existing event monitor
        if let monitor = mouseTrackingMonitor {
            NSEvent.removeMonitor(monitor)
        }

        // Create a new global event monitor to track mouse movements
        mouseTrackingMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
            self?.handleGlobalMouseMoved(event: event)
        }
    }

    private func handleGlobalMouseMoved(event: NSEvent) {
        guard let window = window else { return }
        let mouseLocation = NSEvent.mouseLocation  // Get the mouse location in screen coordinates
        
        if notchArea.contains(mouseLocation) {
            print("Mouse entered notch area")  // Debug log
            window.orderFront(nil)
        } else {
            print("Mouse exited notch area")  // Debug log
            window.orderOut(nil)
        }
    }

    deinit {
        // Remove the event monitor when WindowManager is deinitialized
        if let monitor = mouseTrackingMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
