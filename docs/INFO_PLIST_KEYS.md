# Required before running Stage 3

Xcode > project > SubtitleLearn target > Info tab > Custom iOS Target Properties, add:

| Key | Example value |
| --- | --- |
| Privacy - Microphone Usage Description (`NSMicrophoneUsageDescription`) | SubtitleLearn listens to Chinese speech so it can show the words, pinyin and meanings. |
| Privacy - Speech Recognition Usage Description (`NSSpeechRecognitionUsageDescription`) | SubtitleLearn converts your speech to text to translate it. |

Without both keys the app crashes the first time you tap the mic.
