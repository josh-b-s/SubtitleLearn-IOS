# Picture in Picture setup

1. Xcode > File > Add Package Dependencies...
   URL: https://github.com/getsidetrack/swiftui-pipify.git
   Add the "Pipify" library to the SubtitleLearn target.
2. Target > Signing & Capabilities > + Capability > Background Modes,
   tick "Audio, AirPlay, and Picture in Picture". PiP will not start without it.
3. Run, open the Screen Share tab, tap "Start Picture in Picture demo".
   Press Home to check the window stays over other apps.
