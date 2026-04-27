//
//  AboutView.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 24/03/2026.
//

import SwiftUI

struct AboutView: View {
    
    var body: some View {
        VStack(spacing: 16) {
            Image("DevCacheCleanerIcon")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 12, y: 6)

            VStack(spacing: 6) {
                Text(Constants.About.displayName)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Version \(Constants.About.version) (\(Constants.About.build))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Divider()
            
            
            VStack(alignment: .leading ,spacing: 8) {
                Link(destination: Constants.About.websiteURL) {
                    Label("kangama.com", systemImage: "globe")
                        .font(.footnote)
                }

                Link(destination: Constants.About.linkedInURL) {
                    Label("LinkedIn", systemImage: "person.crop.square")
                        .font(.footnote)
                }
                Link(destination: Constants.About.gitHub) {
                    Label("GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                        .font(.footnote)
                }
            }
            
            Divider()

            Text("Copyright \(Constants.About.copyright) Karim Angama. All rights reserved.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(width: 320)
    }
}

#Preview {
    AboutView()
}
