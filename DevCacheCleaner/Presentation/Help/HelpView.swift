//
//  HelpView.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import SwiftUI

struct HelpView: View {

    private let sections: [HelpSectionContent] = [
        .init(
            title: "Overview",
            paragraphs: [
                "DevCacheCleaner helps you reclaim disk space used by developer caches and generated project files on your Mac.",
                "It is designed to inspect storage first, then let you clean only the items you choose. Many of these files can be recreated later by tools such as Xcode, Swift Package Manager, Node.js, Gradle, or Flutter.",
                "The app relies on current folder structures to detect disposable files. If developer tools change how they store caches or generated data, some cleanup rules may need to be updated."
            ]
        ),
        .init(
            title: "Permissions",
            paragraphs: [
                "DevCacheCleaner needs access to your Home folder to scan the cache locations shown in the app.",
                "Workspace access is optional. If you select a workspace, the app only inspects that folder to find supported generated directories."
            ]
        ),
        .init(
            title: "What It Cleans",
            paragraphs: [
                "DevCacheCleaner can clean developer cache folders stored in your Home directory, along with generated workspace folders such as build output, dependency caches, and tool-specific temporary files.",
                "The amount of recoverable space depends on the tools you use and the projects stored on your Mac."
            ]
        ),
        .init(
            title: "Workspace Cleanup",
            paragraphs: [
                "Workspace cleanup focuses on generated folders rather than source code. Supported folders can include Node.js, SwiftPM, Android, and other tool-generated data when they are detected in the selected project.",
                "You can change the selected workspace at any time from Settings. If the workspace option is included in Clean All Caches, review it carefully before confirming cleanup."
            ]
        ),
        .init(
            title: "Launch at Startup",
            paragraphs: [
                "You can enable automatic startup from Settings or from the one-time suggestion shown after setup.",
                "macOS may still require approval in System Settings > Login Items before DevCacheCleaner can open automatically."
            ]
        ),
        .init(
            title: "Safety",
            paragraphs: [
                "Cleaning cache files cannot be undone. DevCacheCleaner is intended to remove generated and disposable files, not your source code or project documents.",
                "If you are unsure about a detected folder, review it before cleaning."
            ]
        ),
        .init(
            title: "Settings",
            paragraphs: [
                "Use Settings to change the selected workspace path and manage Launch at Startup.",
                "More cleanup-related options can be added there in future versions."
            ]
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                ForEach(sections.indices, id: \.self) { index in
                    HelpSectionView(
                        section: sections[index],
                        showsDivider: index < sections.count - 1
                    )
                }

                supportSection
            }
            .padding(28)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .textSelection(.enabled)
        .frame(width: 700, height: 620)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            Image("DevCacheCleanerIcon")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(Constants.About.displayName)
                .font(.system(size: 28, weight: .bold))
        }
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Support")
                .font(.title3)
                .fontWeight(.bold)

            Text("If you need more information or want to report an issue, use the links below.")
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)

            VStack(alignment: .leading, spacing: 8) {
                Link("Website: kangama.com", destination: Constants.About.websiteURL)
                Link("GitHub: macOS-dev-cache-cleaner", destination: Constants.About.gitHub)
                Link("LinkedIn: Karim Angama", destination: Constants.About.linkedInURL)
            }
            .font(.body)

            Divider()
                .padding(.top, 4)

            Text("Version \(Constants.About.version) (\(Constants.About.build))")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text("Copyright \(Constants.About.copyright) Karim Angama. All rights reserved.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    HelpView()
}
