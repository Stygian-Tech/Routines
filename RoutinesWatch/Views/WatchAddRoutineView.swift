//
//  WatchAddRoutineView.swift
//  RoutinesWatch
//
//  Created for watchOS routine creation
//

import SwiftUI
import SwiftData

struct WatchAddRoutineView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Binding var isPresented: Bool
    @State private var routineName: String = ""
    @State private var selectedTime = Date()
    @State private var selectedColor: SystemColors = .blue
    @State private var selectedSymbol: String = "list.bullet"
    @FocusState private var isTextFieldFocused: Bool
    
    private let commonSymbols = [
        "sun.and.horizon", "moon.stars", "cup.and.saucer.fill",
        "figure.run", "bed.double.fill", "book.fill",
        "heart.fill", "star.fill", "flame.fill",
        "leaf.fill", "drop.fill", "bolt.fill"
    ]
    
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
                    
                    // Create button
                    Button(action: {
                        createRoutine()
                    }) {
                        Label("Create Routine", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(selectedColor.color)
                    .disabled(routineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel("Create routine")
                }
                .padding()
            }
            .navigationTitle("New Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
    
    private func createRoutine() {
        let trimmedName = routineName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let newRoutine = Routine(
            name: trimmedName,
            time: selectedTime,
            iconColor: selectedColor.rawValue,
            iconSymbol: selectedSymbol
        )
        
        modelContext.insert(newRoutine)
        
        do {
            try modelContext.save()
            isPresented = false
        } catch {
            print("Error creating routine: \(error.localizedDescription)")
        }
    }
}

