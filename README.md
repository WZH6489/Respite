# 🌿 Respite

**Goal:** Help people reclaim their time from compulsive scrolling with an app that doesn't just lock apps, but helps you pause, reset, and return with intention.

**Method:** Combine Apple's Screen Time APIs with short, low-friction interventions (intent check-ins, breathing, quick puzzles) that create a boundary at the moment of impulse, then reinforce better habits with focus sessions, reflections, and behavior insights.

**Deliverables:** A native iOS app built entirely in Swift with smart app/category/site blocking, an intervention system, Pomodoro-style focus sessions with Live Activities, a behavior insights dashboard, and daily reflections, all wrapped in a calm Liquid Glass interface.

Developed by **Team 7** at **StormForge 2026** (SFU Surge) from January to April 2026: a team of four, selected from a competitive pool of SFU student applicants, working under the guidance of industry mentors to design and complete the project within four months.

> App Store release was pending approval at the time of the StormForge showcase.

---

# 🎯 Overview

In a hyper-connected world, finding focus and staying organized is harder than ever. We're constantly juggling daily tasks, managing screen time, and bouncing between a cluttered mess of different apps just to keep up. The result is fragmented attention, lost focus, and the constant stress of digital overload.

We realized we were scrolling far more than we intended, even when we wanted to focus, study, or rest. So we built Respite: instead of endless scrolling, it creates a quick boundary and redirects you into short interventions that make it easier to regain control.

Respite is a calming, easy-to-use iOS app that helps you manage your digital habits. You can block noisy apps, redirect your attention, track your screen time, and find your focus, all from your device. It's designed for anyone who wants to reclaim their time.

---

# 🔄 How It Works

1. **Set your boundaries.** Choose which apps, categories, and sites to block, and configure focus sessions.
2. **Intercept the impulse.** When you open a blocked app, Respite asks you to pause and check in: why are you opening this, and what will you do after?
3. **Recover and continue intentionally.** Complete a short intervention (breathing exercise, math challenge, tile puzzle, intent check) to unlock controlled access.
4. **Build momentum.** Daily reflections, streaks, and weekly insights show your progress and reinforce the habit.

---

# ✨ Core Features

| Feature | Description |
|---|---|
| **Smart Scroll Blocking** | App, category, and site blocking with an **Intent Gate** (check-in before opening) and a **Daily Limit** (pause plus extra time) |
| **Intervention System** | Fast recovery activities that unlock controlled access and build healthier habits |
| **Focus Sessions + Fullscreen Focus Mode** | Pomodoro-style timer with presets (25/5, 50/10, 90/15) and custom plans, persistent runtime, and synced Live Activity support |
| **Behavior Insights Dashboard** | Real-time metrics including time saved, momentum streak, recovery score, focus quality, achievements, and weekly insights |
| **Reflections + Progress Archive** | Daily reflection prompts, saved history with edit and delete, and weekly reflection intelligence to track behavior patterns |
| **Apple Integration** | Screen Time, HealthKit, WeatherKit, Live Activities, and Shortcuts support through App Intents |

---

# 🎨 Design

Respite's UI is intentionally designed to de-escalate compulsive scrolling: a calm visual language, clear hierarchy, and low-friction interactions that help users pause, reset, and make deliberate choices.

**Design principles**

- **Simplicity:** low-friction flows, consistent card patterns, and clear primary actions so users can complete tasks in 1-2 taps.
- **Balance:** calm visuals combined with structured behavior controls, so the app feels supportive while still enforcing limits.
- **Focus:** high-priority information is surfaced first, secondary details are progressively disclosed, and interruption screens are optimized for fast, intentional decisions.

**Design system**

- Liquid Glass UI
- Time-aware background that shifts with time and weather context
- Relaxed, custom color language chosen specifically to be calming
- Consistent UI across the app
- Emphasis-driven layout that reduces clutter

---

# 🧰 Technologies

- Swift
- SwiftUI
- Xcode
- Liquid Glass
- Screen Time (Family Controls, Device Activity)
- HealthKit
- WeatherKit
- Live Activities and WidgetKit
- App Intents / Shortcuts

---

# 🏗️ Repository Structure

```
Respite/
├── Respite 3.0/                               # Main app target (views, logic, assets)
├── Respite 3.0.xcodeproj/                     # Xcode project
├── StudyLiveWidget/                           # Widget and Live Activity extension
├── DeviceActivityReportExtension-Info.plist   # Device Activity report extension config
├── Respite copy.xcodeproj/                    # Earlier project workspace (kept for history)
└── LICENSE
```

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
6. When prompted, grant Screen Time access so blocking and insights can work.

> **Note:** Apple gates Family Controls behind an entitlement. You may need to request it from Apple before the app works on your own account.

---

# 🔭 Future Work

- Gamified interventions and streaks
- Physical intervention methods
- Support for macOS and iPadOS

---

# 👥 Team and Acknowledgements

Special thanks to our team mentor, **Mahim Chaudhary**, for his mentorship throughout the project.

Built by a team of four as part of **StormForge 2026** (SFU Surge).

**Team:** William Huang, Justin Tan, Philip Jeon, Vincent Zhao

---

# 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
