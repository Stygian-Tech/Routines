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
                Section(header: Text("Appearance")) {
                    NavigationLink(destination: AppIconPickerView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "app.fill")
                                .foregroundStyle(Color.accentColor)
                            Text("App Icon")
                            Spacer()
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityHint(Text("Opens app icon picker"))
                    }
                }
                Section(header: Text("Follow Us")) {
                    ForEach(socialLinkList.symbols) { symbol in
                        LinkButton(symbol: symbol)
                    }
                }
                Section(header: Text("On the Web")) {
                    LinkButton(symbol: .init(name: "Routines Website", file: nil, url: "https://getroutines.app", color: .purple, sfSymbolName: "globe"))
                    LinkButton(symbol: .init(name: "Stygian Tech Website", file: nil, url: "https://stygiantech.dev", color: .black, sfSymbolName: "globe"))
                }
                Section(header: Text("Donate")) {
                    Text("Coming Soon...")
                }
                Section(header: Text("Special Thanks")) {
                    LinkListCardView(urlString: "https://github.com/jeremieb/social-symbols/tree/main", name: "Social Symbols")
                    LinkListCardView(urlString: "https://github.com/alessiorubicini/SFSymbolsPickerForSwiftUI", name: "SF Symbols Picker for SwiftUI")
                    LinkListCardView(urlString: "https://github.com/mono0926/LicensePlist", name: "LicensePlist")
                }
            }
            Spacer()
            Text("Version: \(versionNumber) (\(buildNumber))")
                .font(.caption)
        }
    }
}
