# Mock audio for testing speech recognition (no microphone needed)

On your Mac, in Terminal, from the folder you want the file in:

    say -v Tingting -o sample.aiff "我喜欢学习中文"

(If `Tingting` isn't installed: System Settings > Accessibility > Spoken Content > System Voice > Manage Voices,
download a Chinese (China) voice, then use `say -v '?' | grep zh_CN` to see its name.)

Then drag sample.aiff into the Xcode project (tick "Add to target"), run a DEBUG build,
and tap "Test speech with sample audio" under the Translate button.
Expected: the text box fills with 我喜欢学习中文 and the word cards appear.
