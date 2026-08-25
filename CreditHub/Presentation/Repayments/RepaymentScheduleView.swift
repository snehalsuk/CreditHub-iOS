import SwiftUI

struct RepaymentScheduleView: View {
    let installments: [RepaymentInstallment]

    var body: some View {
        List(installments) { installment in
            HStack {
                VStack(alignment: .leading) {
                    Text(installment.dueDate, style: .date)
                    Text(statusLabel(installment.status)).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Text(CurrencyFormatter.string(from: installment.amountDue, currencyCode: installment.currency))
                    .fontWeight(.semibold)
            }
        }
        .navigationTitle("Repayment Schedule")
        .overlay {
            if installments.isEmpty {
                ContentUnavailableView("No Upcoming Payments", systemImage: "calendar.badge.checkmark")
            }
        }
    }

    private func statusLabel(_ status: RepaymentStatus) -> String {
        switch status {
        case .upcoming: return "Upcoming"
        case .due: return "Due"
        case .paid: return "Paid"
        case .overdue: return "Overdue"
        }
    }
}
