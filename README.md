# Subtitle Learn

An iOS app for learning Mandarin from video and audio you already watch. It transcribes speech, splits it into words, shows each word with pinyin and meaning, and feeds saved words into a spaced repetition quiz.

Author: Josh Brian Saputra (34672087), FIT3178 P9 Custom App.

## Features

- Screen Share: a ReplayKit broadcast extension captures system audio and sends it to the app, which shows live subtitles in a picture in picture overlay. Each session ends with a summary of the words heard, and the latest transcript stays available. A short audio clip is kept for each word so it can be replayed as it was said.
- Translate: speak into the mic or paste text, tap a word to see its meaning, pinyin and per-character breakdown, and save it.
- Vocabulary: search, sort and filter saved words by mastery level, change a word's level by hand, search the whole dictionary, add custom words, or add words you already know.
- Quiz: four mastery levels, scheduled with SM-2. Each level has two question types, chosen by the word's progress through the level.
  - Level 1: multiple choice, Chinese to English and then English to Chinese.
  - Level 2: match a word with its pinyin and meaning, in both directions.
  - Level 3: a listening question, then a fill in the blank question using a sentence from Gemini.
  - Level 4: fully learned, never quizzed again.
  - Missed questions come back at the end. Past quizzes are kept in a history.
- Hints: once a word passes level 1 its meaning is hidden in subtitles, and once it passes level 2 its pinyin is hidden too. Both can be switched off in Settings.
- Stats: streak, review heatmap and weekly learned words.
- Review reminders: an optional daily notification at a time you choose, shown only on days when words are due.
- Home screen widget: words due today and your current streak.
- Settings: appearance, speech recognition mode, questions per quiz, slower speech, reminders, Gemini key, and an About page.
- Onboarding: a short tour on first launch.

## Requirements

- Xcode 16 or later, iOS 18.5 deployment target.
- A real device for screen share and on-device speech recognition. The Simulator does not support either, so turn off "On-device recognition" in Settings there.
- Optional: a Gemini API key, entered under Settings and stored in the Keychain. Without it, levels 1 and 2 and the listening question at level 3 still work, and the fill in the blank question is replaced by an easier one.

## Build and run

1. Open `SubtitleLearn.xcodeproj`.
2. Set your own signing team on the `SubtitleLearn`, `SubtitleBroadcast` and `SubtitleWidgetExtension` targets.
3. The app, the broadcast extension and the widget share data through the App Group `group.com.SubtitleLearn`. If you change the app's bundle identifier, change the group in all three entitlements files to `group.` plus the new identifier. `BroadcastShared` builds the group name from the bundle identifier, so the two must match.
4. Run the `SubtitleLearn` scheme. Allow microphone, speech recognition and notifications when asked.

## Tests

Run the `SubtitleLearn` scheme tests in Xcode (Cmd+U). The unit tests cover mastery rules, SM-2 scheduling, word segmentation, pinyin search, vocabulary sorting and filtering, the session word tracker, stats, reminder planning, the widget snapshot and the Keychain store.

## Project layout

- `SubtitleLearn/App`: app entry point and root view.
- `SubtitleLearn/Models`: SwiftData models and quiz types, grouped by Vocabulary, Quiz, Session, Stats and Settings.
- `SubtitleLearn/Services`: Dictionary, Vocabulary, Learning (mastery and spaced repetition), Audio, Speech, Quiz, Session, Stats, Pip, Gemini, Reminders, Widget and Settings.
- `SubtitleLearn/ViewModels`: state for the Translate, Screen Share, Quiz and dictionary search screens.
- `SubtitleLearn/Views`: SwiftUI views, one per file, grouped by screen. `Components` holds views used across screens.
- `SubtitleLearn/Resources`: dictionary and sample audio.
- `SubtitleBroadcast`: broadcast upload extension.
- `SubtitleWidget`: home screen widget extension.
- `Shared`: code used by the app and the extensions.
- `SubtitleLearnTests`, `SubtitleLearnUITests`: unit and UI tests.
- `docs`: feature list and review notes.

## Acknowledgements

- Dictionary data: [CedPane](https://github.com/ssb22/CedPane) by ssb22, file `PD-English-Definitions.tsv`.
- Pinyin: merged from [CC-CEDICT](https://cc-cedict.org) (CC BY-SA) and [pypinyin](https://github.com/mozillazg/python-pinyin), which filled gaps when the word list was built.
- Google Gemini API, for level 3 example sentences.
- Apple frameworks: Speech, ReplayKit, AVKit, Charts, SwiftData, WidgetKit, UserNotifications.
- Some code was written with help from Claude (Anthropic).