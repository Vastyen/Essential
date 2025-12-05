import AppKit
import CoreGraphics
import ApplicationServices
import SwiftUI

struct OnboardingView: View {
    @State private var screenCaptureGranted = false
    @State private var accessibilityGranted = false
    @State private var selectedIcon: String = "</>"
    @State private var permissionTimer: Timer?
    @State private var animateHeader = false
    @State private var currentStep: Int = 1
    @State private var screenshotPath: String = ""
    
    let onComplete: () -> Void
    
    private let iconOptions = ["</>", "⌘", "⌥"]
    private let totalSteps = 4
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            Divider()
                .opacity(0.3)
            
            // Progress indicator
            progressIndicator
            
            Divider()
                .opacity(0.3)
            
            // Step content
            stepContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
            
            Divider()
                .opacity(0.3)
            
            footerSection
        }
        .frame(width: 600, height: 900)
        .background(
            ZStack {
                Color(nsColor: .windowBackgroundColor)
                
                // Subtle gradient overlay
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.03),
                        Color.purple.opacity(0.02),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .onAppear {
            checkPermissions()
            loadSavedIcon()
            loadScreenshotPath()
            
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                animateHeader = true
            }
            
            permissionTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
                let screenGranted = CGPreflightScreenCaptureAccess()
                let accessibilityGranted = AXIsProcessTrusted()
                
                DispatchQueue.main.async {
                    if screenGranted != self.screenCaptureGranted {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            self.screenCaptureGranted = screenGranted
                        }
                    }
                    if accessibilityGranted != self.accessibilityGranted {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            self.accessibilityGranted = accessibilityGranted
                        }
                    }
                    // No invalidar el timer, seguir verificando hasta que ambos estén otorgados
                }
            }
            RunLoop.current.add(permissionTimer!, forMode: .common)
        }
        .onDisappear {
            permissionTimer?.invalidate()
            permissionTimer = nil
        }
    }
    
    private var progressIndicator: some View {
        HStack(spacing: 12) {
            ForEach(1...totalSteps, id: \.self) { step in
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(step <= currentStep ? 
                                  LinearGradient(
                                      colors: [.blue, .purple],
                                      startPoint: .topLeading,
                                      endPoint: .bottomTrailing
                                  ) :
                                  LinearGradient(
                                      colors: [Color.secondary.opacity(0.2), Color.secondary.opacity(0.2)],
                                      startPoint: .topLeading,
                                      endPoint: .bottomTrailing
                                  )
                            )
                            .frame(width: 28, height: 28)
                        
                        if step < currentStep {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Text("\(step)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(step == currentStep ? .white : .secondary)
                        }
                    }
                    
                    if step < totalSteps {
                        Rectangle()
                            .fill(step < currentStep ? 
                                  LinearGradient(
                                      colors: [.blue, .purple],
                                      startPoint: .leading,
                                      endPoint: .trailing
                                  ) :
                                  LinearGradient(
                                      colors: [Color.secondary.opacity(0.2), Color.secondary.opacity(0.2)],
                                      startPoint: .leading,
                                      endPoint: .trailing
                                  )
                            )
                            .frame(height: 3)
                            .cornerRadius(1.5)
                    }
                }
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 20)
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 1:
            step1Permissions
        case 2:
            step2ScreenshotPath
        case 3:
            step3Icons
        case 4:
            step4Shortcuts
        default:
            step1Permissions
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            ZStack {
                // Outer glow
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.4),
                                Color.purple.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)
                    .blur(radius: 12)
                    .opacity(animateHeader ? 1 : 0)
                
                // Mostrar el icono de la app con bordes redondeados
                if let appIcon = NSImage(named: "AppIcon") ?? NSImage(named: NSImage.applicationIconName) {
                    Image(nsImage: appIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .blue.opacity(0.4), radius: 16, y: 8)
                        .shadow(color: .purple.opacity(0.2), radius: 8, y: 4)
                } else {
                    // Fallback si no se encuentra el icono
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue,
                                    Color.purple
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: .blue.opacity(0.4), radius: 16, y: 8)
                        .shadow(color: .purple.opacity(0.2), radius: 8, y: 4)
                    
                    Text(selectedIcon)
                        .font(.system(
                            size: selectedIcon == "</>" ? 32 : 40,
                            weight: .bold,
                            design: .monospaced
                        ))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                }
            }
            .scaleEffect(animateHeader ? 1 : 0.8)
            .opacity(animateHeader ? 1 : 0)
            
            VStack(spacing: 8) {
                Text("Welcome to Essential")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Your powerful clipboard manager for macOS")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .opacity(animateHeader ? 1 : 0)
            .offset(y: animateHeader ? 0 : 10)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
    }
    
    // Step 1: Permissions
    private var step1Permissions: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 12, y: 4)
                
                Text("Step 1: Permissions")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                
                Text("Essential needs permissions to function properly")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                // Screen Recording Permission
                permissionRow(
                    icon: "camera.viewfinder",
                    title: "Screen Recording",
                    description: "Required for screenshot capture functionality",
                    granted: screenCaptureGranted,
                    onRequest: requestScreenCapture
                )
                
                // Accessibility Permission
                permissionRow(
                    icon: "hand.raised.fill",
                    title: "Accessibility",
                    description: "Required for keyboard shortcuts to work",
                    granted: accessibilityGranted,
                    onRequest: requestAccessibility
                )
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 20)
    }
    
    private func permissionRow(
        icon: String,
        title: String,
        description: String,
        granted: Bool,
        onRequest: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        granted ?
                        LinearGradient(
                            colors: [Color.green.opacity(0.2), Color.green.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.orange.opacity(0.2), Color.orange.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            colors: granted ? [.green, .green.opacity(0.8)] : [.orange, .orange.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .shadow(color: (granted ? Color.green : Color.orange).opacity(0.3), radius: 12, y: 4)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            if granted {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Granted")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.green)
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                Button {
                    onRequest()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "gear")
                            .font(.system(size: 12))
                        Text("Open Settings")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        )
    }
    
    // Step 2: Screenshot Path
    private var step2ScreenshotPath: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "folder.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.3), radius: 12, y: 4)
                
                Text("Step 2: Screenshot Location")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                
                Text("Choose where to save your screenshots")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                // Mostrar la ruta actual
                HStack {
                    Image(systemName: "folder")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                    
                    Text(screenshotPath.isEmpty ? getDefaultScreenshotPath() : screenshotPath)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
                )
                
                // Botón para seleccionar carpeta
                Button {
                    selectScreenshotFolder()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 14))
                        Text("Choose Folder")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                // Botón para usar la ruta por defecto
                Button {
                    screenshotPath = ""
                    saveScreenshotPath("")
                } label: {
                    Text("Use Default (Documents/Screenshots)")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 20)
    }
    
    // Step 3: Icon Selection
    private var step3Icons: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "menubar.rectangle")
                    .font(.system(size: 56))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .purple.opacity(0.3), radius: 12, y: 4)
                
                Text("Step 3: Menu Bar Icon")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                
                Text("Choose your preferred icon style for the menu bar")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            HStack(spacing: 20) {
                ForEach(iconOptions, id: \.self) { icon in
                    iconButton(icon)
                }
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 20)
    }
    
    private func iconButton(_ icon: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedIcon = icon
                saveIcon(icon)
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        selectedIcon == icon ?
                        LinearGradient(
                            colors: [Color.accentColor.opacity(0.2), Color.accentColor.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color(nsColor: .controlBackgroundColor), Color(nsColor: .controlBackgroundColor)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 85)
                
                Text(icon)
                    .font(.system(
                        size: icon == "</>" ? 32 : 42,
                        weight: .bold,
                        design: .monospaced
                    ))
                    .foregroundColor(selectedIcon == icon ? .accentColor : .primary)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        selectedIcon == icon ?
                        LinearGradient(
                            colors: [.accentColor, .accentColor.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [.clear, .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: selectedIcon == icon ? 2.5 : 0
                    )
            )
            .shadow(
                color: selectedIcon == icon ? Color.accentColor.opacity(0.3) : .clear,
                radius: 10,
                y: 5
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(selectedIcon == icon ? 1.05 : 1.0)
    }
    
    // Step 4: Shortcuts
    private var step4Shortcuts: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "keyboard.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 12, y: 4)
                
                Text("Step 4: Keyboard Shortcuts")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                
                Text("Learn the essential shortcuts to get started")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            shortcutRow("⌘ ⇧ V", "Open clipboard history")
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 20)
    }
    
    private func getDefaultScreenshotPath() -> String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let screenshotsURL = documentsURL.appendingPathComponent("Screenshots")
        return screenshotsURL.path
    }
    
    private func selectScreenshotFolder() {
        let panel = NSOpenPanel()
        panel.title = "Select Screenshot Folder"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        
        // Si ya hay una ruta guardada, abrir en esa ubicación
        if !screenshotPath.isEmpty {
            panel.directoryURL = URL(fileURLWithPath: screenshotPath)
        } else {
            // Abrir en Documents por defecto
            panel.directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        }
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                screenshotPath = url.path
                saveScreenshotPath(url.path)
            }
        }
    }
    
    private func shortcutRow(_ keys: String, _ description: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(keys)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.secondary.opacity(0.12),
                                    Color.secondary.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
                )
            
            Text(description)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
        )
    }
    
    private var footerSection: some View {
        VStack(spacing: 8) {
            HStack {
                if currentStep > 1 {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentStep -= 1
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
                } else {
                    // Espaciador invisible para mantener el layout consistente
                    Color.clear
                        .frame(width: 0, height: 0)
                }
                
                Spacer()
                
                if currentStep < totalSteps {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentStep += 1
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("Next")
                                .font(.system(size: 14, weight: .semibold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                } else {
                    Button {
                        saveIcon(selectedIcon)
                        
                        // Guardar el estado de onboarding
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        UserDefaults.standard.synchronize() // Forzar sincronización inmediata
                        
                        // Verificar que se guardó correctamente
                        let bundleId = Bundle.main.bundleIdentifier ?? "open.Essential"
                        print("✅ Onboarding completado y guardado")
                        print("   Bundle ID: \(bundleId)")
                        print("   Valor guardado: \(UserDefaults.standard.bool(forKey: "hasCompletedOnboarding"))")
                        
                        // Forzar escritura al disco
                        CFPreferencesAppSynchronize(bundleId as CFString)
                        
                        onComplete()
                    } label: {
                        HStack(spacing: 6) {
                            Text("Get Started")
                                .font(.system(size: 14, weight: .semibold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                }
            }
            
            Text("Developed by @Vastyen. Open Source Project Essential")
                .font(.system(size: 10))
                .foregroundColor(.secondary.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 4)
                .padding(.horizontal, 0)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [
                    Color(nsColor: .windowBackgroundColor).opacity(0.8),
                    Color(nsColor: .windowBackgroundColor)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private func checkPermissions() {
        screenCaptureGranted = CGPreflightScreenCaptureAccess()
        accessibilityGranted = AXIsProcessTrusted()
    }
    
    private func requestScreenCapture() {
        NSApp.activate(ignoringOtherApps: true)
        
        // Primero intentar solicitar el permiso directamente
        let granted = CGRequestScreenCaptureAccess()
        
        // Esperar un momento y verificar
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let hasPermission = CGPreflightScreenCaptureAccess()
            if hasPermission {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    self.screenCaptureGranted = true
                }
                return
            }
            
            // Si no se otorgó, abrir System Settings
            let urlString: String
            if #available(macOS 13.0, *) {
                urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"
            } else {
                urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"
            }
            
            if let url = URL(string: urlString) {
                NSWorkspace.shared.open(url)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        }
    }
    
    private func requestAccessibility() {
        NSApp.activate(ignoringOtherApps: true)
        
        // Solicitar permisos de accesibilidad
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if trusted {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                self.accessibilityGranted = true
            }
        } else {
            // Abrir System Settings para accesibilidad
            let urlString: String
            if #available(macOS 13.0, *) {
                urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
            } else {
                urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
            }
            
            if let url = URL(string: urlString) {
                NSWorkspace.shared.open(url)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        }
    }
    
    private func loadSavedIcon() {
        UserDefaults.standard.synchronize()
        if let saved = UserDefaults.standard.string(forKey: "menuBarIcon") {
            selectedIcon = saved
        }
    }
    
    private func saveIcon(_ icon: String) {
        UserDefaults.standard.set(icon, forKey: "menuBarIcon")
        UserDefaults.standard.synchronize()
    }
    
    private func loadScreenshotPath() {
        UserDefaults.standard.synchronize()
        if let saved = UserDefaults.standard.string(forKey: "screenshotPath"), !saved.isEmpty {
            screenshotPath = saved
        } else {
            screenshotPath = ""
        }
    }
    
    private func saveScreenshotPath(_ path: String) {
        UserDefaults.standard.set(path, forKey: "screenshotPath")
        UserDefaults.standard.synchronize()
    }
}

struct ClipboardView: View {
    @ObservedObject var store: ClipboardStore
    let onDismiss: () -> Void
    
    @State private var hoveredEntryId: UUID?
    @State private var searchText: String = ""
    
    private var filteredEntries: [ClipboardEntry] {
        guard !searchText.isEmpty else { return store.entries }
        
        return store.entries.filter { entry in
            switch entry.content {
            case .text(let string):
                return string.localizedCaseInsensitiveContains(searchText)
            case .image:
                return "image".localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            searchBar
            Divider()
            contentView
        }
        .frame(width: 320, height: 420)
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "doc.on.clipboard.fill")
                .font(.title3)
                .foregroundColor(.accentColor)
            
            Text("Clipboard History")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Text("\(store.entries.count)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.2))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.subheadline)
            
            TextField("Search...", text: $searchText)
                .textFieldStyle(.plain)
                .font(.subheadline)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private var contentView: some View {
        if filteredEntries.isEmpty {
            emptyStateView
        } else {
            entriesListView
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "clipboard")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text(searchText.isEmpty ? "No clipboard history" : "No results found")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if searchText.isEmpty {
                Text("Copy something to get started")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var entriesListView: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                ForEach(filteredEntries) { entry in
                    ClipboardEntryRow(
                        entry: entry,
                        isHovered: hoveredEntryId == entry.id,
                        onSelect: {
                            store.copyToClipboard(entry)
                            onDismiss()
                        },
                        onDelete: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                store.deleteEntry(entry)
                            }
                        }
                    )
                    .onHover { isHovered in
                        hoveredEntryId = isHovered ? entry.id : nil
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    }
}

struct ClipboardEntryRow: View {
    let entry: ClipboardEntry
    let isHovered: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteButton = false
    
    var body: some View {
        HStack(spacing: 10) {
            contentPreview
            
            Spacer()
            
            if isHovered {
                deleteButton
            } else {
                timestampView
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovered ? Color.accentColor.opacity(0.1) : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
    }
    
    @ViewBuilder
    private var contentPreview: some View {
        switch entry.content {
        case .text(let string):
            textPreview(string)
        case .image(let image):
            imagePreview(image)
        }
    }
    
    private func textPreview(_ string: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "doc.text")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(entry.content.previewText)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func imagePreview(_ image: NSImage) -> some View {
        HStack(spacing: 8) {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 36, height: 36)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Screenshot")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text("\(Int(image.size.width)) × \(Int(image.size.height))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var timestampView: some View {
        Text(entry.timestamp, style: .relative)
            .font(.caption2)
            .foregroundColor(.secondary)
    }
    
    private var deleteButton: some View {
        Button(action: onDelete) {
            Image(systemName: "trash")
                .font(.caption)
                .foregroundColor(.red.opacity(0.8))
        }
        .buttonStyle(.plain)
        .help("Delete")
    }
}

#Preview {
    ClipboardView(store: ClipboardStore(), onDismiss: {})
}

