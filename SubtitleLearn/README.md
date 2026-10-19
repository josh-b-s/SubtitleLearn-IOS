# Subtitle Learn

An iOS app for learning Mandarin from video and audio you already watch. It transcribes speech, splits it into words, shows each word with pinyin and meaning, and feeds saved words into a spaced repetition quiz.

Author: Josh Brian Saputra (34672087), FIT3178 P9 Custom App.

## Features

- Screen Share: a ReplayKit broadcast extension captures system audio and sends it to the app, which shows live subtitles in a picture in picture overlay.
- Translate: speak into the mic or paste text, tap a word to see its meaning, pinyin and per-character breakdown, and save it.
- Vocabulary: search and filter saved words by mastery level, change a word's level by hand, search the whole dictionary, add custom words, or add words you already know.
- Quiz: four mastery levels. Level 1 is multiple choice, level 2 matches pinyin and meaning, level 3 is fill in the blank, level 4 is fully learned. Scheduling uses SM-2. Missed questions come back at the end.
- Stats: streak, review heatmap and weekly learned words.

## Requirements

- Xcode 16 or later, iOS 18.5 deployment target.
- A real device for screen share and on-device speech recognition. The Simulator does not support either, so turn off "On-device recognition" in Settings there.
- Optional: a Gemini API key, entered under Settings. Without it, levels 1 and 2 still work and level 3 is skipped.

## Build and run

1. Open `SubtitleLearn.xcodeproj`.
2. Set your own signing team on the `SubtitleLearn` and `SubtitleBroadcast` targets.
3. Run the `SubtitleLearn` scheme. Allow microphone and speech recognition when asked.

## Project layout

- `SubtitleLearn/Models`: SwiftData models and quiz types.
- `SubtitleLearn/Services`: dictionary, segmentation, speech, spaced repetition, quiz builders, Gemini client.
- `SubtitleLearn/ViewModels`: state for the Translate, Screen Share and Quiz screens.
- `SubtitleLearn/Views`: SwiftUI views, one per file.
- `SubtitleBroadcast`: broadcast upload extension.
- `Shared`: code used by both the app and the extension.

## Acknowledgements

- Dictionary data: [CedPane](https://github.com/ssb22/CedPane) by ssb22, file `PD-English-Definitions.tsv`.
- Pinyin: merged from [CC-CEDICT](https://cc-cedict.org) (CC BY-SA) and [pypinyin](https://github.com/mozillazg/python-pinyin), which filled gaps when the word list was built.
- Google Gemini API, for level 3 example sentences.
- Apple frameworks: Speech, ReplayKit, AVKit, Charts, SwiftData.
- Some code was written with help from Claude (Anthropic).
