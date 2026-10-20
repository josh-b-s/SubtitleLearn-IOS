import Testing
@testable import SubtitleLearn

struct MasteryFilterTests {
    @Test func eachLevelMatchesExactlyOneFilter() {
        for level in 1...Mastery.masteredLevel {
            let matches = MasteryFilter.allCases.filter { $0.matches(level: level) }
            #expect(matches.count == 1)
        }
    }

    @Test func levelsTwoAndThreeAreSeparate() {
        #expect(MasteryFilter.level2.matches(level: 2))
        #expect(!MasteryFilter.level2.matches(level: 3))
        #expect(MasteryFilter.level3.matches(level: 3))
    }
}
