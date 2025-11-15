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
    @State private var isBusy = false
    @State private var successMessage: String?

    // To handle address lookup
    @State private var geocoder = CLGeocoder()

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
                    TextField("Address (e.g. 1 LMU Dr, Los Angeles, CA)", text: $address)
                        .textInputAutocapitalization(.words)
                }
                .authField()

                // Submit Button
                Button {
                    Task {
                        guard !isBusy else { return }
                        isBusy = true
                        defer { isBusy = false }

                        do {
                            var lat: Double? = nil
                            var lon: Double? = nil

                            // Use CLGeocoder to get coordinates from address
                            if !address.isEmpty {
                                if let location = try await geocode(address: address) {
                                    @State var address = ""
                                } else {
                                    print("⚠️ Could not geocode address.")
                                }
                            }

                            try await SupabaseManager.shared.createEvent(
                                title: title,
                                description: description,
                                date: date,
                                latitude: lat,
                                longitude: lon
                            )

                            successMessage = "✅ Event Created!"
                            title = ""
                            description = ""
                            address = ""
                            onCreated?()
                        } catch {
                            successMessage = "❌ Failed: \(error.localizedDescription)"
                            print("❌ Error creating event:", error)
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

                if let message = successMessage {
                    Text(message)
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 8)
                }

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Geocoding Helper
    private func geocode(address: String) async throws -> CLLocationCoordinate2D? {
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(address) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let loc = placemarks?.first?.location {
                    continuation.resume(returning: loc.coordinate)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
