//
//  AmountWithFuelType.swift
//  Dispatch404
//
//  Created by Shawn Tucker on 12/4/24.
//

import SwiftUI

// Added: Custom style for the amount text field
struct AmountTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 8)
            .padding(.horizontal, 8) // Reduced horizontal padding
            .background(Color(.systemGray6))
    }
}
struct AmountWithFuelType: View {
    @Binding var amount: String
    @Binding var selectedFuelType: String
    var hasExcessAmount: Bool
    var onAmountChanged: ((String) -> Void)?
    
    private var borderColor: Color {
        if hasExcessAmount {
            return .red
        }
        return amount.count == 4 ? .green : Color.gray.opacity(0.3)
    }
    
    private var borderWidth: CGFloat {
        hasExcessAmount ? 1.0 : 0.5
    }
    
    var body: some View {
        HStack(spacing: 0) {
            TextField("", text: $amount)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.primary)
                .padding(.horizontal, 8)
                .frame(height: 36)
                .onChange(of: amount) { oldValue, newValue in  // Updated syntax
                        onAmountChanged?(newValue)
                    }
            
            Menu {
                ForEach(["UNL", "PREM", "ULSD", "HSD", "K-1"], id: \.self) { fuelType in
                    Button(action: {
                        selectedFuelType = fuelType
                    }) {
                        Text(fuelType).bold()
                    }
                }
            } label: {
                Text(selectedFuelType)
                    .foregroundColor(.primary)
                    .padding(.trailing, 4)
                    .padding(.leading, 8)
                    .frame(width: 55)
                    .font(.system(size: 14))
            }
        }
        .frame(height: 36)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: borderWidth)
        )
    }
}
