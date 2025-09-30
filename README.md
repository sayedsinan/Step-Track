

# Step Track - Health Connect Dashboard

A Flutter application that displays **real-time health data** from Health Connect with smooth, interactive charts and performance monitoring. The app also provides a simulation mode for testing without a device sensor or Health Connect dependency.

---

## Features

* Real-time **step count** and **heart rate** monitoring
* Interactive charts (pan, zoom, tooltip) implemented via **CustomPainter**
* Performance monitoring HUD (FPS, build time, paint time)
* **Simulation mode** for deterministic testing without Health Connect
* Zero network dependency, fully offline capable
* Permissions management with graceful denial handling

---

## Setup

### Prerequisites

* **Flutter SDK** (stable channel)
* Android device/emulator with **API 28+ (Android 9+)**
* Health Connect app installed and enabled on the device

### Installation

1. Clone the repository:

```bash
git clone https://github.com/sayedsinan/Step-Track
cd step_track
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

---

## Architecture

### State Management

* **Riverpod** is used for reactive state management.
* **HealthProvider**: Manages Health Connect integration, permissions, and data polling.
* **SimProvider**: Provides synthetic step/HR data for testing without real sensors.

### Data Flow

* Health Connect events are **polled every 5 seconds** (or via Passive Listener if available).
* Records are **deduplicated** using record IDs/timestamps.
* Data is aggregated and displayed in real-time in the dashboard cards and charts.
* Charts use **CustomPainter**, with **point decimation and resampling** for smooth rendering.

---

## Permissions & Health Connect

* Requests read permissions for:

  * StepsRecord
  * HeartRateRecord
* **Permissions screen** shows the grant state and allows re-request.
* Denials are handled gracefully with banners and retry buttons.

---

## Dashboard UI

* **Top cards**: show today's step count and last HR value
* **Charts**:

  * Steps vs time (last 60 minutes)
  * HR vs time (rolling window, optional smoothing)
* **Interactions**: pan, pinch-zoom, tooltip shows nearest value
* Maintains **60 FPS** with up to 5–10k points

---

## Performance

* Average **build time ≤ 8 ms**
* No jank frames during 90-second session
* Performance HUD displays:

  * Average build time
  * Last paint time
  * Estimated FPS

---

## Debug & Simulation

* Debug screen enables **SimSource**: emits synthetic step/HR updates for testing
* Deterministic testing without writing to Health Connect
* Simulation mode is disabled in release builds
* Useful for golden and integration tests

---

## Testing & CI

* **Unit tests**: event → view-model state mapping, de-duplication
* **Golden tests**: chart rendering with fixed synthetic data
* **Integration tests**: scripted interactions using SimSource
* Minimal CI workflow: format, analyze, unit, golden, integration (headless)

---

## Submission Deliverables

* Git repo with 8–12 logical commits
* README (≤1.5 pages)
* Screen recording showing:

  * Permissions granted
  * Live updates
  * Chart interactions
* DevTools frame chart screenshot during live session

---

## Anti-Plagiarism & Authenticity

* **SALT** = `SHA256("${packageName}:${firstGitCommitHash}")`
* Commit history must show iterative progress
* Live follow-up may require minor feature tweaks (smoothing toggle, sampling window change)

---


## Notes

* Charts **must be implemented without external charting libraries**
* App works **completely offline**
* Synthetic data is only for **debug/testing purposes**, not in production
* Ensure **smooth UI updates**, **no per-frame allocations**, and **deterministic behavior** for tests

---

This README covers **setup,, permissions, dashboard UI, simulation, performance, testing, and submission requirements** in a concise, structured way suitable for your Flutter hiring task.

