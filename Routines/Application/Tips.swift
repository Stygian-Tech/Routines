//
//  Tips.swift
//  Routines
//
//  Created by Sam Clemente on 8/12/24.
//

import Foundation
import TipKit

struct ResetRoutinesTip: Tip {
    var title: Text {
        Text("Reset Your Routines")
    }
    
    var message: Text {
        Text("Start fresh each day by resetting your routines!")
    }
    
    var image: Image? {
        Image(systemName: "arrow.circlepath")
    }
}
