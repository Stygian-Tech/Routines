//
//  SocialLinkList.swift
//  Routines
//
//  Created by Sam Clemente on 7/31/24.
//

import Foundation

class SocialLinkList: ObservableObject {
    @Published var symbols: [Symbol] = [
        .init(name: "Mastodon", file: "Mastodon", url: "https://indieweb.social/@CountableNewt/", color: .purple),
        .init(name: "Bluesky", file: "Bluesky", url: "https://bsky.app/profile/samclemente.me", color: .blue),
//        .init(name: "Threads", file: "Threads", url: "https://www.threads.net/@CountableNewt/", color: .primary),
        .init(name: "Routines on GitHub", file: "GitHub", url: "https://github.com/CountableNewt/Routines", color: .primary)
    ]
}
