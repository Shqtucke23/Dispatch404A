//
//  AmountWithFuelType.swift
//  Dispatch404
//
//  Created by Shawn Tucker on 12/4/24.
//

import SwiftUI

struct AppConstants {
    struct FuelTypes {
        static let all = ["UNL", "PREM", "ULSD", "HSD", "K-1"]
        static let defaultType = "UNL"
    }
    
    struct UI {
        static let cornerRadius: CGFloat = 8
        static let defaultHeight: CGFloat = 36
        static let defaultPadding: CGFloat = 8
        static let menuWidth: CGFloat = 55
    }
}

// Added: Custom style for the amount text field
struct AmountTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, AppConstants.UI.defaultPadding)
            .padding(.horizontal, AppConstants.UI.defaultPadding)
            .background(Color(.systemGray6))
    }
}

struct AmountWithFuelType: View {
    // MARK: - Properties
    @Binding var amount: String
    @Binding var selectedFuelType: String
    var hasExcessAmount: Bool
    var onAmountChanged: ((String) -> Void)?
    
    // MARK: - Computed Properties
    private var borderColor: Color {
        if hasExcessAmount { return .red }
        return amount.count == 4 ? .green : Color.gray.opacity(0.3)
    }
    
    private var borderWidth: CGFloat {
        hasExcessAmount ? 1.0 : 0.5
    }
    
    var body: some View {
        HStack(spacing: 0) {
            amountTextField
            fuelTypeMenu
        }
        .frame(height: AppConstants.UI.defaultHeight)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                .stroke(borderColor, lineWidth: borderWidth)
        )
    }
    
    // MARK: - Subviews
    private var amountTextField: some View {
        TextField("", text: $amount)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .foregroundColor(.primary)
            .padding(.horizontal, AppConstants.UI.defaultPadding)
            .frame(height: AppConstants.UI.defaultHeight)
            .onChange(of: amount) { oldValue, newValue in  // Using new syntax
                onAmountChanged?(newValue)
            }
    }
    
    private var fuelTypeMenu: some View {
            Menu {
                ForEach(AppConstants.FuelTypes.all, id: \.self) { fuelType in
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
                    .padding(.leading, AppConstants.UI.defaultPadding)
                    .frame(width: AppConstants.UI.menuWidth)
                    .font(.system(size: 14))
            }
        }
    }

// IMPROVEMENT 5: Added Preview Provider for easier testing
struct AmountWithFuelType_Previews: PreviewProvider {
    static var previews: some View {
        AmountWithFuelType(
            amount: .constant("1000"),
            selectedFuelType: .constant(AppConstants.FuelTypes.defaultType),
            hasExcessAmount: false,
            onAmountChanged: nil
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
