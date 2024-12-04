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
// Added: Custom view for amount with fuel type selection
struct AmountWithFuelType: View {
    @Binding var amount: String
    @Binding var selectedFuelType: String
    var onAmountChanged: ((String) -> Void)?
    
    var body: some View {
        HStack(spacing: 0) {
            TextField("", text: $amount)
                //.keyboardType(.numberPad)
                .modifier(AmountTextFieldStyle())
                .onChange(of: amount) { newValue in
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
                    .foregroundColor(.blue)
                    .padding(.trailing, 4) // Reduced padding
                    .padding(.leading, -4) // Added negative padding to bring fuel type closer to amount
                    .frame(width: 45) // Fixed width for fuel type
                    .font(.system(size: 14)) // Smaller font size
            }
        }
        .frame(height: 36) // Reduced overall height
        //.background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
