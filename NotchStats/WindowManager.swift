//
//  WindowManager.swift
//  NotchStats
//
//  Created by Abhigyan Mohanta on 27/10/24.
//


import SwiftUI
import AppKit

class WindowManager: NSObject {
    static let shared = WindowManager()
    var window: NSWindow?
    
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
            
            let xPos = (screenRect.width - windowWidth) / 2
            let yPos = screenRect.height - windowHeight
            
            window.setFrame(NSRect(x: xPos, y: yPos, width: windowWidth, height: windowHeight), display: true)
        }
        
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
    }
}
