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
    
    // NEW: Added enums for the new dropdowns
       enum WeekDay: String, CaseIterable {
           case mon = "Mon", tue = "Tue", wed = "Wed", thu = "Thu"
           case fri = "Fri", sat = "Sat", sun = "Sun"
       }
       
       enum ContactMethod: String, CaseIterable {
           case email = "Email"
           case text = "Text"
           case phone = "Phone"
       }
    
    // NEW: Added time array for the time dropdown
       let times = stride(from: 0, to: 24*60, by: 15).map { minutes in
           let hour = (minutes / 60) % 12
           let adjustedHour = hour == 0 ? 12 : hour
           let minute = String(format: "%02d", minutes % 60)
           let period = minutes < 12*60 ? "am" : "pm"
           return "\(adjustedHour):\(minute)\(period)"
       }
    
    // NEW: Added TimeSlot enum and state
    enum TimeSlot: String, CaseIterable {
        case anyTime = "Any time"
        case earlyShift = "12am - 7am"
        case dayShift = "7am - 3pm"
        case lateShift = "3pm - 12am"
    }
    
    @State private var selectedDay: WeekDay = .mon
    @State private var selectedTime: String = "12:00am"
    @State private var selectedContact: ContactMethod = .email
    @State private var selectedTimeSlot: TimeSlot = .anyTime
    @State private var isTimeSlotExpanded = false
    @State private var notes: String = ""
    @State private var isOrderConfirmed = false
    @Binding var state: DispatchListView.DispatchState
    @Binding var selectedDriver: String?
    
    let drivers: [String]
    let isAllFieldsValid: Bool
    let brandColors: [String: Color]
    let terminalInfo: [String: (letter: String, color: Color)]
    let onAmountChanged: (String, String) -> Void
    let hasExcessAmount: Bool
    
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 12) {
            stationInfoSection
            schedulingSection
            driverSelectionSection
            if selectedDriver != nil {
                timeSlotSection
            }
            dispatchAmountSection
            notesSection
        }
        .padding(.vertical, 8)
        // NEW: Added tap gesture to dismiss keyboard
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                         to: nil, from: nil, for: nil)
        }
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
    
    // NEW: Added time slot section
    private var timeSlotSection: some View {
            HStack {
                Text("Deliver time:")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Menu {
                    ForEach(TimeSlot.allCases, id: \.self) { slot in
                        Button(action: {
                            selectedTimeSlot = slot
                        }) {
                            if selectedTimeSlot == slot {
                                Label(slot.rawValue, systemImage: "checkmark")
                            } else {
                                Text(slot.rawValue)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedTimeSlot.rawValue)
                            .font(.system(size: 14))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)

        
    }
    
    // NEW: Added notes section component
    private var notesSection: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "note.text")
                .foregroundColor(.gray)
                .frame(width: 24, height: 24)
            
            TextField("Add notes...", text: $notes, axis: .vertical)
                .font(.system(size: 13))
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
    
    private var schedulingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Order placed:")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                // Day dropdown
                Menu {
                    ForEach(WeekDay.allCases, id: \.self) { day in
                        Button(action: { selectedDay = day }) {
                            if selectedDay == day {
                                Label(day.rawValue, systemImage: "checkmark")
                            } else {
                                Text(day.rawValue)
                            }
                        }
                    }
                } label: {
                    menuLabel(text: selectedDay.rawValue)
                }
                
                // Time dropdown
                Menu {
                    ForEach(times, id: \.self) { time in
                        Button(action: { selectedTime = time }) {
                            if selectedTime == time {
                                Label(time, systemImage: "checkmark")
                            } else {
                                Text(time)
                            }
                        }
                    }
                } label: {
                    menuLabel(text: selectedTime)
                }
                
                // Contact method dropdown
                Menu {
                    ForEach(ContactMethod.allCases, id: \.self) { method in
                        Button(action: { selectedContact = method }) {
                            if selectedContact == method {
                                Label(method.rawValue, systemImage: "checkmark")
                            } else {
                                Text(method.rawValue)
                            }
                        }
                    }
                } label: {
                    menuLabel(text: selectedContact.rawValue)
                }

                // REPLACE the existing checkmark button with this updated version
                // This gives better touch area and proper spacing
                Button(action: {
                    withAnimation {
                        isOrderConfirmed.toggle()
                    }
                }) {
                    ZStack {
                        Circle()
                            .stroke(isOrderConfirmed ? Color.green : Color.gray.opacity(0.5), lineWidth: 1.5)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(isOrderConfirmed ? .green : .gray.opacity(0.5))
                    }
                    .frame(width: 44, height: 44)  // Makes touch target bigger
                    .contentShape(Rectangle())      // Makes entire frame tappable
                }
                .padding(.leading, 8)               // Adds space between dropdown and checkmark
            }
        }
        .padding(.horizontal, 16)
    }
        
    
    
    // NEW: Helper function for consistent menu label styling
    private func menuLabel(text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 14))
                .frame(minWidth: 30)
            if !isOrderConfirmed {  // This is correct now - show/hide chevron based on confirmation
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
            }
        }
        .foregroundColor(.primary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

