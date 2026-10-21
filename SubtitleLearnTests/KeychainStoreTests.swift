import Testing
@testable import SubtitleLearn

struct KeychainStoreTests {
    private let key = "keychainStoreTests.sample"

    @Test func writesReadsAndDeletes() {
        KeychainStore.write("abc123", for: key)
        #expect(KeychainStore.read(key) == "abc123")

        KeychainStore.write("", for: key)
        #expect(KeychainStore.read(key) == nil)
    }
}
