import Foundation
import Observation

@Observable
final class CardsViewModel {
    var cards: [Card] = []
    var isLoading = false
    var errorMessage: UserFacingError?
    /// Revealed PAN/CVV, keyed by card id. Cleared whenever the user taps "Hide" — never persisted.
    var revealedDetails: [String: CardDetails] = [:]

    private let fetchCreditAccountsUseCase: FetchCreditAccountsUseCase
    private let fetchCardsUseCase: FetchCardsUseCase
    private let setCardStatusUseCase: SetCardStatusUseCase
    private let updateCardSpendingLimitUseCase: UpdateCardSpendingLimitUseCase
    private let revealCardDetailsUseCase: RevealCardDetailsUseCase

    init(fetchCreditAccountsUseCase: FetchCreditAccountsUseCase, fetchCardsUseCase: FetchCardsUseCase, setCardStatusUseCase: SetCardStatusUseCase, updateCardSpendingLimitUseCase: UpdateCardSpendingLimitUseCase, revealCardDetailsUseCase: RevealCardDetailsUseCase) {
        self.fetchCreditAccountsUseCase = fetchCreditAccountsUseCase
        self.fetchCardsUseCase = fetchCardsUseCase
        self.setCardStatusUseCase = setCardStatusUseCase
        self.updateCardSpendingLimitUseCase = updateCardSpendingLimitUseCase
        self.revealCardDetailsUseCase = revealCardDetailsUseCase
    }

    @MainActor
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let accounts = try await fetchCreditAccountsUseCase()
            guard let primaryAccountId = accounts.first?.id else {
                cards = []
                return
            }
            cards = try await fetchCardsUseCase(accountId: primaryAccountId)
        } catch {
            errorMessage = ErrorPresenter.present(error, fallbackMessage: String(localized: "cards.error.loadFallback"))
        }
    }

    @MainActor
    func toggleFreeze(_ card: Card) async {
        let newStatus: CardStatus = card.status == .frozen ? .active : .frozen
        do {
            apply(try await setCardStatusUseCase(cardId: card.id, status: newStatus))
        } catch {
            errorMessage = ErrorPresenter.present(error, fallbackMessage: String(localized: "cards.error.updateFallback"))
        }
    }

    @MainActor
    func updateSpendingLimit(_ card: Card, to limit: Decimal) async {
        do {
            apply(try await updateCardSpendingLimitUseCase(cardId: card.id, limit: limit))
        } catch {
            errorMessage = ErrorPresenter.present(error, fallbackMessage: String(localized: "cards.error.updateFallback"))
        }
    }

    @MainActor
    func revealDetails(for card: Card) async {
        do {
            revealedDetails[card.id] = try await revealCardDetailsUseCase(cardId: card.id)
        } catch {
            errorMessage = ErrorPresenter.present(error, fallbackMessage: String(localized: "cards.error.revealFallback"))
        }
    }

    func hideDetails(for card: Card) {
        revealedDetails[card.id] = nil
    }

    private func apply(_ updated: Card) {
        if let index = cards.firstIndex(where: { $0.id == updated.id }) {
            cards[index] = updated
        }
    }
}
