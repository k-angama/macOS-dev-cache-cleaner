import Testing
@testable import DevCacheCleaner

@MainActor
struct WorkspaceCleanupRuleEntityTests {

    @Test func supportedRulesDescribeInitialWorkspaceTargets() {
        let rules = WorkspaceCleanupRuleEntity.supportedRules

        #expect(rules.count == 2)
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
    }
}

