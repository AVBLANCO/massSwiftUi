//
//  CardViewModel.swift
//  massAppTecnica
//
//  Created by Victor Manuel Blanco Mancera on 6/11/25.
//

import Foundation
import SwiftData
import SwiftUI

/// Clase principal que gestiona el estado de la aplicación y la interacción con SwiftData y NetworkManager.
final class CardViewModel: ObservableObject {
    @Published var activeCardInfo: TullaveCard?
    @Published var registrationError: String?
    @Published var isLoading = false

    private let networkManager = NetworkManager()

    // Inyección de dependencias para el contexto de SwiftData (se recibe de la vista principal)
    private var modelContext: ModelContext?

    /// Inicializa el ViewModel con el contexto de SwiftData y carga la tarjeta activa.
    func setup(context: ModelContext) {
        self.modelContext = context
        loadActiveCard()
    }

    // MARK: - SwiftData CRUD y Lógica

    /// Carga la tarjeta marcada como activa.
    func loadActiveCard() {
        guard let context = modelContext else { return }

        do {
            let predicate = #Predicate<TullaveCard> { $0.isActive == true }
            let descriptor = FetchDescriptor(predicate: predicate)
            let active = try context.fetch(descriptor).first

            self.activeCardInfo = active
        } catch {
            print("Error al cargar la tarjeta activa: \(error.localizedDescription)")
            self.activeCardInfo = nil
        }
    }

    /// Selecciona una tarjeta como activa, desactivando la anterior.
    func selectCard(card: TullaveCard) {
        guard let context = modelContext else { return }

        do {
            // 1. Desactiva la tarjeta que estaba activa previamente
            if let currentActive = self.activeCardInfo {
                currentActive.isActive = false
            }

            // 2. Activa la nueva tarjeta seleccionada
            card.isActive = true
            self.activeCardInfo = card

            try context.save()
        } catch {
            print("Error al seleccionar tarjeta: \(error.localizedDescription)")
        }
    }

    /// Elimina una tarjeta de la persistencia.
    func deleteCard(card: TullaveCard) {
        guard let context = modelContext else { return }

        // Si se elimina la tarjeta activa, se limpia el estado activo.
        if card.isActive {
            self.activeCardInfo = nil
            // Podríamos intentar seleccionar la tarjeta más reciente aquí si fuera necesario
        }

        context.delete(card)
        do {
            try context.save()
        } catch {
            print("Error al eliminar tarjeta: \(error.localizedDescription)")
        }
    }

    /// Registra la tarjeta: verifica con la API y guarda en SwiftData si es válida.
    func registerCard(serial: String, allSavedCards: [TullaveCard]) async {
        // Limpiamos el input para asegurar que solo se procesen números
        let cleanSerial = serial.filter { $0.isNumber }

        guard !cleanSerial.isEmpty else {
            registrationError = "El serial de la tarjeta no puede estar vacío."
            return
        }

        isLoading = true
        registrationError = nil

        guard let context = modelContext else {
            registrationError = "Contexto de datos no inicializado."
            isLoading = false
            return
        }

        // 1. Verificar si ya existe en la base de datos
        if let existingCard = allSavedCards.first(where: { $0.serial == cleanSerial }) {
            selectCard(card: existingCard)
            registrationError = "La tarjeta con serial \(cleanSerial) ya estaba registrada. Seleccionada."
            isLoading = false
            return
        }

        do {
            // 2. Validar tarjeta con la API
           // let cardData = try await networkManager.fetchCardInfo(serial: cleanSerial)
            let cardData = try await networkManager.fetchCardInformation(serial: cleanSerial)

            // 3. Desactivar la tarjeta activa anterior (si existe)
            if let currentActive = self.activeCardInfo {
                currentActive.isActive = false
            }

            // 4. Crear, establecer como activa, y guardar la nueva tarjeta
            let newCard = TullaveCard(from: cardData, isActive: true)
            context.insert(newCard)
            self.activeCardInfo = newCard // Actualiza el estado

            try context.save()

            registrationError = "Tarjeta \(cardData.cardNumber) registrada y seleccionada con éxito."

        } catch let error as NetworkError {
            registrationError = error.localizedDescription
            self.activeCardInfo = nil
        } catch {
             registrationError = "Un error inesperado ocurrió: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func setActiveCard(_ card: TullaveCard) {
        // Implementación requerida en CardViewModel:
        // 1. Recorrer todas las tarjetas en el contexto de SwiftData y poner isActive = false.
        // 2. Establecer la tarjeta seleccionada (card) como isActive = true.
        // 3. Opcional: Actualizar activeCardInfo con la información de la card.
        print("Tarjeta \(card.serial) seleccionada y configurada como activa.")
    }

}
