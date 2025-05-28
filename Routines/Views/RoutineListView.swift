//
//  RoutineListView.swift
//  Routines
//
//  Created by Sam Clemente on 6/30/24.
//

import SwiftUI
import SwiftData
import TipKit

struct RoutineListView: View {
    // Data Models
    @Environment(\.modelContext) var modelContext
    @Query var routines: [Routine]
    @State var newRoutine: Routine?
    @State var routineToEdit: Routine?
    
    // Presentation Logic
    @State private var addRoutineIsPresented = false
    @State private var settingsIsPresented = false
    @State private var resetAlertIsPresented = false
    @State private var showAllRoutines = false
    @State private var routinesAreHidden = false
    @State private var addIsPressed = false
    @State private var addButtonIsPresented = true
    @State private var editRoutineIsPresented = false
    
    // Layout Properties
    let backgroundGradient = Gradient(colors: [.purple, .clear])
    let resetRoutinesTip = ResetRoutinesTip()
    
    var today: String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    var body: some View {
        ZStack {
            // TODO: This isn't working
            LinearGradient(gradient: backgroundGradient, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.all)
            
            NavigationStack {
                Group {
                    if routines.isEmpty {
                        Text("No Routines")
                            .foregroundStyle(.secondary)
                    } else {
                        RoutineList(showAllRoutines: $showAllRoutines, addButtonIsPresented: $addButtonIsPresented, routineToEdit: $routineToEdit, deleteRoutine: deleteRoutine, getTimeComponent: getTimeComponent)
                        .onChange(of: routineToEdit) { _, newValue in
                            if newValue != nil {
                                editRoutineIsPresented = true
                            }
                        }
                        .onAppear() {
                            for routine in routines {
                                routine.checkRoutineCompletion()
                            }
                            withAnimation {
                                addButtonIsPresented = true
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Donate", systemImage: "gear", action: { settingsIsPresented = true })
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Reset Routines", systemImage: "arrow.circlepath", action: { resetAlertIsPresented = true })
                            .popoverTip(resetRoutinesTip)
                            .onTapGesture {
                                resetRoutinesTip.invalidate(reason: .actionPerformed)
                            }
                            .alert("Reset Routines to Incomplete?", isPresented: $resetAlertIsPresented) {
                                Button("Reset", role: .destructive, action: resetRoutines)
                                Button("Cancel", role: .cancel, action: { resetAlertIsPresented = false })
                            }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Show All Routines", systemImage: showAllRoutines ? "eye" : "eye.slash") {
                            withAnimation {
                                showAllRoutines.toggle()
                            }
                        }
                    }
                }
                .navigationTitle(showAllRoutines ? "All Routines" : "Routines")
                .sheet(isPresented: $settingsIsPresented) {
                    SettingsSheet(isPresented: $settingsIsPresented)
                }
                .sheet(isPresented: $addRoutineIsPresented) {
                    AddRoutineSheet(
                        newRoutine: $newRoutine,
                        isPresented: $addRoutineIsPresented,
                        modelContext: modelContext
                    )
                }
                .sheet(isPresented: $editRoutineIsPresented, onDismiss: { routineToEdit = nil }) {
                    if let routine = routineToEdit {
                        EditRoutineSheet(
                            routine: routine, 
                            isPresented: $editRoutineIsPresented
                        )
                    } else {
                        Text("No Routine Selected")
                    }
                }
            }
            if addButtonIsPresented {
                AddButton(isPressed: $addIsPressed, onAdd: addRoutine)
            }
        }
    }

    // MARK: - Helper Methods
    
    private func getTimeComponent(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return calendar.date(from: components) ?? date
    }
    
    private func resetRoutines() {
        for routine in routines {
            routine.resetSteps()
        }
    }
    
    private func addRoutine() {
        addRoutineIsPresented = true
        let routine = Routine()
        modelContext.insert(routine)
        newRoutine = routine
    }
    
    private func deleteRoutine(_ indexSet: IndexSet) {
        for index in indexSet {
            let routine = routines.sorted(by: { getTimeComponent($0.time) < getTimeComponent($1.time) })[index]
            modelContext.delete(routine)
        }
    }
}

// MARK: - SettingsSheet

struct SettingsSheet: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            SettingsView(isPresented: $isPresented)
                .navigationTitle("Settings")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Done")
                        }
                    }
                }
        }
    }
}

// MARK: - AddButton

struct AddButton: View {
    @Binding var isPressed: Bool
    var onAdd: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Circle()
                    .fill(isPressed ? Color.accentColor.opacity(0.7) : Color.accentColor)
                    .frame(width: 60)
                    .overlay(
                        Image(systemName: "plus")
                            .foregroundStyle(.white)
                            .font(.title2)
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation {
                                    isPressed = true
                                }
                            }
                            .onEnded { _ in
                                withAnimation {
                                    isPressed = false
                                    onAdd()
                                }
                            }
                    )
            }
            .padding(.trailing, 30)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - AddRoutineSheet

struct AddRoutineSheet: View {
    @Binding var newRoutine: Routine?
    @Binding var isPresented: Bool
    var modelContext: ModelContext
    
    var body: some View {
        NavigationStack {
            EditRoutineView(routine: newRoutine ?? Routine(), onDismiss: { tempRoutine in
                modelContext.delete(newRoutine ?? Routine())
                isPresented = false
            }, onSave: { tempRoutine in
                if let routine = newRoutine {
                    routine.name = tempRoutine.name
                    routine.time = tempRoutine.time
                    routine.iconSymbol = tempRoutine.iconSymbol
                    routine.iconColor = tempRoutine.iconColor
                    routine.days = tempRoutine.days
                }
                isPresented = false
            })
            .navigationTitle("New Routine")
        }
    }
}

// MARK: - EditRoutineSheet

struct EditRoutineSheet: View {
    let routine: Routine
    @Binding var isPresented: Bool
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            EditRoutineView(routine: routine) { tempRoutine in
                modelContext.delete(tempRoutine)
                isPresented = false
            } onSave: { tempRoutine in
                routine.name = tempRoutine.name
                routine.time = tempRoutine.time
                routine.iconSymbol = tempRoutine.iconSymbol
                routine.iconColor = tempRoutine.iconColor
                routine.days = tempRoutine.days
                modelContext.delete(tempRoutine)
                isPresented = false
            }
            .navigationTitle("Edit \(routine.name)")
        }
    }
}
