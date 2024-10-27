//
//  MouseTrackingView.swift
//  NotchStats
//
//  Created by Abhigyan Mohanta on 27/10/24.
//

import AppKit

class MouseTrackingView: NSView {
    private var trackingArea: NSTrackingArea?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        // Remove the old tracking area if it exists
        if let existingTrackingArea = trackingArea {
            removeTrackingArea(existingTrackingArea)
        }

        // Define the global tracking area around the notch location
        guard let screen = NSScreen.main else { return }
        let notchWidth: CGFloat = 100
        let notchHeight: CGFloat = 40
        let xPos = (screen.frame.width - notchWidth) / 2
        let yPos = screen.frame.height - notchHeight
        let trackingRect = NSRect(x: xPos, y: yPos, width: notchWidth, height: notchHeight)

        // Create and add the tracking area with global and persistent options
        trackingArea = NSTrackingArea(
            rect: trackingRect,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect, .assumeInside],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea!)
    }

}
