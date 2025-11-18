//
//  Symbol.swift
//  Routines
//
//  Created by Sam Clemente on 7/31/24.
//

import SwiftUI

struct Symbol: Identifiable {
    var id = UUID()
    var name: String
    var file: String? = nil
    var url: String
    var color: Color
    var sfSymbolName: String? = nil
}
