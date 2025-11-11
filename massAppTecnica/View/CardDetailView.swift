//
//  CardDetailView.swift
//  massAppTecnica
//
//  Created by Victor Manuel Blanco Mancera on 6/11/25.
//

import SwiftUI
import Foundation

/// Vista para mostrar el detalle de una tarjeta seleccionada.
struct CardDetailView: View {
    let card: TullaveCard
    @EnvironmentObject var viewModel: CardViewModel
    @State private var lastUpdate: Date = Date()
    @State private var isBalanceButtonTapped = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                TullaveCardDisplay(card: card)
                    .padding(.horizontal, 20)

                SectionView(title: "Saldo") {
                    BalanceButton(balance: card.balance)
                        .onTapGesture {
                            isBalanceButtonTapped.toggle()
                        }
                }
                .padding(.horizontal, 20)

                SectionView(title: "Detalles Adicionales") {
                    VStack(alignment: .leading, spacing: 15) {
                        ReadOnlyInput(
                            label: "Serial de la Tarjeta",
                            value: card.serial,
                            icon: "number.circle.fill"
                        )
                        ReadOnlyInput(
                            label: "Última Actualización de Saldo",
                            value: formattedDateTime(lastUpdate),
                            icon: "clock.fill"
                        )
                    }
                }
                .padding(.horizontal, 20)

                SectionView(title: "Información del Titular") {
                    VStack(spacing: 15) {
                        CardDetailItem(label: "Perfil Asociado", value: card.profile, icon: "id-card.fill")
                        Divider().background(Color.maasDark.opacity(0.5))
                        CardDetailItem(label: "Fecha de Registro", value: formattedDate(card.registeredDate), icon: "calendar")
                    }
                    .padding()
                    .background(Color.maasDark.opacity(0.8))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .padding(.top, 10)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Detalles de Tarjeta")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .foregroundColor(.white)
        .onAppear {
            Task {
                await viewModel.fetchBalance(for: card)
                lastUpdate = Date()
            }
        }
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}


// MARK: - COMPONENTES ESTILIZADOS

/// 1. Componente que simula el diseño de la "Tarjeta Saldo" con fondo púrpura/azul.
struct BalanceButton: View {
    let balance: Double

    var body: some View {
        HStack {
            Text("Mi Saldo")
                .font(.titleMedium)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Spacer()

            Text(formattedCurrency(balance))
                .font(.titleLarge)
                .fontWeight(.heavy)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.maasBalanceBlue) // El color azul/púrpura
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
        )
    }

    private func formattedCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "COP" // Asumiendo pesos colombianos
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$ 0"
    }
}

/// 2. Componente que simula un Input de Texto pero es de SOLO LECTURA.
struct ReadOnlyInput: View {
    let label: String
    let value: String
    let icon: String? // Opcional para hacerlo más flexible

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {

            // Etiqueta (Label) fuera del input
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 5)

            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(.maasPrimary)
                        .padding(.leading, 10)
                }

                Text(value)
                    .font(.body)
                    .foregroundColor(.white)

                Spacer()
            }
            .frame(height: 48) // Altura estándar de input
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.maasDark.opacity(0.8)) // Fondo oscuro
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1) // Borde gris claro
                    )
            )
        }
    }
}


/// 3. Componente que simula la Tarjeta Física (Fondo verde degradado) - Sin cambios funcionales.
struct TullaveCardDisplay: View {
    let card: TullaveCard

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            HStack {
                Text("Tullave")
                    .font(.headlineLarge)
                    .fontWeight(.heavy)
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.4))
                Spacer()
                Image(systemName: "creditcard.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }
            .padding(.top, 20)

            Spacer()

            Text(card.serial)
                .font(.titleLarge)
                .fontWeight(.bold)
                .foregroundColor(.maasDark)

            Text(card.fullName)
                .font(.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(.maasDark)
                .padding(.bottom, 15)
        }
        .frame(height: 200)
        .padding(.horizontal, 25)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .tullaveCardGradientStart,
                            .tullaveCardGradientEnd
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 5)
        )
    }
}

/// 4. Componente para las filas de detalle (optimizado para fondo oscuro).
struct CardDetailItem: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.maasPrimary)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.bodyMedium)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            Spacer()
        }
    }
}


/// 5. Componente auxiliar para título de sección.
struct SectionView<Content: View>: View {
    let title: String
    let content: () -> Content

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.titleMedium)
                .fontWeight(.bold)
                .foregroundColor(.maasPrimary)

            content()
        }
    }
}

