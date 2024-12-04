//
//  DriversView.swift
//  Dispatch404
//
//  Created by Shawn Tucker on 12/4/24.
//

import SwiftUI

// MODIFIED: Simple circle shape
struct CircleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: rect)
        return path
    }
}

struct Driver: Identifiable, Codable {
    let id: String
    let name: String
    let phone: String
    let home: String
    let carded: [String: [String]]
    
    var imageUrl: String {
        "/api/placeholder/400/400"
    }
    
    private static let locationAbbreviations = [
        "Charleston": "CHS",
        "Charlotte": "CLT",
        "N.Augusta": "NAG",
        "Sparty": "SPTY",
        "Belton": "BLT"
    ]
    
    var cardedLocations: String {
        carded.keys
            .map { location in
                Driver.locationAbbreviations[location] ?? location
            }
            .joined(separator: " • ")
    }
}

struct DriversView: View {
    @State private var drivers: [Driver] = []
    @State private var selectedDriver: Driver?
    @State private var showingProfile = false
    
    var body: some View {
        NavigationView {
            List(drivers) { driver in
                DriverRowView(driver: driver)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedDriver = driver
                        showingProfile = true
                    }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Drivers")
            .sheet(isPresented: $showingProfile, content: {
                if let driver = selectedDriver {
                    DriverProfileSheet(driver: driver)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
            })
        }
        .onAppear {
            if let jsonData = DriverData.sampleJsonString.data(using: .utf8) {
                do {
                    drivers = try JSONDecoder().decode([Driver].self, from: jsonData)
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }
    }
}

struct DriverProfileSheet: View {
    let driver: Driver
    // ADDED: Random color generator
    private let randomColor: Color = [.blue, .green, .orange, .pink, .purple, .red].randomElement() ?? .blue
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // MODIFIED: Profile Image and Basic Info
                    HStack(spacing: 12) {
                        // REMOVED: Original Image
                        // ADDED: New profile image with pointed circle
                        AsyncImage(url: URL(string: driver.imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.white
                        }
                        .frame(width: 50, height: 50) // Made slightly taller for point
                        .clipShape(CircleShape())
                        .overlay(CircleShape().stroke(randomColor, lineWidth: 3))
                        
                        VStack {
                            Text(driver.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(driver.home)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                    }
                    .padding(.top, 20)
                    
                    // Rest of the view remains unchanged
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Carded Locations")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(Array(driver.carded.keys.sorted()), id: \.self) { location in
                            if let terminals = driver.carded[location], !terminals.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(location)
                                        .font(.system(.subheadline, weight: .semibold))
                                        .foregroundStyle(.primary)
                                    
                                    ForEach(terminals, id: \.self) { terminal in
                                        HStack(spacing: 8) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .imageScale(.small)
                                                .foregroundStyle(.green)
                                            Text(terminal)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom)
            }
        }
    }
}

struct DriverRowView: View {
    let driver: Driver
    // ADDED: Random color generator for row view
    private let randomColor: Color = [.blue, .green, .orange, .pink, .purple, .red].randomElement() ?? .blue
    
    var body: some View {
        HStack(spacing: 16) {
            // MODIFIED: Profile image in row
            AsyncImage(url: URL(string: driver.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.white
            }
            .frame(width: 48, height: 48) // Slightly taller for point
            .clipShape(CircleShape())
            .overlay(CircleShape().stroke(randomColor, lineWidth: 4))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(driver.name)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                
                Text(driver.home)
                    .font(.system(.subheadline))
                    .foregroundStyle(.secondary)
                
                Text(driver.phone)
                    .font(.system(.subheadline))
                    .foregroundStyle(.secondary)
                
                Label {
                    Text(driver.cardedLocations)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.blue)
                } icon: {
                    Image(systemName: "creditcard.fill")
                        .imageScale(.small)
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
    // Preview
    #Preview {
        DriversView()
    }

    

