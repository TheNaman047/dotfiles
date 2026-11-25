// Drops scroll-wheel encoder bounce: a direction flip arriving < WINDOW ms after the last accepted tick.
import Cocoa
let window = Double(ProcessInfo.processInfo.environment["SD_WINDOW_MS"] ?? "60")! / 1000
let verbose = CommandLine.arguments.contains("-v")
var lastSign: Int64 = 0
var lastAccepted: TimeInterval = 0
var dropped = 0, passed = 0, clamped = 0
var lastDrop: TimeInterval = 0
var lastMag: Int64 = 1
var tapRef: CFMachPort?

let cb: CGEventTapCallBack = { _, type, ev, _ in
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let t = tapRef { CGEvent.tapEnable(tap: t, enable: true) }
        return Unmanaged.passUnretained(ev)
    }
    guard type == .scrollWheel,
          ev.getIntegerValueField(.scrollWheelEventIsContinuous) == 0,
          ev.getIntegerValueField(.eventSourceUnixProcessID) == 0 else { return Unmanaged.passUnretained(ev) }
    let d = ev.getIntegerValueField(.scrollWheelEventDeltaAxis1)
    if d == 0 { return Unmanaged.passUnretained(ev) }
    let s: Int64 = d > 0 ? 1 : -1
    let now = ProcessInfo.processInfo.systemUptime
    if lastSign != 0 && s != lastSign && now - lastAccepted < window {
        dropped += 1; lastDrop = now
        if verbose { print(String(format: "drop %3d  (%.0fms after last)", d, (now - lastAccepted) * 1000)) }
        return nil
    }
    var mag = abs(d)
    if now - lastAccepted > 0.3 { lastMag = 1 }
    // tick right after a bounce carries bogus acceleration (1ms interval): hold it to the previous size;
    // otherwise limit growth so lone spikes (1 -> 8) can't jump the page
    let cap = (s == lastSign && now - lastDrop < 0.03) ? lastMag : lastMag * 2 + 1
    if mag > cap {
        let r = Double(cap) / Double(mag)
        ev.setIntegerValueField(.scrollWheelEventDeltaAxis1, value: s * cap)
        ev.setDoubleValueField(.scrollWheelEventFixedPtDeltaAxis1, value: ev.getDoubleValueField(.scrollWheelEventFixedPtDeltaAxis1) * r)
        ev.setIntegerValueField(.scrollWheelEventPointDeltaAxis1, value: Int64((Double(ev.getIntegerValueField(.scrollWheelEventPointDeltaAxis1)) * r).rounded()))
        if verbose { print(String(format: "clamp %3d -> %3d", d, s * cap)) }
        mag = cap; clamped += 1
    } else if verbose { print(String(format: "pass %3d", d)) }
    lastSign = s; lastAccepted = now; lastMag = mag; passed += 1
    return Unmanaged.passUnretained(ev)
}

guard let tap = CGEvent.tapCreate(tap: .cghidEventTap, place: .headInsertEventTap, options: .defaultTap,
        eventsOfInterest: CGEventMask(1 << CGEventType.scrollWheel.rawValue), callback: cb, userInfo: nil) else {
    FileHandle.standardError.write("tapCreate failed: grant Accessibility to this binary/terminal (Privacy & Security > Accessibility)\n".data(using: .utf8)!)
    exit(1)
}
tapRef = tap
CFRunLoopAddSource(CFRunLoopGetCurrent(), CFMachPortCreateRunLoopSource(nil, tap, 0), .commonModes)
CGEvent.tapEnable(tap: tap, enable: true)
setbuf(stdout, nil)
print("scrolldebounce running, window \(Int(window * 1000))ms\(verbose ? " (verbose)" : ""). Ctrl-C to stop.")
signal(SIGINT) { _ in print("\npassed \(passed), dropped \(dropped), clamped \(clamped)"); exit(0) }
CFRunLoopRun()
