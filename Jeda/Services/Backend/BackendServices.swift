/**
 * Scope: BackendServices.swift
 * Purpose: Builds the backend-backed repositories and safety service from configured credentials.
 */

import Foundation

struct BackendServices: Sendable {
    let entryRepository: any EntryRepositing
    let summaryRepository: any SummaryRepositing
    let safetyService: any SafetyScanning

    static func make(
        credentialsProvider: any BackendCredentialsProviding = BundleBackendCredentialsProvider()
    ) -> BackendServices? {
        do {
            let credentials = try credentialsProvider.credentials()
            let configuration = APIConfiguration.backend(
                baseURL: credentials.baseURL,
                token: credentials.token
            )
            let api = APIService(configuration: configuration)

            return BackendServices(
                entryRepository: EntryRepository(
                    api: api,
                    enrichmentStore: ReflectionEnrichmentStore()
                ),
                summaryRepository: SummaryRepository(api: api),
                safetyService: SafetyService(api: api)
            )
        } catch {
            let detail = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            print("[Jeda Backend] Integrasi backend nonaktif (mode offline): \(detail)")
            return nil
        }
    }
}
