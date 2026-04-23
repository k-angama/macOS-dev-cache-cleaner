import Testing
@testable import DevCacheCleaner

@MainActor
struct WorkspaceCleanupRuleEntityTests {

    @Test func supportedRulesDescribeInitialWorkspaceTargets() {
        let rules = WorkspaceCleanupRuleEntity.supportedRules

        #expect(rules.count == 5)
        #expect(rules.contains(
            WorkspaceCleanupRuleEntity(
                kind: .nodeModules,
                markerFileName: "package.json",
                generatedDirectoryName: "node_modules"
            )
        ))
        #expect(rules.contains(
            WorkspaceCleanupRuleEntity(
                kind: .cocoaPods,
                markerFileName: "Podfile",
                generatedDirectoryName: "Pods"
            )
        ))
        #expect(rules.contains(
            WorkspaceCleanupRuleEntity(
                kind: .swiftPackageManager,
                markerFileName: "Package.swift",
                generatedDirectoryName: ".build"
            )
        ))
        #expect(rules.contains(
            WorkspaceCleanupRuleEntity(
                kind: .androidGradle,
                markerFileName: "settings.gradle",
                alternateMarkerFileNames: ["settings.gradle.kts"],
                generatedDirectoryName: ".gradle"
            )
        ))
        #expect(rules.contains(
            WorkspaceCleanupRuleEntity(
                kind: .androidBuild,
                markerFileName: "build.gradle",
                alternateMarkerFileNames: ["build.gradle.kts"],
                generatedDirectoryName: "build"
            )
        ))
    }
}
