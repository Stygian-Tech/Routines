//
//  SettingsView.swift
//  Routines
//
//  Created by Sam Clemente on 7/2/24.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @StateObject private var socialLinkList = SocialLinkList()
    @Binding var isPresented: Bool
    
    let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Follow Us")) {
                    ForEach(socialLinkList.symbols) { symbol in
                        Button(action: {
                            guard let url = URL(string: symbol.url) else {
                                return
                            }
                            UIApplication.shared.open(url)
                        }) {
                            HStack {
                                Image(symbol.file)
                                    .foregroundStyle(symbol.color)
                                Text(symbol.name)
                                Spacer()
                                Image(systemName: "chevron.forward")
                                    .foregroundStyle(.tertiary)
                                    .font(.caption)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                Section(header: Text("Donate")) {
                    Text("Coming Soon...")
                }
                Section(header: Text("Special Thanks")) {
                    LinkListCardView(urlString: "https://github.com/jeremieb/social-symbols/tree/main", name: "Social Symbols")
                    LinkListCardView(urlString: "https://github.com/alessiorubicini/SFSymbolsPickerForSwiftUI", name: "SF Symbols Picker for SwiftUI")
                }
            }
            Spacer()
            Text("Version: \(versionNumber) (\(buildNumber))")
                .font(.caption)
        }
    }
}
