import SwiftUI
import UIKit

struct MobileGestaltItem: Identifiable {
    let id = UUID()
    let key: String
    let obfuscatedKey: String
    let value: String?
}

struct ContentView: View {
    @StateObject private var viewModel = MGInspectorViewModel()
    @State private var searchText = ""
    @State private var showingAlert = false
    @State private var copiedText = ""
    @State private var showingShareSheet = false
    
    private let gestaltPlistPath = "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist"
    
    var filteredItems: (valid: [MobileGestaltItem], invalid: [MobileGestaltItem]) {
        let items = searchText.isEmpty ? viewModel.items :
            viewModel.items.filter {
                $0.key.localizedCaseInsensitiveContains(searchText) ||
                $0.obfuscatedKey.localizedCaseInsensitiveContains(searchText)
            }
        
        return (
            valid: items.filter { $0.value != nil },
            invalid: items.filter { $0.value == nil }
        )
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: HeaderView(title: "With Value", count: filteredItems.valid.count)) {
                    ForEach(filteredItems.valid) { item in
                        ItemView(item: item, showingAlert: $showingAlert, copiedText: $copiedText)
                    }
                }
                
                Section(header: HeaderView(title: "Without Value", count: filteredItems.invalid.count)) {
                    ForEach(filteredItems.invalid) { item in
                        ItemView(item: item, showingAlert: $showingAlert, copiedText: $copiedText)
                    }
                }
            }
            .navigationTitle("MGInspector")
            .searchable(text: $searchText, prompt: "Search keys")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            viewModel.reloadData()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = URL(string: "file://\(gestaltPlistPath)") {
                    ShareSheet(activityItems: [url])
                } else {
                    Text("File not found")
                }
            }
        }
        .alert("Copied", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(copiedText)
        }
    }
}

struct HeaderView: View {
    let title: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(count)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.2))
                .clipShape(Capsule())
        }
    }
}

struct ItemView: View {
    let item: MobileGestaltItem
    @Binding var showingAlert: Bool
    @Binding var copiedText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.key)
                    .font(.headline)
                Spacer()
                Menu {
                    Button(action: { copyOriginalKey() }) {
                        Label("Copy Key", systemImage: "key")
                    }
                    Button(action: { copyMobileGestaltKey() }) {
                        Label("Copy MobileGestalt Key", systemImage: "key.fill")
                    }
                    if let value = item.value {
                        Button(action: { copyValue() }) {
                            Label("Copy Value", systemImage: "doc.on.doc")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.blue)
                }
            }
            
            Text(item.obfuscatedKey)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let value = item.value {
                Text(value)
                    .font(.body)
                    .foregroundColor(.blue)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
    
    private func copyOriginalKey() {
        UIPasteboard.general.string = item.key
        copiedText = "\(item.key)"
        showingAlert = true
    }
    
    private func copyMobileGestaltKey() {
        UIPasteboard.general.string = item.obfuscatedKey
        copiedText = "\(item.obfuscatedKey)"
        showingAlert = true
    }
    
    private func copyValue() {
        if let value = item.value {
            UIPasteboard.general.string = value
            copiedText = "\(value)"
            showingAlert = true
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ContentView()
}
