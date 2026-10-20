import Testing
@testable import SubtitleLearn

struct PinyinSearchTests {
    private func entry(_ pinyin: String, _ meanings: String...) -> DictionaryEntry {
        DictionaryEntry(pinyin: pinyin, meanings: meanings)
    }

    private var dictionary: ChineseDictionary {
        ChineseDictionary(entries: [
            "喜欢": entry("xǐhuan", "like"),
            "洗": entry("xǐ", "wash"),
            "是": entry("shì", "be"),
            "母鸡": entry("mǔjī", "hen"),
            "和": entry("hé", "and"),
            "他": entry("tā", "he")
        ])
    }

    @Test func keyIgnoresCaseTonesAndSpaces() {
        #expect("Xǐ Huan".pinyinKey == "xihuan")
    }

    @Test func findsWordByPinyinWithoutTones() {
        #expect(dictionary.search("shi").map(\.word) == ["是"])
    }

    @Test func spacesInQueryAreIgnored() {
        #expect(dictionary.search("xi huan").map(\.word) == ["喜欢"])
    }

    @Test func exactPinyinRanksBeforePrefix() {
        #expect(dictionary.search("xi").map(\.word) == ["洗", "喜欢"])
    }

    @Test func exactEnglishMeaningRanksBeforePinyin() {
        #expect(dictionary.search("he").map(\.word) == ["他", "和", "母鸡"])
    }
}
