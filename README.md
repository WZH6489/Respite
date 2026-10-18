# 🌿 Respite 3.0

**Goal:** Help people build healthier relationships with their phones by making screen time visible and interrupting mindless usage at the right moment.

**Method:** Use Apple's Screen Time APIs (Family Controls, Device Activity) to track app usage, surface it in a clear dashboard, and trigger gentle interventions when usage patterns drift.

**Deliverables:** A native iOS app written in Swift with a usage dashboard, configurable interventions, a Family Controls view with weekly usage statistics, a live study widget, and Shortcuts integration.

An iOS digital wellness app built in **Swift**, originally developed as part of **StormForge 2026** (SFU Surge) from January to April 2026 by a team of four with industry mentors. This repository is the 3.0 iteration of the app.

---

# 🎯 Overview

Most phone-time tools only report numbers after the fact. Respite aims to be more active: it shows how time is actually spent, then steps in with interventions that help the user pause, reflect, or switch to something more intentional.

Respite 3.0 focuses on:

- **Awareness**: a dashboard that summarizes daily and weekly device usage.
- **Intervention**: configurable nudges that interrupt unwanted usage patterns.
- **Support**: a Family Controls view with weekly usage statistics for parents or guardians.
- **Focus**: a live widget for study sessions.
- **Automation**: Shortcuts support through an App Intent, so Respite can fit into existing routines.

---

# ✨ Features

| Feature | Description |
|---|---|
| Usage dashboard | Daily and weekly screen-time summaries with formatted, readable stats |
| Interventions | Configurable prompts that interrupt usage before it turns into a habit loop |
| Settings | User-controlled intervention behavior and app preferences |
| Family Controls | Weekly usage statistics display for supervised accounts |
| Study Live Widget | Live widget that tracks study sessions from the home or lock screen |
| Shortcuts integration | `ForegroundContinuableIntent` support so Shortcuts automations can open and continue inside the app |

---

# 🏗️ Repository Structure

```
Respite-3.0/
├── Respite 3.0/                          # Main app target (SwiftUI views, logic, assets)
├── Respite 3.0.xcodeproj/                # Xcode project
├── StudyLiveWidget/                      # Widget extension for live study sessions
├── DeviceActivityReportExtension-Info.plist   # Device Activity report extension config
├── Respite copy.xcodeproj/               # Legacy project workspace (kept for history)
└── .gitignore
```

---

# 🧰 Technologies

- Swift
- SwiftUI
- Xcode
- Family Controls
- Device Activity (Screen Time API)
- WidgetKit
- App Intents / Shortcuts

---

# 🚀 Getting Started

### Requirements

- A Mac with a recent version of **Xcode**
- An **iOS device** (Screen Time APIs such as Family Controls generally need a real device rather than the simulator)
- An Apple Developer account, since Family Controls requires a signing capability

### Run the app

1. Clone the repository:
   ```bash
   git clone https://github.com/WZH6489/Respite-3.0.git
   cd Respite-3.0
   ```
2. Open `Respite 3.0.xcodeproj` in Xcode.
3. Select the **Respite 3.0** scheme and set your own **Team** under *Signing & Capabilities* for the app and each extension target.
4. Make sure the **Family Controls** capability is enabled for the app and extensions.
5. Build and run on a connected iPhone.
6. When prompted, grant Screen Time access so the dashboard and interventions can work.

> **Note:** Apple gates Family Controls behind an entitlement. You may need to request it from Apple before the app works on your own account.

---

# 🔭 Future Work

- Smarter, context-aware interventions
- Longer-term trends and goal setting
- Expanded widgets and lock screen support
- More Shortcuts actions
- Accessibility and localization

---

# 👥 Team and Acknowledgements

Special thanks to our team mentor, **Mahim Chaudhary**, for his mentorship throughout the project.

Built by a team of four as part of **StormForge 2026** (SFU Surge).

**Team:** William Huang, Justin Tan, Philip Jeon, Vincent Zhao

---

# 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
