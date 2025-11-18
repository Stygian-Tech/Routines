//
//  Routines_WidgetsBundle.swift
//  Routines Widgets
//
//  Created by Sam Clemente on 9/15/24.
//

import WidgetKit
import SwiftUI

@main
struct Routines_WidgetsBundle: WidgetBundle {
    var body: some Widget {
        if #available(iOS 18.0, *) { Routines_WidgetsControl() }
    }
}
