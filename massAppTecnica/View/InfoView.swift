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
    @FocusState private var serialFieldFocused: Bool

    @State private var serialInput: String = ""
    @Query(sort: \TullaveCard.registeredDate, order: .reverse) private var savedCards: [TullaveCard]

    var body: some View {
        NavigationView {
            ZStack {
                Color.maasDark.ignoresSafeArea() // Fondo oscuro principal para toda la vista

                List {
                    // --- SECCIÓN 1: Tarjeta Activa (Estilizada como Tarjeta Tullave) ---
                    Section {
                        if let activeCard = viewModel.activeCardInfo {
                            // Usamos el componente visual de la tarjeta
                            TullaveCardDisplay(card: activeCard)
                                .listRowInsets(EdgeInsets()) // Eliminar padding de la lista
                                .listRowBackground(Color.clear) // Fondo transparente
                        } else {
                            Text("No hay tarjeta seleccionada.")
                                .foregroundColor(.gray)
                                .listRowBackground(Color.maasDark.opacity(0.9))
                        }
                    } header: {
                        Text("Tarjeta Activa")
                            .font(.titleMedium)
                            .foregroundColor(.maasPrimary)
                            .padding(.top, 10)
                    }

                    // --- SECCIÓN 2: Registrar Nueva Tarjeta (Inputs y Botón Estilizados) ---
                    Section {
                        VStack(spacing: 15) {
                            // Campo de texto estilizado
                            TextField("Serial de Tarjeta Tullave", text: $serialInput)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.black.opacity(0.8)) // Fondo del input más oscuro
                                .cornerRadius(8)
                                .foregroundColor(.white) // Texto del input blanco
                                .accentColor(.maasPrimary) // Cursor verde
                                .focused($serialFieldFocused)

                            if viewModel.isLoading {
                                ProgressView("Verificando...")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(.maasPrimary)
                            } else {
                                // Botón "Verificar y Registrar" (Fondo Verde Principal)
                                Button {
                                    Task {
                                        // Pasa la lista de tarjetas para la verificación de duplicados.
                                        await viewModel.registerCard(serial: serialInput, allSavedCards: savedCards)
                                        serialInput = ""
                                    }
                                } label: {
                                    Text("Verificar y Registrar")
                                        .frame(maxWidth: .infinity)
                                }
                                .padding(.vertical, 10)
                                .background(Color.maasPrimary) // Color de fondo principal
                                .foregroundColor(.maasDark) // Texto oscuro sobre verde
                                .font(.titleMedium)
                                .cornerRadius(8)
                                .buttonStyle(PlainButtonStyle()) // Evita el estilo por defecto de la lista
                                .disabled(serialInput.count < 5 || viewModel.isLoading)
                                // Efecto visual de deshabilitado
                                .opacity((serialInput.count < 5 || viewModel.isLoading) ? 0.5 : 1.0)
                            }
                        }

                        if let error = viewModel.registrationError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    } header: {
                        Text("Registrar Nueva Tarjeta")
                            .font(.titleMedium)
                            .foregroundColor(.maasPrimary)
                    }
                    .listRowBackground(Color.maasDark.opacity(0.9)) // Fondo oscuro para la sección


                    // --- SECCIÓN 3: Tarjetas Registradas ---
                    Section {
                        ForEach(savedCards) { card in
                            NavigationLink(destination: CardDetailView(card: card)) {
                                CardListRow(card: card)
                            }
                            // Usamos .onTapGesture para establecer la tarjeta como activa
                            .onTapGesture {
                                viewModel.setActiveCard(card)
                            }
                        }
                        .onDelete(perform: deleteCards)
                    } header: {
                        Text("Tarjetas Registradas")
                            .font(.titleMedium)
                            .foregroundColor(.maasPrimary)
                    }
                    .listRowBackground(Color.maasDark.opacity(0.9))

                }
                .scrollContentBackground(.hidden) // Oculta el fondo blanco de la lista
                .listStyle(.grouped)
                .gesture(
                    TapGesture()
                        .onEnded { _ in
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                )
            }
            .navigationTitle("Gestión Tullave")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                viewModel.setup(context: modelContext)
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .onDisappear {
                serialFieldFocused = false
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    serialFieldFocused = false
                }
            }
        }
    }

    private func deleteCards(offsets: IndexSet) {
        withAnimation {
            offsets.map { savedCards[$0] }.forEach(viewModel.deleteCard)
        }
    }
}

/// Componente para mostrar la tarjeta en la lista (Estilo de Fila)
struct CardListRow: View {
    @Bindable var card: TullaveCard

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "creditcard.fill")
                .foregroundColor(card.isActive ? .maasPrimary : .gray)
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                Text(card.fullName)
                    .font(.titleMedium)
                    .foregroundColor(.white)

                HStack {
                    Text("Serial:")
                        .foregroundColor(.gray)
                    Text(card.serial)
                        .font(.bodyMedium)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            if card.isActive {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.maasPrimary)
                    .font(.title)
            }
        }
        .listRowBackground(Color.maasDark.opacity(0.9)) // Fondo oscuro para las filas
        .padding(.vertical, 8)
    }
}

/// Mantenemos CardDetailRow para la compatibilidad aunque ya no se usa directamente en la sección "Tarjeta Activa"
struct CardDetailRow: View {
    let card: TullaveCard

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(card.fullName)
                .font(.headline)
                .foregroundColor(.white)
            Text("Serial: \(card.serial)")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("Perfil: \(card.profile)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .listRowBackground(Color.maasDark.opacity(0.9))
    }
}
