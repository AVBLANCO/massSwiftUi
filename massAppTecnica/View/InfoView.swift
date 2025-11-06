//
//  InfoView.swift
//  massAppTecnica
//
//  Created by Victor Manuel Blanco Mancera on 6/11/25.
//

import SwiftUI
import MapKit
import SwiftData

// MARK: - InfoView (Gestión de Tarjetas)
struct InfoView: View {
    @EnvironmentObject var viewModel: CardViewModel
    @Environment(\.modelContext) private var modelContext // Inyección del contexto de SwiftData

    @State private var serialInput: String = ""

    // Query de SwiftData para obtener todas las tarjetas guardadas
    @Query(sort: \TullaveCard.registeredDate, order: .reverse) private var savedCards: [TullaveCard]

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Tarjeta Activa")) {
                    if let activeCard = viewModel.activeCardInfo {
                        // Se mantiene CardDetailRow para mostrar los detalles de la activa
                        CardDetailRow(card: activeCard)
                    } else {
                        Text("No hay tarjeta seleccionada.")
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Registrar Nueva Tarjeta")) {
                    VStack {
                        TextField("Serial de Tarjeta Tullave", text: $serialInput)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)

                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Button("Verificar y Registrar") {
                                Task {
                                    // Pasa la lista de tarjetas para la verificación de duplicados.
                                    await viewModel.registerCard(serial: serialInput, allSavedCards: savedCards)
                                    serialInput = ""
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            // Desactivar si el serial es muy corto o si ya hay una carga en curso
                            .disabled(serialInput.count < 5 || viewModel.isLoading)
                        }
                    }

                    if let error = viewModel.registrationError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                Section(header: Text("Tarjetas Registradas")) {
                    // Ahora cada tarjeta es un NavigationLink
                    ForEach(savedCards) { card in
                        // 1. El NavigationLink lleva a la vista de detalle
                        NavigationLink(destination: CardDetailView(card: card)) {
                            CardListRow(card: card) // CardListRow ya no necesita el viewModel
                        }
                        // 2. Usamos .onTapGesture para establecer la tarjeta como activa justo antes de navegar
                        .onTapGesture {
                            viewModel.setActiveCard(card)
                        }
                    }
                    .onDelete(perform: deleteCards)
                }
            }
            .navigationTitle("Información Tullave")
            .onAppear {
                // Configura el ViewModel con el contexto de SwiftData al aparecer la vista
                viewModel.setup(context: modelContext)
            }
        }
    }

    private func deleteCards(offsets: IndexSet) {
        withAnimation {
            offsets.map { savedCards[$0] }.forEach(viewModel.deleteCard)
        }
    }
}

// MARK: - VISTAS DE DETALLE Y FILA

/// Componente para mostrar detalles de la tarjeta activa (sin cambios mayores)
struct CardDetailRow: View {
    let card: TullaveCard

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(card.fullName)
                .font(.headline)
                .foregroundColor(.primary)
            Text("Serial: \(card.serial)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Perfil: \(card.profile)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

/// Componente para mostrar la tarjeta en la lista (simplificado)
struct CardListRow: View {
    @Bindable var card: TullaveCard
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(card.fullName)
                    // Mostrar en negrita si es la tarjeta activa
                    .fontWeight(card.isActive ? .bold : .regular)
                Text("Serial: \(card.serial)")
                    .font(.caption)
            }

            Spacer()

            if card.isActive {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
    }
}



