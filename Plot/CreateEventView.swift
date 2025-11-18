//
//  CreateEventView.swift
//  Plot
//
//  Created by Julian Mazzier on 11/14/25.
//

import SwiftUI
import CoreLocation

struct CreateEventView: View {
    var onCreated: (() -> Void)? = nil

    @State private var title = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var isBusy = false
    @State private var successMessage: String?
    @State private var errorMessage: String?

    // To handle address lookup
    private let geocoder = CLGeocoder()

    var body: some View {
        AuthScaffold(title: "Create Event") {
            VStack(spacing: 16) {
                // Title
                HStack(spacing: 10) {
                    Image(systemName: "text.line.first.and.arrowtriangle.forward")
                        .foregroundColor(.white.opacity(0.6))
                    TextField("Title", text: $title)
                        .submitLabel(.next)
                }
                .authField()

                // Description
                HStack(spacing: 10) {
                    Image(systemName: "text.quote")
                        .foregroundColor(.white.opacity(0.6))
                    TextField("Description", text: $description)
                        .submitLabel(.next)
                }
                .authField()

                // Date Picker
                DatePicker("Date & Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.vertical, 8)

                // Address
                HStack(spacing: 10) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.white.opacity(0.6))
                    TextField("Street Address", text: $address)
                        .textInputAutocapitalization(.words)
                }
                .authField()

                // City
                HStack(spacing: 10) {
                    Image(systemName: "building.2")
                        .foregroundColor(.white.opacity(0.6))
                    TextField("City", text: $city)
                        .textInputAutocapitalization(.words)
                }
                .authField()

                // State
                HStack(spacing: 10) {
                    Image(systemName: "map.fill")
                        .foregroundColor(.white.opacity(0.6))
                    TextField("State", text: $state)
                        .textInputAutocapitalization(.words)
                }
                .authField()

                // Submit Button
                Button {
                    Task {
                        guard !isBusy else { return }
                        isBusy = true
                        errorMessage = nil
                        successMessage = nil
                        defer { isBusy = false }

                        do {
                            // Combine inputs into a single query
                            let fullAddress = "\(address), \(city), \(state)"
                            print("📍 Geocoding \(fullAddress)")

                            guard let coordinate = try await geocode(fullAddress) else {
                                errorMessage = "Unable to find that location. Please verify and try again."
                                return
                            }

                            try await SupabaseManager.shared.createEvent(
                                title: title,
                                description: description,
                                date: date,
                                latitude: coordinate.latitude,
                                longitude: coordinate.longitude
                            )

                            await MainActor.run {
                                successMessage = "✅ Event Created!"
                                title = ""
                                description = ""
                                address = ""
                                city = ""
                                state = ""
                                onCreated?()
                            }

                        } catch {
                            print("❌ Error creating event:", error.localizedDescription)
                            await MainActor.run {
                                errorMessage = "Could not create event. Try again."
                            }
                        }
                    }
                } label: {
                    HStack {
                        if isBusy { ProgressView().tint(.white) }
                        Text(isBusy ? "Creating…" : "Create Event")
                    }
                }
                .primaryCTA()
                .padding(.top, 4)

                if let msg = successMessage {
                    Text(msg)
                        .font(.callout)
                        .foregroundColor(.green)
                        .padding(.top, 8)
                } else if let error = errorMessage {
                    Text(error)
                        .font(.callout)
                        .foregroundColor(.red)
                        .padding(.top, 8)
                }

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Geocoding Helper
    private func geocode(_ query: String) async throws -> CLLocationCoordinate2D? {
        try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(query) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let location = placemarks?.first?.location {
                    continuation.resume(returning: location.coordinate)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
