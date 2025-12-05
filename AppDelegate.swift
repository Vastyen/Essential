import AppKit
import ApplicationServices
import CoreGraphics
import ServiceManagement
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?
    private var hotkeyManager: HotkeyManager?
    private let clipboardStore = ClipboardStore()
    private var onboardingWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Sincronizar UserDefaults para asegurar que se lea el estado más reciente
        UserDefaults.standard.synchronize()
        
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        let bundleId = Bundle.main.bundleIdentifier ?? "open.Essential"
        print("🔍 Onboarding check:")
        print("   Bundle ID: \(bundleId)")
        print("   Has completed onboarding: \(hasCompletedOnboarding)")
        
        // Verificar también en el dominio persistente
        if let persistentDomain = UserDefaults.standard.persistentDomain(forName: bundleId) {
            print("   Persistent domain keys: \(persistentDomain.keys)")
        }
        
        if hasCompletedOnboarding {
            startApp()
        } else {
            showOnboarding()
        }
    }
    
    private func showOnboarding() {
        NSApp.setActivationPolicy(.regular)
        
        let onboardingView = OnboardingView { [weak self] in
            self?.onboardingWindow?.close()
            self?.onboardingWindow = nil
            self?.startApp()
        }
        
        let hostingController = NSHostingController(rootView: onboardingView)
        
        onboardingWindow = NSWindow(contentViewController: hostingController)
        onboardingWindow?.title = "Essential"
        onboardingWindow?.styleMask = [.titled, .closable]
        onboardingWindow?.isReleasedWhenClosed = false
        onboardingWindow?.delegate = self
        
        if let screen = NSScreen.main {
            let size = NSSize(width: 600, height: 900)
            let visibleFrame = screen.visibleFrame
            let x = visibleFrame.origin.x + (visibleFrame.width - size.width) / 2
            let y = visibleFrame.origin.y + (visibleFrame.height - size.height) / 2
            onboardingWindow?.setFrame(NSRect(x: x, y: y, width: size.width, height: size.height), display: true)
        }
        
        onboardingWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func startApp() {
        NSApp.setActivationPolicy(.accessory)
        
        // Habilitar launch at login siempre
        enableLaunchAtLogin()
        
        // Solo verificar permisos, no pedirlos si ya se completó el onboarding
        // Los permisos ya se pidieron durante el onboarding
        let hasPermission = CGPreflightScreenCaptureAccess()
        if hasPermission {
            print("✅ Screen Recording permission already granted")
        } else {
            print("⚠️ Screen Recording permission not granted (user can enable in Settings)")
        }
        
        checkAccessibilityPermissions()

        statusBarController = StatusBarController(clipboardStore: clipboardStore)

        hotkeyManager = HotkeyManager(
            onScreenshotSelection: { [weak self] in
                self?.captureScreenSelection()
            },
            onScreenshotFullScreen: { [weak self] in
                self?.captureFullScreen()
            },
            onToggleClipboard: { [weak statusBarController] in
                statusBarController?.togglePopover()
            }
        )
    }
    
    private func enableLaunchAtLogin() {
        if #available(macOS 13.0, *) {
            do {
                let service = SMAppService.mainApp
                let status = service.status
                
                print("📋 Launch at Login status: \(status)")
                
                switch status {
                case .notRegistered:
                    try service.register()
                    print("✅ Launch at Login enabled (SMAppService)")
                case .enabled:
                    print("✅ Launch at Login already enabled")
                case .requiresApproval:
                    // En macOS 13+, el usuario puede necesitar aprobar manualmente
                    print("⚠️ Launch at Login requires user approval")
                    print("   Go to: System Settings → General → Login Items")
                    // Intentar registrar de todos modos
                    do {
                        try service.register()
                        print("✅ Launch at Login registration attempted")
                    } catch {
                        print("⚠️ Failed to register: \(error)")
                    }
                case .notFound:
                    print("⚠️ Launch at Login service not found")
                    // Intentar registrar de todos modos
                    do {
                        try service.register()
                        print("✅ Launch at Login registration attempted")
                    } catch {
                        print("⚠️ Failed to register: \(error)")
                    }
                @unknown default:
                    print("⚠️ Unknown Launch at Login status: \(status.rawValue)")
                    // Intentar registrar de todos modos
                    do {
                        try service.register()
                        print("✅ Launch at Login registration attempted")
                    } catch {
                        print("⚠️ Failed to register: \(error)")
                    }
                }
            } catch {
                print("⚠️ Failed to enable Launch at Login: \(error)")
                if let bundleIdentifier = Bundle.main.bundleIdentifier {
                    print("   Bundle ID: \(bundleIdentifier)")
                }
            }
        } else {
            // Para macOS 12 y anteriores
            guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
                print("⚠️ Failed to get bundle identifier")
                return
            }
            
            let success = SMLoginItemSetEnabled(bundleIdentifier as CFString, true)
            if success {
                print("✅ Launch at Login enabled (SMLoginItemSetEnabled)")
            } else {
                print("⚠️ Failed to enable Launch at Login")
                print("   Bundle ID: \(bundleIdentifier)")
                print("   Note: App may need to be in /Applications folder")
            }
        }
    }
    
    private func requestScreenRecordingPermissions() {
        let hasPermission = CGPreflightScreenCaptureAccess()
        
        if !hasPermission {
            print("📹 Requesting Screen Recording permissions...")
            
            NSApp.activate(ignoringOtherApps: true)
            
            let granted = CGRequestScreenCaptureAccess()
            
            if granted {
                print("✅ Screen Recording permission granted")
            } else {
                print("⚠️ Screen Recording permission denied or dialog didn't appear")
                print("   Opening System Settings...")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if CGPreflightScreenCaptureAccess() {
                        print("✅ Screen Recording permission granted (after delay)")
                        return
                    }
                    
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
                        NSWorkspace.shared.open(url)
                        NSApp.activate(ignoringOtherApps: true)
                    }
                }
            }
        } else {
            print("✅ Screen Recording permission already granted")
        }
    }
    
    private func checkAccessibilityPermissions() {
        let trusted = AXIsProcessTrusted()
        if !trusted {
            print("⚠️ Accessibility permissions required for ⌘⇧3 and ⌘⇧4")
            print("   Go to: System Settings → Privacy & Security → Accessibility")
            print("   Enable Essential")
            
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
            AXIsProcessTrustedWithOptions(options as CFDictionary)
        } else {
            print("✅ Accessibility permissions granted")
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager = nil
    }

    private func captureScreenSelection() {
        DispatchQueue.global(qos: .userInitiated).async {
            // Verificar y solicitar permisos si es necesario
            self.ensureScreenCapturePermission { [weak self] hasPermission in
                guard let self = self else { return }
                
                if !hasPermission {
                    print("⚠️ Screen Recording permission required to take screenshots")
                    return
                }
                
                let screenshotPath = self.getScreenshotPath()
                
                // Guardar la captura en el archivo
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
                process.arguments = ["-s", screenshotPath]
                
                do {
                    try process.run()
                    process.waitUntilExit()
                    
                    // Verificar que el archivo se creó y copiarlo al portapapeles
                    if FileManager.default.fileExists(atPath: screenshotPath),
                       let image = NSImage(contentsOfFile: screenshotPath) {
                        // Copiar al portapapeles
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.writeObjects([image])
                        
                        print("✅ Screenshot guardada en: \(screenshotPath)")
                    } else {
                        print("⚠️ Screenshot file not created - permission may be required")
                    }
                } catch {
                    print("Error running screencapture: \(error)")
                }
            }
        }
    }

    private func captureFullScreen() {
        DispatchQueue.global(qos: .userInitiated).async {
            // Verificar y solicitar permisos si es necesario
            self.ensureScreenCapturePermission { [weak self] hasPermission in
                guard let self = self else { return }
                
                if !hasPermission {
                    print("⚠️ Screen Recording permission required to take screenshots")
                    return
                }
                
                let screenshotPath = self.getScreenshotPath()
                
                // Guardar la captura en el archivo
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
                process.arguments = [screenshotPath]
                
                do {
                    try process.run()
                    process.waitUntilExit()
                    
                    // Verificar que el archivo se creó y copiarlo al portapapeles
                    if FileManager.default.fileExists(atPath: screenshotPath),
                       let image = NSImage(contentsOfFile: screenshotPath) {
                        // Copiar al portapapeles
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.writeObjects([image])
                        
                        print("✅ Screenshot guardada en: \(screenshotPath)")
                    } else {
                        print("⚠️ Screenshot file not created - permission may be required")
                    }
                } catch {
                    print("Error running screencapture: \(error)")
                }
            }
        }
    }
    
    private func ensureScreenCapturePermission(completion: @escaping (Bool) -> Void) {
        // Verificar permisos primero
        var hasPermission = CGPreflightScreenCaptureAccess()
        
        if hasPermission {
            completion(true)
            return
        }
        
        // Si no hay permisos, intentar solicitarlos
        print("📹 Screen Recording permission not granted, requesting...")
        
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            
            // Solicitar permisos
            let granted = CGRequestScreenCaptureAccess()
            
            if granted {
                print("✅ Screen Recording permission granted")
                completion(true)
                return
            }
            
            // Esperar un momento y verificar de nuevo (a veces hay delay en la actualización)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                hasPermission = CGPreflightScreenCaptureAccess()
                
                if hasPermission {
                    print("✅ Screen Recording permission granted (after delay)")
                    completion(true)
                } else {
                    print("⚠️ Screen Recording permission still not granted")
                    // Abrir System Settings para que el usuario pueda otorgar permisos
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
                        NSWorkspace.shared.open(url)
                        NSApp.activate(ignoringOtherApps: true)
                    }
                    completion(false)
                }
            }
        }
    }
    
    private func getScreenshotPath() -> String {
        // Obtener la ruta guardada en UserDefaults, o usar la ruta por defecto
        UserDefaults.standard.synchronize()
        let savedPath = UserDefaults.standard.string(forKey: "screenshotPath")
        
        let screenshotsURL: URL
        if let savedPath = savedPath, !savedPath.isEmpty {
            screenshotsURL = URL(fileURLWithPath: savedPath)
        } else {
            // Ruta por defecto: ~/Documents/Screenshots
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            screenshotsURL = documentsURL.appendingPathComponent("Screenshots")
        }
        
        // Crear el directorio si no existe
        try? FileManager.default.createDirectory(at: screenshotsURL, withIntermediateDirectories: true, attributes: nil)
        
        // Generar nombre de archivo con timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH.mm.ss"
        let fileName = "Screenshot \(formatter.string(from: Date())).png"
        
        return screenshotsURL.appendingPathComponent(fileName).path
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow,
              window === onboardingWindow else { return }
        
        UserDefaults.standard.synchronize()
        let hasCompleted = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if !hasCompleted {
            NSApp.terminate(nil)
        }
    }
}
