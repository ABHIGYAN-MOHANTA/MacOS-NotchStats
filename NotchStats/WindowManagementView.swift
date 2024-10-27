//
//  WindowManagementView.swift
//  NotchStats
//
//  Created by Abhigyan Mohanta on 27/10/24.
//


import SwiftUI

struct WindowManagementView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                WindowManager.shared.setupWindow(window)
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}
