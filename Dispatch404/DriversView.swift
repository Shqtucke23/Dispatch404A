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
            if let jsonData = sampleJsonString.data(using: .utf8) {
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

    
    //Store the JSON
    let sampleJsonString: String = """
[
    {
      "id": "1",
      "name": "Adam",
      "image": "/api/placeholder/400/400",
      "phone": "+18431234567",
      "home": "324 Pine Valley Road",
      "carded": {
        "Charleston": ["Buckeye"],
        "Charlotte": ["Motiva N & S"],
        "N.Augusta": ["KM2", "US Oil 1 & 2"],
        "Sparty": ["Motiva", "Buckeye"]
      }
    },
    {
      "id": "2",
      "name": "Anthony",
      "image": "/api/placeholder/400/400",
      "phone": "+18431234568",
      "home": "947 Maple Creek Drive",
      "carded": {
        "Charlotte": ["KM2", "US Oil 1 & 2"],
        "N.Augusta": ["Buckeye", "KM2", "Motiva"],
        "Sparty": [],
        "Charleston": []
      }
    },
    {
      "id": "3",
      "name": "Clarence",
      "image": "/api/placeholder/400/400",
      "phone": "+18431234569",
      "home": "156 Oakwood Circle",
      "carded": {
        "Charlotte": ["Motiva N & S", "KM2", "Citgo"],
        "N.Augusta": ["KM2", "US Oil 1 & 2"],
        "Sparty": ["Motiva", "Citgo", "USoil1"],
        "Charleston": ["Buckeye", "KM"]
      }
    },
    {
      "id": "4",
      "name": "Daniel",
      "image": "/api/placeholder/400/400",
      "phone": "+18431234570",
      "home": "2873 Highland Avenue",
      "carded": {
        "Charlotte": ["Buckeye 2", "Motiva South"],
        "N.Augusta": ["KM2", "MAG 1 & 2"],
        "Sparty": ["Motiva", "Buckeye", "US Oil"],
        "Charleston": ["Buckeye", "Buckeye"]
      }
    },
    {
      "id": "5",
      "name": "Dewayne",
      "image": "/api/placeholder/400/400",
      "phone": "+18431234571",
      "home": "583 River Bend Lane",
      "carded": {
        "Charlotte": ["Motiva N & S", "KM2", "Buckeye"],
        "N.Augusta": ["KM2", "US Oil 1 & 2", "Buckeye"],
        "Sparty": ["Motiva", "Citgo", "Buckeye", "US Oil"],
        "Charleston": ["Buckeye"]
      }
    },
    {
      "id": "6",
      "name": "Jerry",
      "image": "/api/placeholder/400/400",
      "phone": "+18431234572",
      "home": "1492 Willow Street",
      "carded": {
        "Charlotte": ["Motiva N & S"],
      }
    },
    {
      "id": "7",
      "name": "Mark",
      "image": "/api/placeholder/400/400",
      "phone": "+18431234573",
      "home": "725 Dogwood Lane",
      "carded": {
        "Charlotte": ["Buckeye", "KM2", "Motiva N & S"],
        "N.Augusta": ["KM2", "US Oil 2"],
        "Sparty": ["Motiva", "Buckeye"],
        "Charleston": []
      }
    },
    {
      "id": "8",
      "name": "Michael",
      "image": "/api/placeholder/400/400",
      "phone": "+18431234574",
      "home": "364 Magnolia Drive",
      "carded": {
        "Charlotte": ["Motiva South"],
        "N.Augusta": ["US Oil 1 & 2", "KM2"],
        "Sparty": ["Motiva"],
        "Charleston": ["Buckeye"]
      }
    },
    {
      "id": "9",
      "name": "Tim",
      "image": "/api/placeholder/400/400",
      "phone": "+18431234575",
      "home": "1756 Cedar Court",
      "carded": {
        "Belton": ["Buckeye"],
        "N.Augusta": ["KM2", "US Oil 1 & 2", "Buckeye"],
        "Sparty": ["Motiva", "US Oil 1", "KM"],
        "Charleston": ["Buckeye"]
      }
    },
    {
      "id": "10",
      "name": "Tobin",
      "image": "/api/placeholder/400/400",
      "phone": "+18431234576",
      "home": "935 Forest Hills Road",
      "carded": {
        "Charlotte": ["Motiva N & S", "Citgo", "KM2", "Buckeye"],
        "N.Augusta": ["Buckeye", "KM 1 & 2", "US Oil 1 & 2"],
        "Sparty": ["Motiva", "Citgo", "Buckeye", "KM", "US Oil 1 & 2"],
        "Charleston": ["Buckeye"]
      }
    },
    {
      "id": "11",
      "name": "Z-Alco",
      "image": "/api/placeholder/400/400",
      "phone": "+18431234577",
      "home": "2145 Birch Street",
      "carded": {
        "Charlotte": ["Motiva N & S"],
        "N.Augusta": ["KM2"],
        "Sparty": ["Motiva"],
        "Charleston": ["Buckeye"]
      }
    },
    {
      "id": "12",
      "name": "Z-Clark",
      "image": "/api/placeholder/400/400",
      "phone": "+18431234578",
      "home": "487 Sycamore Avenue",
      "carded": {
        "Charlotte": ["Motiva N & S"],
        "N.Augusta": ["KM2"],
        "Sparty": ["Motiva", "Citgo"],
        "Charleston": ["Buckeye"]
      }
    },
    {
      "id": "13",
      "name": "Z-Pete",
      "image": "/api/placeholder/400/400",
      "phone": "+18431234579",
      "home": "639 Elm Street",
      "carded": {
        "Charlotte": ["Motiva N & S"],
        "N.Augusta": ["KM2"],
        "Sparty": ["Motiva"],
        "Charleston": ["Buckeye"]
      }
    },
    {
      "id": "14",
      "name": "Z-Somco",
      "image": "/api/placeholder/400/400",
      "phone": "+18431234580",
      "home": "1823 Poplar Lane",
      "carded": {
        "Charlotte": ["Motiva N & S"],
        "N.Augusta": ["KM2"],
        "Sparty": ["Motiva"],
        "Charleston": ["Buckeye"]
      }
    }
  ]







"""
