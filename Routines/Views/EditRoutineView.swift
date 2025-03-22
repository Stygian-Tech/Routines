//
//  EditRoutineView.swift
//  Routines
//
//  Created by Sam Clemente on 7/2/24.
//

import Foundation
import SwiftUI
import SFSymbolsPicker

struct EditRoutineView: View {
    @Bindable private var routine: Routine
    @State private var tempRoutine: Routine
    private let circleButtonSize = 45.5
    private var onDismiss: (Routine) -> Void
    private var onSave: (Routine) -> Void
    @State private var symbolPickerIsPresented = false
    @State private var tempSymbol: String
    private var tempColor: Color {
        get {
            return tempRoutine.getIconColor()
        }
    }
    
    init(routine: Routine, onDismiss: @escaping (Routine) -> Void, onSave: @escaping (Routine) -> Void) {
        self.routine = routine
        _tempRoutine = State(initialValue: routine.copy())
        self.onDismiss = onDismiss
        self.onSave = onSave
        _tempSymbol = State(initialValue: routine.iconSymbol)
    }
    
    var body: some View {
        Form {
            Section("Name") {
                TextField("Routine Name", text: $tempRoutine.name)
            }
            Section("Time & Days") {
                DatePicker("Time", selection: $tempRoutine.time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                EditDaysView(days: $tempRoutine.days, iconColor: tempColor)
                    .padding(.vertical, 3)
            }
            Section("Icon") {
                HStack {
                    Spacer()
                    Circle()
                        .fill(tempRoutine.getIconColor())
                        .frame(width: 80)
                        .overlay(
                            Image(systemName: tempRoutine.iconSymbol)
                                .font(.largeTitle)
                                .foregroundStyle(.white)
                        )
                    Spacer()
                }
                HStack {
                    Text("Color")
                        .font(.headline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(SystemColors.allCases, id: \.self) { color in
                                Button(action: {
                                    tempRoutine.iconColor = color.rawValue
                                }) {
                                    Circle()
                                        .fill(color.color)
                                }
                                .frame(width: circleButtonSize)
                            }
                        }
                    }
                }
                HStack {
                    Text("Symbol")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        symbolPickerIsPresented = true
                    }, label: {
                        Image(systemName: tempRoutine.iconSymbol)
                            .foregroundStyle(tempRoutine.getIconColor())
                    })
                }
//                Text("Symbol")
//                    .font(.headline)
//                ForEach(IconLists.allCases, id: \.self) { list in
//                    HStack {
//                        Text(list.rawValue)
//                            .font(.caption)
//                            .frame(width: 1.5 * circleButtonSize, height: circleButtonSize, alignment: .leading)
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack {
//                                ForEach(list.iconList, id: \.self) { icon in
//                                    Button(action: {
//                                        tempRoutine.iconSymbol = icon
//                                    }) {
//                                        Circle()
//                                            .fill(.gray)
//                                            .frame(width: circleButtonSize)
//                                            .overlay(
//                                                Image(systemName: icon)
//                                                    .foregroundColor(.white)
//                                            )
//                                    }
//                                }
//                            }
//                        }
//                   }
//                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    onDismiss(tempRoutine)
                }) {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    onSave(tempRoutine)
                }) {
                    Text("Done")
                }
            }
        }
        .sheet(isPresented: $symbolPickerIsPresented) {
            SymbolsPicker(selection: $tempSymbol, title: "Select Symbol", autoDismiss: true) {
                Text("Done")
            }
            .onDisappear(perform: {
                tempRoutine.iconSymbol = tempSymbol
            })
        }
    }
}
