//
//  massAppTecnicaApp.swift
//  massAppTecnica
//
//  Created by Victor Manuel Blanco Mancera on 5/11/25.
//

import SwiftUI
import SwiftData

@main
struct massAppTecnicaApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TullaveCard.self, // Usamos tu modelo TullaveCard
        ])

        // isStoredInMemoryOnly: false (por defecto en SwiftData) asegura que los datos sean persistentes.
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Un error fatal si la inicialización de la base de datos falla
            fatalError("No se pudo crear el ModelContainer para SwiftData: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            // Establecemos la vista raíz de tu aplicación modular
            MainTabView()
        }
        // Inyectamos el contenedor de modelos en el entorno de la aplicación
        .modelContainer(sharedModelContainer)
    }
}
