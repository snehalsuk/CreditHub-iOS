import XCTest
@testable import CreditHub

@MainActor
final class CardsViewModelTests: XCTestCase {
    private func makeCard(status: CardStatus = .active) -> Card {
        Card(id: "card_1", accountId: "acct_1", lastFourDigits: "4821", network: .visa, cardType: .physical, status: status, spendingLimit: 1000, currency: "USD")
    }

    func test_load_populatesCardsForPrimaryAccount() async {
        let creditRepository = FakeCreditRepository()
        creditRepository.accountsResult = .success([
            CreditAccount(id: "acct_1", productName: "Test", accountNumberMasked: "1234", creditLimit: 1000, availableCredit: 500, currentBalance: 500, currency: "USD", status: .active)
        ])
        let cardRepository = FakeCardRepository()
        cardRepository.cardsResult = .success([makeCard()])

        let viewModel = CardsViewModel(
            fetchCreditAccountsUseCase: FetchCreditAccountsUseCase(creditRepository: creditRepository),
            fetchCardsUseCase: FetchCardsUseCase(cardRepository: cardRepository),
            setCardStatusUseCase: SetCardStatusUseCase(cardRepository: cardRepository),
            updateCardSpendingLimitUseCase: UpdateCardSpendingLimitUseCase(cardRepository: cardRepository),
            revealCardDetailsUseCase: RevealCardDetailsUseCase(cardRepository: cardRepository)
        )

        await viewModel.load()

        XCTAssertEqual(viewModel.cards.count, 1)
        XCTAssertNil(viewModel.errorMessage)
    }

    func test_toggleFreeze_updatesCardInPlace() async {
        let creditRepository = FakeCreditRepository()
        let cardRepository = FakeCardRepository()
        cardRepository.setStatusResult = .success(makeCard(status: .frozen))

        let viewModel = CardsViewModel(
            fetchCreditAccountsUseCase: FetchCreditAccountsUseCase(creditRepository: creditRepository),
            fetchCardsUseCase: FetchCardsUseCase(cardRepository: cardRepository),
            setCardStatusUseCase: SetCardStatusUseCase(cardRepository: cardRepository),
            updateCardSpendingLimitUseCase: UpdateCardSpendingLimitUseCase(cardRepository: cardRepository),
            revealCardDetailsUseCase: RevealCardDetailsUseCase(cardRepository: cardRepository)
        )
        viewModel.cards = [makeCard(status: .active)]

        await viewModel.toggleFreeze(makeCard(status: .active))

        XCTAssertEqual(viewModel.cards.first?.status, .frozen)
    }

    func test_revealDetails_storesDetailsByCardId() async {
        let creditRepository = FakeCreditRepository()
        let cardRepository = FakeCardRepository()
        let details = CardDetails(cardNumber: "4111 1111 1111 4821", expiryMonth: 9, expiryYear: 2028, cvv: "123")
        cardRepository.revealResult = .success(details)

        let viewModel = CardsViewModel(
            fetchCreditAccountsUseCase: FetchCreditAccountsUseCase(creditRepository: creditRepository),
            fetchCardsUseCase: FetchCardsUseCase(cardRepository: cardRepository),
            setCardStatusUseCase: SetCardStatusUseCase(cardRepository: cardRepository),
            updateCardSpendingLimitUseCase: UpdateCardSpendingLimitUseCase(cardRepository: cardRepository),
            revealCardDetailsUseCase: RevealCardDetailsUseCase(cardRepository: cardRepository)
        )

        await viewModel.revealDetails(for: makeCard())

        XCTAssertEqual(viewModel.revealedDetails["card_1"], details)
    }
}
