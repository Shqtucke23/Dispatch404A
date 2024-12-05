//
//  StationRowView.swift
//  Dispatch404
//
//  Created by Shawn Tucker on 12/4/24.
//

import SwiftUI

struct StationRow: View {
    // MARK: - Properties
    let info: User
    @Binding var state: DispatchListView.DispatchState
    @Binding var selectedDriver: String?
    let drivers: [String]
    let isAllFieldsValid: Bool
    let brandColors: [String: Color]
    let terminalInfo: [String: (letter: String, color: Color)]
    let onAmountChanged: (String, String) -> Void
    let hasExcessAmount: Bool
    // NEW: Added state property for notes
    @State private var notes: String = ""
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 12) {
            stationInfoSection
            driverSelectionSection
            dispatchAmountSection
            notesSection  // NEW: Added notes section to main VStack
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - View Components
    private var stationInfoSection: some View {
        HStack(spacing: 12) {
            terminalIndicator
            storeInformation
            Spacer()
            brandBadge
        }
        .padding(.horizontal, 16)
    }
    
    private var terminalIndicator: some View {
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
    }
    
    private var storeInformation: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(info.name)
                .font(.subheadline)
            Text(info.address)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var brandBadge: some View {
        Text(info.brand)
            .font(.system(size: 17, weight: .medium))
            .foregroundColor(brandColors[info.brand, default: .gray])
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(brandColors[info.brand, default: .gray].opacity(0.1))
            .cornerRadius(6)
    }
    
    private var driverSelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dispatch To:")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                
            DriverListView(drivers: drivers, selectedDriver: $selectedDriver)
        }
        .padding(.vertical, 8)
    }
    
    private var dispatchAmountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Dispatch Amount")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                
                if isAllFieldsValid {
                    CheckmarkCircle()
                }
            }
            
            amountGrid
        }
        .padding(.top, 8)
    }
    
    // NEW: Added notes section component
    private var notesSection: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "note.text")
                .foregroundColor(.yellow)
                .frame(width: 24, height: 24)
            
            TextField("Add notes...", text: $notes, axis: .vertical)
                .font(.system(size: 16))
                .lineLimit(3)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
        .padding(.horizontal, 16)
    }
    
    private var amountGrid: some View {
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
}
