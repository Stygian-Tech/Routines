//
//  AddStepView.swift
//  Routines
//
//  Created by Sam Clemente on 7/2/24.
//

import Foundation
import SwiftUI

struct AddStepView: View {
    @Bindable var routine: Routine
    @Binding var newStep: String
    private var routineColor: Color {
        get {
            return routine.getIconColor()
        }
    }
    
    var body: some View {
        Form {
            Section("Name") {
                TextField("Step", text: $newStep)
            }
            Section("Days") {
                EditDaysView(days: $routine.days, iconColor: routineColor)
            }
        }
    }
}
