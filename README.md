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

# 🧠 Origins and Research

**Premise:** Most existing apps tackle only one piece of the problem, either blocking apps or offering relaxation tools like meditation and puzzle games. We wanted to cover every facet of detoxing and adapt to each user's needs, so the proposal split the approach into three methods.

| Method | Idea in the proposal | Where it lives in Respite |
|---|---|---|
| **Reactive** (block content and apps) | Interrupt mindless scrolling as it happens | Smart Scroll Blocking with Intent Gate and Daily Limit |
| **Proactive** (track time and reflect) | Make users state their intent and earn access before scrolling | Intent check-ins, behavior insights dashboard, daily reflections |
| **Restructure** (redirect to better activities) | Swap scrolling for calming or productive alternatives | Intervention System with breathing, math, and puzzle activities, plus the Wellness tab |

**Bespoke ideas that shaped the design**

- **Digital sunrise and sunset:** tie the experience to the user's local time so a session ends with a sense of closure. This became the time-aware background and the sunrise/sunset card on the home screen.
- **Time-to-life converter:** turn abstract minutes into something meaningful. This became the "time saved" and "this pace, 1 year" cards.
- **Silent achievements:** favor subtle, calm UI shifts over dopamine-spike badges and fireworks, which carried into Respite's calm design language.

**Background**

- "Brainrot" is shorthand for the mental dulling that can follow spending too much time on low-quality, unchallenging online content. Reported effects include feeling overwhelmed, emotional numbness, memory and decision-making trouble, and social withdrawal.
- Phone distraction is a growing concern in education too: school districts across British Columbia have adopted codes of conduct limiting student phone use in classrooms.

**Inspiration**

- The **MINDSPACE** behavior-change framework (Messenger, Incentives, Norms, Defaults, Salience, Priming, Affect, Commitments, Ego), which guided how we nudge users toward better choices
- **Art of Fauna**, a calm puzzle game that shaped the idea of a relaxing replacement for scrolling
- **Rize**, a time-tracking app that inspired the insights dashboard

**References**

- [What Is Brainrot? (Healthline)](https://www.healthline.com/health/what-is-brainrot)
- [Cellphones in Schools (Government of British Columbia)](https://www2.gov.bc.ca/gov/content/education-training/k-12/cellphones-in-schools)
- [Tools of the Trade (The Decision Lab)](https://thedecisionlab.com/guide/tools-of-the-trade)
- [Anti-Brainrot Apps (Digital Minimalist)](https://www.digitalminimalist.com/blog/anti-brainrot-apps)

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
├── RespiteFocusKit/                           # Shared focus session logic
├── RespiteFocusLiveActivity/                  # Live Activity extension for focus sessions
├── DeviceActivityReportExtension/             # Screen Time (Device Activity) report extension
├── DeviceActivityReportExtension-Info.plist   # Device Activity report extension config
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
- Browser extension to block short-form video such as YouTube Shorts (from the original proposal)

---

# 👥 Team and Acknowledgements

Special thanks to our team mentor, **Mahim Chaudhary**, for his mentorship throughout the project.

Built by a team of four as part of **StormForge 2026** (SFU Surge).

**Team:** William Huang, Justin Tan, Philip Jeon, Vincent Zhao

---

# 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
