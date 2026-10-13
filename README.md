# Drum Trigger (JUCE 8 / C++17, VST3 + AU + Standalone)

Audio in → transient detection → built-in multi-sample player **and** MIDI out (and/or a hosted VST3/AU instrument).

> **Status:** source only. I wrote this without a JUCE toolchain available, so it has not been compiled or run.
> Expect a few small compile fixes on first build, and expect to tune the detector on real drum tracks.

## Build

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
```
CMake fetches JUCE 8.0.4 automatically. Plugins are copied to your system plugin folders after the build.
Requirements: CMake 3.22+, a C++17 compiler (Xcode / MSVC 2022 / GCC 11+).

## Windows 11 (x64)

Two ways to get a `.vst3` and a standalone `.exe`:

1. **Build locally.** Install Visual Studio 2022 (workload "Desktop development with C++"), CMake and Git, then run `.\build_windows.ps1` in PowerShell. Output is a `Drum Trigger.vst3` folder and `Drum Trigger.exe`.
2. **Build in the cloud, no tools needed.** Push this folder to a GitHub repo. The workflow in `.github/workflows/build-windows.yml` builds on a Windows runner; download `DrumTrigger-Windows-x64` from the run's Artifacts.

Install: copy `Drum Trigger.vst3` to `C:\Program Files\Common Files\VST3`, then rescan plugins in your DAW. The runtime is linked statically, so no Visual C++ redistributable is needed. Hosting works with VST3 instruments (AU does not exist on Windows). The plugin is unsigned, so SmartScreen may warn on the standalone `.exe`; sign it for distribution.

## Feature map

| Requested feature | Where / how it works |
|---|---|
| Intelligent transient / algorithmic detection | `TransientDetector` (TriggerEngine.h). Three modes: **Threshold**, **Adaptive** (fast envelope vs slow envelope ratio), **Onset** (energy rise in dB over 2 ms). A 2.5 ms look-ahead window measures the true peak before firing, and a decaying dynamic threshold + retrigger hold-off prevents double triggers on ringing. |
| Leakage / bleed suppression | **Bleed Reject**: the detection signal must exceed the sidechain reference (e.g. a neighbouring mic) by N dB. Also the dynamic threshold and hold-off above. |
| Frequency filtering & sidechaining | Detection-only HPF/LPF (does not colour your audio). **Source** switch: detect from Main or Sidechain input. The other input becomes the bleed reference. |
| Visual waveform analysis | `ScopeView`: ~5 s scrolling waveform, trigger markers (height = velocity), threshold lines. Drag in the scope to set the threshold. |
| Multi-sample velocity distribution | 8 layers. Drop/load samples into a layer; velocity 1–127 is split evenly across non-empty layers. Ranges are shown in the loaded-samples list. Velocity is mapped from measured peak dB between Threshold and Vel Ceil with a Vel Curve. |
| Round-robin | Several samples in the same layer rotate: Cycle / Random / No Repeat. |
| Humanize | Velocity (%), timing (ms), pitch (cents). Applied to the **samples only**; MIDI output stays exact. |
| Trigger shift / time offset | Offset −2.5…+50 ms. The plugin reports 5 ms latency so the dry audio is delay-compensated and samples/MIDI land on the original onset. |
| Phase inversion & alignment | Separate polarity invert for samples and dry. The processor cross-correlates dry vs sample start (±1 ms) and shows polarity/lag; **Auto-Align** applies the suggestion. |
| Dynamic envelope shaping | Attack, Decay (5000 = off), Vel→Decay (harder hits ring longer/shorter), Vel Sens (velocity → level). |
| Integrated browser & "AI" search | Scan a folder; each file is analysed in the background (decay, spectral centroid) and auto-classified (Kick/Snare/Tom/HiHat/Cymbal). Search by name **and** content: "punchy snare", "dark kick", "long cymbal". This is local heuristic analysis, not a neural network. Thresholds in `SampleLibrary::classify` are worth tuning to your libraries. |
| Instrument hosting | **Load Instrument…** loads any VST3/AU instrument inside the plugin, feeds it the generated MIDI, mixes its output (Instrument level). State is saved with your project. |
| Accurate MIDI generation | Note-on at the latency-compensated onset with measured velocity, sample-accurate placement, fixed note/length params. **Record MIDI → Export .mid** writes a file at the host tempo with timestamps on the *original* audio timeline (so it lines up with the uncompensated track). |

## Known limitations / next steps

- Hit analysis for velocity uses the filtered detection signal; a raw-peak option would be easy to add.
- Velocity zones split evenly; manual zone boundaries and layer crossfades are not implemented.
- Hosted instrument latency is not reported to the host; hosted-plugin state/bus layouts are minimal (stereo out expected).
- Alignment analysis uses channel 0 of the sample and assumes similar sample rates.
- Always test with the dry level at 0 dB and samples muted to check the detector first.
