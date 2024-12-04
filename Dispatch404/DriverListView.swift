//
//  DriverListView.swift
//  Dispatch404
//
//  Created by Shawn Tucker on 12/4/24.
//

import SwiftUI

// MARK: - Driver List Component
struct DriverListView: View {
    let drivers: [String]
    @Binding var selectedDriver: String?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(drivers, id: \.self) { driver in
                    if selectedDriver == nil || selectedDriver == driver {
                        DriverButton(driver: driver, selectedDriver: $selectedDriver) // CHANGE: Extracted button to separate component
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// CHANGE: New component to reduce complexity in DriverListView
struct DriverButton: View {
    let driver: String
    @Binding var selectedDriver: String?
    
    var body: some View {
        Button {
            selectedDriver = selectedDriver == driver ? nil : driver
        } label: {
            HStack(spacing: 6) {
                Text(driver)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                if selectedDriver == driver {
                    CheckmarkCircle() // CHANGE: Extracted checkmark to reusable component
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
        }
    }
}

// CHANGE: Reusable checkmark component
struct CheckmarkCircle: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.green)
                .frame(width: 20, height: 20)
            
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

struct DispatchListView: View {
    // CHANGE: Grouped related state variables into a struct
    struct DispatchState {
        var amounts: [String] = Array(repeating: "", count: 4)
        var fuelTypes = ["UNL", "PREM", "ULSD", "HSD"]
    }
    
    let stations: [User]
    let drivers = ["ADAM", "ANTHONY", "CLARENCE", "DANIEL", "DEWAYNE", "JERRY", "MARK", "MICHAEL", "TIM", "TOBIN", "ALCO", "CLARK", "PETE", "SOMCO"]
    @State private var showExcessAmountAlert = false // Add this
    
    @State private var state = DispatchState()
    @State private var selectedDriver: String? = nil
    @State private var showLowGasAlert = false
    
    // CHANGE: Simplified color and terminal info using dictionaries
    private let brandColors: [String: Color] = [
        "BP": .purple, "EXXON": .blue, "SHELL": .orange,
        "UNB": .red, "AMOCO": .yellow, "SUNOCO": .green,
        "CITGO": Color(red: 0.416, green: 0.647, blue: 0.369)
    ]
    
    private let terminalInfo: [String: (letter: String, color: Color)] = [
        "N. AUG": ("N", .blue),
        "CLT": ("C", .red),
        "SPARTY": ("S", .orange)
    ]
    
    private var totalAmount: Int {
            state.amounts.compactMap { Int($0) }.reduce(0, +)
        }
        
        private var hasExcessAmount: Bool {
            totalAmount > 8500
        }
    
    private func validateAmount(_ amount: String, fuelType: String) {
        // Only validate if amount has at least 4 digits
        if amount.count >= 4 {
            let isValid = amount == "0" || (amount.count == 4 && amount.allSatisfy { $0.isNumber })
            if !isValid, let index = state.amounts.firstIndex(of: amount) {
                state.amounts[index] = ""
            }
            
            // Only show alert if amount is 4 digits and meets criteria
            if fuelType == "UNL", let amountValue = Int(amount),
               amount.count == 4 && amountValue <= 3500 && amountValue > 0 {
                showLowGasAlert = true
            }
        }
    }
    
    private var isAllFieldsValid: Bool {
        state.amounts.allSatisfy { $0 == "0" || ($0.count == 4 && $0.allSatisfy { $0.isNumber }) }
    }
    
    var body: some View {
        List(stations) { info in
            StationRow(info: info,
                      state: $state,
                      selectedDriver: $selectedDriver,
                      drivers: drivers,
                      isAllFieldsValid: isAllFieldsValid,
                      brandColors: brandColors,
                      terminalInfo: terminalInfo,
                       onAmountChanged: validateAmount, hasExcessAmount: hasExcessAmount)
        }
        .navigationTitle("Today's Dispatch")
        .alert("Low Gas Warning", isPresented: $showLowGasAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("May need gas")
        }
    }
}

// CHANGE: Fixed StationRow implementation
struct StationRow: View {
    let info: User
    @Binding var state: DispatchListView.DispatchState
    @Binding var selectedDriver: String?
    let drivers: [String]
    let isAllFieldsValid: Bool
    let brandColors: [String: Color]
    let terminalInfo: [String: (letter: String, color: Color)]
    let onAmountChanged: (String, String) -> Void
    let hasExcessAmount: Bool
    
    var body: some View {  // Added missing body property
        VStack(spacing: 12) {
            // Main Info Row
            HStack(spacing: 12) {
                // Terminal Square Indicator
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(terminalInfo[info.terminal]?.color ?? .yellow)
                        .frame(width: 40, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.white, lineWidth: 1.5)
                                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                        )
                    
                    Text(terminalInfo[info.terminal]?.letter ?? "?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Store Information
                VStack(alignment: .leading, spacing: 4) {
                    Text(info.name)
                        .font(.subheadline)
                    Text(info.address)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Brand Badge
                Text(info.brand)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(brandColors[info.brand, default: .gray])
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(brandColors[info.brand, default: .gray].opacity(0.1))
                    .cornerRadius(6)
            }
            .padding(.horizontal, 16)
            
            // Driver Selection Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Dispatch To:")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    
                DriverListView(drivers: drivers, selectedDriver: $selectedDriver)
            }
            .padding(.vertical, 8)
            
            // Dispatch Amount Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Dispatch Amount")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    
                    if isAllFieldsValid {
                        CheckmarkCircle()
                    }
                }
                
                VStack(spacing: 12) {
                    ForEach(0..<2) { row in
                        HStack(spacing: 16) {
                            ForEach(0..<2) { col in
                                let index = row * 2 + col
                                AmountWithFuelType(
                                        amount: Binding(
                                            get: { state.amounts[index] },
                                            set: { state.amounts[index] = $0 }
                                        ),
                                        selectedFuelType: .constant(state.fuelTypes[index]),
                                        hasExcessAmount: hasExcessAmount,
                                        onAmountChanged: { newAmount in
                                            onAmountChanged(newAmount, state.fuelTypes[index])
                                        }
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                                )
                            }
                        }
                        .padding(8)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 8)
    }
}
