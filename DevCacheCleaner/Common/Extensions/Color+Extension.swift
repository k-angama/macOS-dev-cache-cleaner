//
//  Color+Extension.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 17/03/2026.
//

import AppKit
import Foundation
import SwiftUI

extension Color: @retroactive Codable {
    private struct RGBAColor: Codable {
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double
    }

    public init(from decoder: Decoder) throws {
        let color = try RGBAColor(from: decoder)
        self = Color(
            .sRGB,
            red: color.red,
            green: color.green,
            blue: color.blue,
            opacity: color.alpha
        )
    }

    public func encode(to encoder: Encoder) throws {
        guard let color = NSColor(self).usingColorSpace(.sRGB) else {
            throw EncodingError.invalidValue(
                self,
                EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription: "Unable to convert Color to sRGB."
                )
            )
        }

        try RGBAColor(
            red: Double(color.redComponent),
            green: Double(color.greenComponent),
            blue: Double(color.blueComponent),
            alpha: Double(color.alphaComponent)
        ).encode(to: encoder)
    }
}
