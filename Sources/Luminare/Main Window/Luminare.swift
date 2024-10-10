//
//  Luminare.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

public enum LuminareConstants {
    public static var tint: () -> Color = { .accentColor }
    public static var animation: Animation = .smooth(duration: 0.2)
    public static var fastAnimation: Animation = .easeOut(duration: 0.1)
}

public class LuminareWindow: NSWindow {
    private var initializationTime: Date

    public init(
        blurRadius: CGFloat? = nil,
        content: @escaping () -> some View
    ) {
        self.initializationTime = .now

        super.init(
            contentRect: .zero,
            styleMask: [.titled, .fullSizeContentView, .closable],
            backing: .buffered,
            defer: false // If true, background blur will break
        )

        let view = NSHostingView(
            rootView: LuminareView(content: content)
                .environment(\.tintColor, LuminareConstants.tint)
                .environment(\.luminareWindow, self)
        )

        contentView = view
        toolbarStyle = .unified
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        toolbar = NSToolbar()

        if let blurRadius {
            try? setBackgroundBlur(radius: Int(blurRadius))
            backgroundColor = .white.withAlphaComponent(0.001)
            ignoresMouseEvents = false
        }

        alphaValue = 0
    }

    public func show() {
        orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            self.animator().alphaValue = 1
        }
    }

    func setBackgroundBlur(radius: Int) throws {
        debugPrint("SKIPPING!")
        
    }
}
