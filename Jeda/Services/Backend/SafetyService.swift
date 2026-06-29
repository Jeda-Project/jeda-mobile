/**
 * Scope: SafetyService.swift
 * Purpose: Runs crisis safety scans against the backend with an on-device fallback when offline.
 */

import Foundation

protocol SafetyScanning: Sendable {
    func scan(text: String) async -> CrisisDetectionResult
    func resources() async -> [CrisisSupportResource]
}

struct SafetyService: SafetyScanning {
    private let api: APIService
    private let onDeviceDetector: any CrisisDetecting

    init(api: APIService, onDeviceDetector: any CrisisDetecting = CrisisDetectionService()) {
        self.api = api
        self.onDeviceDetector = onDeviceDetector
    }

    func scan(text: String) async -> CrisisDetectionResult {
        do {
            let result = try await api.request(
                SafetyAPIEndpoint.scan(.init(text: text)),
                responseType: SafetyDTO.self
            )
            return CrisisDetectionResult(
                isCrisis: result.flagged,
                matchedTerms: result.matches.map(\.category)
            )
        } catch {
            return onDeviceDetector.detect(in: text)
        }
    }

    func resources() async -> [CrisisSupportResource] {
        do {
            let envelope = try await api.request(
                SafetyAPIEndpoint.resources,
                responseType: SafetyResourcesEnvelope.self
            )
            let mapped = envelope.resources.map(Self.resource(from:))
            return mapped.isEmpty ? [.sejiwa] : mapped
        } catch {
            return [.sejiwa]
        }
    }

    static func resource(from dto: SafetyResourceDTO) -> CrisisSupportResource {
        let display = dto.phone ?? dto.url ?? ""
        let dialNumber = (dto.phone ?? "").filter(\.isNumber)
        return CrisisSupportResource(
            title: dto.name,
            message: dto.description,
            displayNumber: display,
            dialNumber: dialNumber
        )
    }
}
