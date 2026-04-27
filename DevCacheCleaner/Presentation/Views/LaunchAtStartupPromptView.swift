//
//  LaunchAtStartupPromptView.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import SwiftUI

struct LaunchAtStartupPromptView: View {
    let onEnable: () -> Void
    let onNotNow: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {


            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 14) {
                    Image(systemName: "wrench.and.screwdriver")
                        .font(.title2)
                        .foregroundStyle(.primary)
                        .padding(.top, 2)
                    Text("Launch at Startup")
                        .font(.headline)
                }

                Text("Open DevCacheCleaner automatically when your Mac starts. You can change this later in Settings.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 10) {
                    Button("Not Now") {
                        onNotNow()
                    }

                    Button("Enable") {
                        onEnable()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top, 2)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.orange.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview {
    LaunchAtStartupPromptView(onEnable: {}, onNotNow: {})
}
