import Testing
@testable import SubtitleLearn

struct SegmentationTests {
    private func entry(_ pinyin: String, _ meanings: String...) -> DictionaryEntry {
        DictionaryEntry(pinyin: pinyin, meanings: meanings)
    }

    private var dictionary: ChineseDictionary {
        ChineseDictionary(entries: [
            "喜欢": entry("xǐhuan", "to like"),
            "学习": entry("xuéxí", "to study"),
            "学习中文": entry("xuéxízhōngwén", "to study Chinese"),
            "中文": entry("zhōngwén", "Chinese")
        ])
    }

    @Test func splitsSentenceIntoDictionaryWords() {
        #expect(dictionary.segment("喜欢中文") == ["喜欢", "中文"])
    }

    @Test func prefersLongestMatch() {
        #expect(dictionary.segment("学习中文") == ["学习中文"])
    }

    @Test func unknownCharactersBecomeSingleCharWords() {
        #expect(dictionary.segment("我们") == ["我", "们"])
    }

    @Test func skipsLatinDigitsAndPunctuation() {
        #expect(dictionary.segment("hi 喜欢, 123!") == ["喜欢"])
    }

    @Test func emptyInputGivesNoWords() {
        #expect(dictionary.segment("").isEmpty)
    }

    @Test func tokensCarryMeaningsAndPositionIds() {
        let tokens = dictionary.tokens(for: "喜欢我")
        #expect(tokens.map(\.id) == [0, 1])
        #expect(tokens[0].meanings == ["to like"])
        #expect(tokens[0].pinyin == "xǐhuan")
    }

    @Test func unknownWordHasNoMeaningsButStillGetsPinyin() {
        let token = dictionary.tokens(for: "我")[0]
        #expect(token.meanings.isEmpty)
        #expect(!token.pinyin.isEmpty)
    }

    @Test func customEntryOverridesBundledOne() {
        let custom = dictionary.withCustom(["中文": entry("zhongwen", "my meaning")])
        #expect(custom.entry(for: "中文")?.meanings == ["my meaning"])
    }
}
