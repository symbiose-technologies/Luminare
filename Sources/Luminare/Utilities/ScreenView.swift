//
//  ScreenView.swift
//  Luminare Tester
//
//  Created by Kai Azim on 2024-04-14.
//

import SwiftUI

public struct ScreenView<Content>: View where Content: View {

    let screenContent: () -> Content
    @State private var image: NSImage?

    public init(@ViewBuilder _ screenContent: @escaping () -> Content) {
        self.screenContent = screenContent
    }

    public var body: some View {
        ZStack {
            Group {
                GeometryReader { geo in
                    Group {
                        if let image = self.image {
                            Image(nsImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            ZStack {
                                Color.black

                                Image(systemName: "apple.logo")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                .allowsHitTesting(false)
                .task {
                    await updateImage()
                }
            }
            .overlay {
                if self.image != nil {
                    screenContent()
                        .padding(5)
                }
            }
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 12,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 12
            ))

            UnevenRoundedRectangle(
                topLeadingRadius: 12,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 12
            )
            .stroke(.gray, lineWidth: 2)

            UnevenRoundedRectangle(
                topLeadingRadius: 9.5,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 9.5
            )
            .stroke(.black, lineWidth: 5)
            .padding(2.5)

            UnevenRoundedRectangle(
                topLeadingRadius: 11.5,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 11.5
            )
            .stroke(.gray.opacity(0.2), lineWidth: 1)
            .padding(0.5)
        }
        .aspectRatio(16/10, contentMode: .fill)
    }

    func updateImage() async {
        if let screen = NSScreen.main,
           let url = NSWorkspace.shared.desktopImageURL(for: screen),
           let image = NSImage.resize(url: url, width: 300) {

            withAnimation {
                self.image = image
            }
        }
    }
}

extension NSImage {
    static func resize(url: URL, width: CGFloat) -> NSImage? {
        guard let inputImage = NSImage(contentsOf: url) else { return nil }

        let aspectRatio = inputImage.size.height / inputImage.size.width
        let targetSize = NSSize(
            width: width,
            height: width * aspectRatio
        )

        let frame = NSRect(
            x: 0,
            y: 0,
            width: targetSize.width,
            height: targetSize.height
        )

        guard let representation = inputImage.bestRepresentation(
            for: frame,
            context: nil,
            hints: nil
        ) else {
            return nil
        }

        let image = NSImage(
            size: targetSize,
            flipped: false
        ) { _ -> Bool in
            return representation.draw(in: frame)
        }

        return image
    }
}
