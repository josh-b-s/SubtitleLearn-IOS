import Testing
@testable import SubtitleLearn

struct ShortMeaningsTests {
    @Test func stripsToPrefixNotesAndDuplicates() {
        let result = ChineseDictionary.shortMeanings("to eat/to consume (formal)/Eat/food")
        #expect(result == ["eat", "consume", "food"])
    }

    @Test func keepsAtMostThreeMeanings() {
        let result = ChineseDictionary.shortMeanings("a/b/c/d/e")
        #expect(result == ["a", "b", "c"])
    }

    @Test func splitsOnSemicolonsAndCommas() {
        #expect(ChineseDictionary.shortMeanings("big; large, huge") == ["big", "large", "huge"])
    }

    @Test func capitalisesLoneI() {
        #expect(ChineseDictionary.shortMeanings("i") == ["I"])
    }

    @Test func emptyDefinitionGivesNothing() {
        #expect(ChineseDictionary.shortMeanings("").isEmpty)
    }
}
