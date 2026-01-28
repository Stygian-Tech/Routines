//
//  SocialLinkList.swift
//  Routines
//
//  Created by Sam Clemente on 7/31/24.
//

import Foundation

class SocialLinkList: ObservableObject {
    @Published var symbols: [Symbol] = [
        .init(name: "Bluesky", url:"https://bsky.app/profile/stygiantech.dev", color: .blue, sfSymbolName: "Bluesky"),
        .init(name: "Routines on GitHub", url: "https://github.com/CountableNewt/Routines", color: .primary, sfSymbolName: "Github"),
//        .init(name: "Sam on Mastodon", file: "Mastodon", url: "https://indieweb.social/@CountableNewt/", color: .purple),
//        .init(name: "Sam on Bluesky", file: "Bluesky", url: "https://bsky.app/profile/samclemente.me", color: .blue)
//        .init(name: "Threads", file: "Threads", url: "https://www.threads.net/@CountableNewt/", color: .primary),
    ]
}
