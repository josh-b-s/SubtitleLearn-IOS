# Subtitle Learn: features and review

## Current features

### Capture
- Screen Share: a ReplayKit broadcast extension captures system audio and the app shows live subtitles in a picture in picture window.
- Session summary after each share, and a transcript of the latest session.
- Audio clips are saved per word, so a word can be replayed as it was heard.
- Translate: speak into the mic or paste text, then tap a word for pinyin, meanings and a per-character breakdown.

### Vocabulary
- Save words from Translate, the transcript or dictionary search.
- Add custom words, or add words you already know at a chosen level.
- Search, sort and filter by mastery level, and change a level by hand.
- Offline dictionary search.
- Word detail sheet with pronunciation, clip replay and the mastery picker.

### Quiz
- Four levels: multiple choice, pinyin and meaning match, listening + fill in the blank, learned.
- SM-2 scheduling. Missed questions come back at the end.
- Quiz history, and a review quiz built from a session's words.
- Level 3 sentences come from Gemini and are cached on the device.

### Stats
- Streak badge, review heatmap and weekly learned, saved and mastered counts.

### Settings and polish
- Theme, on-device speech toggle, hide hints for learned words, questions per quiz.
- Gemini API key stored in the Keychain, with migration from the old UserDefaults value.
- Speak slowly: one setting that slows synthesized speech in the word sheet and quizzes, and slows clip replay. It can be toggled from Settings, from the quiz toolbar and from the word detail sheet.
- First-launch onboarding and a privacy manifest.

## Planned work

1. **Review reminders.** A daily local notification when words are due, with a time picker in Settings. Settings explains what the reminder is for before the permission prompt appears.
2. **Vocabulary export.** CSV through `ShareLink` as an interim backup, since a reinstall wipes the data. iCloud sync needs a model change first, because CloudKit rejects `@Attribute(.unique)` on `SavedWord`.
3. **Sentence translation.** Optional whole-sentence translation under the word breakdown on Translate and in the transcript, using `GeminiClient`. Hidden when no key is set.
4. **Cloze without Gemini.** Build level 3 questions from sentences the app already transcribed, so the quiz works without a key and stays tied to the user's own audio. `SessionTranscriptStore` keeps only the latest session, so each saved word would need its source sentence stored with it.


## Future ideas

### Learning
- Listening quiz: hear a word or clip and pick the meaning.
- Source sentence and clip shown on each saved word.
- HSK level tags, with a filter and a goal.
- Tone colours on pinyin.
- Traditional character toggle.
- Daily review goal and a streak freeze.

### Capture
- Import an SRT or text file for content without live audio.
- Transcript history across sessions, not just the latest.
- Paste or share-sheet input from other apps.

### Platform
- Home screen widget with the due count and streak.
- CSV import to pair with export.
- iCloud sync after the model change.
- iPad layout, including replacing `UIScreen.main` for PiP sizing.

### Quality
- Clear messages when the Mandarin on-device model is missing, or server recognition hits its time limit.
- Long-session testing of the broadcast extension on a real device.
- UI tests for the main flows.

## Review findings

### Likely bugs
1. **Speaking can interrupt the video being watched.** `Speaker.speak` sets the audio category to `.playback` with no options. During a screen share, `PipController` sets `.mixWithOthers`, so a speaker tap can drop it and pause the source app's audio. Use `.mixWithOthers` or `.duckOthers`. Needs a real-device test to confirm.
2. **A killed broadcast extension leaves the session stuck.** "Live" is only the existence of `broadcast.active`. If iOS kills the extension (tight memory limit), the file stays and `BroadcastAudioReceiver` never calls `onEnded`. A timestamp the extension refreshes, treated as stale after a few seconds, would fix it.
3. **The stats chart can count deleted words.** Deleting a `SavedWord` leaves its `ReviewLog` rows, and `weeklyProgress` counts "learned" from all logs. The learned line can sit above the saved line.
4. **Dangling references.** Two error strings point to `SETUP.md`, which does not exist (`ScreenShareViewModel.swift:125`, `ScreenShareView.swift:192`). `docs/INFO_PLIST_KEYS.md` says to add keys that are already in the build settings.
5. **The API key is not trimmed.** A pasted key with trailing whitespace fails with a confusing Gemini error. The Keychain is also rewritten on every keystroke.
6. **Edge case in `SessionReviewSaver`.** It inserts from a snapshot of unsaved words. If one was saved in the meantime, `@Attribute(.unique)` upserts and resets its level and schedule.

### Release concerns
- `UIScreen.main` is used in `PipSubtitleView.pipSize` and `PipFrameRenderer.scale`. It is deprecated, evaluated once, and wrong on iPad or after rotation. The app targets iPad too.
- The privacy manifest declares no collected data, but words go to Gemini and speech can go to Apple's servers. Check the App Privacy answers and the privacy policy against that.
- `sample.mp3` (about 250 KB) ships in release builds although it is only used in DEBUG.
- The deployment target is iOS 18.5. Check whether anything needs more than 18.0.
- CC-CEDICT is CC BY-SA. The app credits it, but the share-alike terms for the dictionary data should be read before a commercial release.
- Level 3 needs a Gemini key, which reviewers and most users will not have. Planned item 4 fixes this.

### Smaller issues
- `SpeechTranscriber` is `@unchecked Sendable`, but `running`, `continuous`, `failureStreak` and the callbacks are read from three queues without the lock.
- `ClozeCache` lives in UserDefaults, grows without limit, never prunes deleted words, and keeps sentences the builder later rejects.
- The default model `gemini-3.6-flash` is valid. Google's model list also shows newer 3.7 and 3.8 Flash versions. Move the name into one constant that is easy to update.
- `hasSeenOnboarding` defaults to `true` in `SettingsView` and `false` in `ContentView`. Harmless but inconsistent.
- Raw audio chunks can stay in the App Group folder after a session if the app does not drain them, until the next reset.

### Tests
- 68 unit tests cover mastery, SM-2, stats, search, segmentation and the session tracker.
- No tests for `QuizSessionBuilder`, `QuizViewModel`, `ClozeQuestionBuilder`, `DistractorPicker`, `QuizGrader` or `SessionSummaryBuilder`.
- The UI tests are still the Xcode template.

### What is solid
- Small, single-purpose files with clear names.
- Speech recognition restarts after its time limit, and a failure streak stops it cleanly.
- The Keychain migration is in place and the mock feed is gated to DEBUG builds.
- 56 accessibility labels and hints across the views.

## Suggested order
1. Fix findings 1, 2, 4 and 5. Each is a small change.
2. Planned item 4 (cloze without Gemini), since it removes the key dependency for reviewers.
3. Planned items 1 and 2 (reminders, export).
4. Add tests for the quiz builders and view model before changing them.
