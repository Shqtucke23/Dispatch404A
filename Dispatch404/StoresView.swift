//
//  StoresView.swift
//  Dispatch404
//
//  Created by Shawn Tucker on 12/4/24.
//
import SwiftUI

struct StoresView: View {
    @ObservedObject var data = ReadJsonData()
    @State private var searchText = ""
    @State private var dispatchedStations: Set<UUID> = [] // Using store ID to track dispatched stations
    
    var filteredStations: [User] {
        guard !searchText.isEmpty else { return data.users }
        return data.users.filter { station in
            station.name.lowercased().contains(searchText.lowercased()) ||
            station.brand.lowercased().contains(searchText.lowercased()) ||
            station.address.lowercased().contains(searchText.lowercased()) ||
            station.city.lowercased().contains(searchText.lowercased())
        }
    }
    
    func getBrandColor(_ brand: String) -> Color {
        switch brand {
            case "BP": return .purple
            case "EXXON": return .blue
            case "SHELL": return .orange
            case "UNB": return .red
            case "AMOCO": return .yellow
            case "SUNOCO": return .green
            case "CITGO": return Color(red: 0.416, green: 0.647, blue: 0.369)
            default: return .gray
        }
    }
    
    func getTerminalInfo(_ terminal: String) -> (letter: String, color: Color) {
        switch terminal {
            case "N. AUG": return ("N", .blue)
            case "CLT": return ("C", .red)
            case "SPARTY": return ("S", .orange)
            default: return ("?", .yellow)
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredStations) { info in
                //NavigationLink(destination: StoreDetailView(store: info)) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 12) {
                            // Terminal Square Indicator
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(getTerminalInfo(info.terminal).color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(.white, lineWidth: 1.5)
                                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                                    )
                                
                                Text(getTerminalInfo(info.terminal).letter)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(info.name)
                                    .bold()
                                    .font(.system(size: 17, weight: .regular))
                                
                                Text(info.address)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(info.brand)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(getBrandColor(info.brand))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(getBrandColor(info.brand).opacity(0.1))
                                .cornerRadius(6)
                        }
                        .opacity(dispatchedStations.contains(info.id) ? 0.5 : 1)
                        .padding(.vertical, 4)
                        
                    }
                //}
                // Add this right after the NavigationLink closing brace and before .listRowSeparator:
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        // Delete action
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        // Call action
                    } label: {
                        Label("Call", systemImage: "phone")
                    }
                    .tint(.blue)
                }
                .swipeActions(edge: .leading) {
                   NavigationLink {
                       DispatchListView(stations: [info])
                   } label: {
                       Circle()
                           .fill(.white)
                           .frame(width: 30, height: 30)
                           .overlay(
                               Group {
                                   if dispatchedStations.contains(info.id) {
                                       Image(systemName: "minus")
                                           .foregroundColor(.red)
                                   } else {
                                       Image(systemName: "plus")
                                           .foregroundColor(.green)
                                   }
                               }
                               .font(.system(size: 16, weight: .bold))
                           )
                   }
                   .tint(.green)
                }
                //.swipeActions(...)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .navigationBarTitle("Gas Stations", displayMode: .inline)
            .listStyle(PlainListStyle())
            .scrollIndicators(.hidden)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search stations..."
            )
        }
    }
}

#Preview {
    StoresView()
}

