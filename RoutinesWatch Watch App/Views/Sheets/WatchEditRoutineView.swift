//
//  WatchEditRoutineView.swift
//  RoutinesWatch
//
//  Created for watchOS routine creation and editing
//

import SwiftUI
import SwiftData

struct WatchEditRoutineView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Binding var isPresented: Bool
    var routine: Routine?
    
    @State private var routineName: String = ""
    @State private var selectedTime = Date()
    @State private var selectedColor: SystemColors = .blue
    @State private var selectedSymbol: String = "list.bullet"
    @State private var selectedDays: [Weekday] = DateUtility.allWeekdays()
    @FocusState private var isTextFieldFocused: Bool
    
    private var routineManager: RoutineManager {
        RoutineManager(modelContext: modelContext)
    }
    
    /// Days that cannot be removed because at least one step has only that day scheduled.
    /// Removing such a day would leave the step with zero days (orphaned).
    private var daysRequiredBySteps: Set<Weekday> {
        guard let routine = routine, let steps = routine.steps else { return [] }
        var lockedDays = Set<Weekday>()
        for step in steps {
            // If step has only one day, that day is locked
            if step.days.count == 1, let onlyDay = step.days.first {
                lockedDays.insert(onlyDay)
            }
        }
        return lockedDays
    }
    
    private let commonSymbols = [
        "sun.and.horizon", "moon.stars", "cup.and.saucer.fill",
        "figure.run", "bed.double.fill", "book.fill",
        "heart.fill", "star.fill", "flame.fill",
        "leaf.fill", "drop.fill", "bolt.fill"
    ]
    
    private var isEditing: Bool {
        routine != nil
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Name field
                    TextField("Routine Name", text: $routineName)
                        .textInputAutocapitalization(.words)
                        .focused($isTextFieldFocused)
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(8)
                    
                    // Time picker
                    DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    
                    // Days selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Days")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        WatchEditDaysView(
                            days: $selectedDays,
                            iconColor: selectedColor.color,
                            daysRequiredByChildren: daysRequiredBySteps
                        )
                    }
                    
                    // Color selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Color")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(SystemColors.allCases, id: \.self) { color in
                                    Button(action: {
                                        selectedColor = color
                                    }) {
                                        Circle()
                                            .fill(color.color)
                                            .frame(width: 30, height: 30)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.primary, lineWidth: selectedColor == color ? 2 : 0)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    
                    // Symbol selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Icon")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(commonSymbols, id: \.self) { symbol in
                                    Button(action: {
                                        selectedSymbol = symbol
                                    }) {
                                        Image(systemName: symbol)
                                            .font(.title3)
                                            .foregroundStyle(selectedSymbol == symbol ? selectedColor.color : .secondary)
                                            .frame(width: 40, height: 40)
                                            .background(
                                                Circle()
                                                    .fill(selectedSymbol == symbol ? selectedColor.color.opacity(0.2) : Color.gray.opacity(0.15))
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    
                    // Save/Create button
                    Button(action: {
                        saveRoutine()
                    }) {
                        Label(isEditing ? "Save Routine" : "Create Routine", systemImage: isEditing ? "checkmark.circle.fill" : "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(selectedColor.color)
                    .disabled(routineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel(isEditing ? "Save routine" : "Create routine")
                }
                .padding()
            }
            .navigationTitle(isEditing ? "Edit Routine" : "New Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                if let routine = routine {
                    // Initialize from existing routine
                    routineName = routine.name
                    selectedTime = routine.time
                    selectedColor = SystemColors(rawValue: routine.iconColor) ?? .blue
                    selectedSymbol = routine.iconSymbol
                    selectedDays = routine.days
                }
                isTextFieldFocused = true
            }
        }
    }
    
    private func saveRoutine() {
        let trimmedName = routineName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        Task {
            do {
                if let routine = routine {
                    // Find days that were removed from routine
                    let oldDays = Set(routine.days)
                    let newDays = Set(selectedDays)
                    let removedDays = oldDays.subtracting(newDays)
                    
                    // Cascade removed days to steps
                    if !removedDays.isEmpty, let steps = routine.steps {
                        for step in steps {
                            var stepDays = step.days
                            stepDays.removeAll { removedDays.contains($0) }
                            if stepDays != step.days {
                                step.days = stepDays
                            }
                        }
                        // Explicitly save step changes
                        try modelContext.save()
                    }
                    
                    // Update existing routine
                    try await routineManager.updateRoutine(
                        routine,
                        name: trimmedName,
                        time: selectedTime,
                        iconColor: selectedColor.rawValue,
                        iconSymbol: selectedSymbol,
                        days: selectedDays
                    )
                } else {
                    // Create new routine
                    _ = try await routineManager.createRoutine(
                        name: trimmedName,
                        time: selectedTime,
                        iconColor: selectedColor.rawValue,
                        iconSymbol: selectedSymbol,
                        days: selectedDays
                    )
                }
                isPresented = false
            } catch {
                print("Error saving routine: \(error.localizedDescription)")
            }
        }
    }
}

