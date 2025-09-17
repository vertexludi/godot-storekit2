import Foundation
import StoreKit

@objcMembers
public final class GodotStoreKit2Proxy: NSObject,
@unchecked Sendable
{
	private var updates: Task<Void, Never>? = nil
	private var unfinished: Task<Void, Never>? = nil
	private var transactionCallback: (TransactionData) -> ()

	public init(transactionCallback: @Sendable @escaping (TransactionData) -> ()) {
		self.transactionCallback = transactionCallback
		super.init()
		updates = newTransactionListenerTask(transactions: Transaction.updates)
		unfinished = newTransactionListenerTask(transactions: Transaction.unfinished)
	}

	deinit {
		// Cancel the update handling task when you deinitialize the class.
		updates?.cancel()
	}

	private func newTransactionListenerTask(transactions: Transaction.Transactions) -> Task<Void, Never> {
		Task(priority: .background) { @Sendable [weak self] in
			for await verificationResult in transactions {
				self?.handle(updatedTransaction: verificationResult)
			}
		}
	}

	private func handle(updatedTransaction verificationResult: VerificationResult<Transaction>) {
		guard case .verified(let transaction) = verificationResult else {
			// Ignore unverified transactions.
			return
		}

		let transData = TransactionData()
		transData.productId = transaction.productID

		if let revocationDate = transaction.revocationDate {
			// Remove access to the product identified by transaction.productID.
			// Transaction.revocationReason provides details about
			// the revoked transaction.
			transData.transactionState = TransactionState.Refunded.rawValue
			transData.revocationDate = revocationDate
		} else if let expirationDate = transaction.expirationDate,
				  expirationDate < Date() {
			// Do nothing, this subscription is expired.
			return
		} else if transaction.isUpgraded {
			// Do nothing, there is an active transaction
			// for a higher level of service.
			return
		} else {
			// Provide access to the product identified by
			// transaction.productID.
			transData.transactionState = TransactionState.Purchased.rawValue
			transData.purchaseDate = transaction.purchaseDate
		}

		self.transactionCallback(transData)
	}

	public func test() -> Bool {
		return true;
	}

	public func isProductAvailable(productId: NSString) -> Bool {
		return false;
	}

	public func isProductPurchased(productId: NSString) -> Bool {
		return false;
	}

	private func priceInfoFromProduct(product: Product) -> PriceInfo {
		let info = PriceInfo()
		info.currencyValue = product.price as NSDecimalNumber
		info.localizedDisplay = String(data: product.displayPrice.data(using: .utf8)!, encoding: .utf8)!
		info.currencyCode = product.priceFormatStyle.currencyCode

		// Get the currency symbol.
		let currencyCode = product.priceFormatStyle.currencyCode
		let locale = product.priceFormatStyle.locale
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencyCode = currencyCode
		formatter.locale = locale
		let currencySymbol = formatter.currencySymbol
		info.currencySymbol = currencySymbol!

		return info
	}

	public func getProductInfo(productId: NSString) async throws -> ProductInfo {
		let productIdentifiers: Set<String> = [productId as String]
		let appProducts = try await Product.products(for: productIdentifiers)
		guard let product = appProducts.first else {
			throw NSError(domain: "GodotStoreKit2Proxy", code: 1, userInfo: [NSLocalizedDescriptionKey: "Product not found"])
		}

		let info = ProductInfo()
		info.productId = product.id
		info.displayName = product.displayName
		info.productDescription = product.description
		info.priceInfo = priceInfoFromProduct(product: product)

		if #available(iOS 18.4, *) {
			for await verificationResult in product.currentEntitlements {
				switch verificationResult {
				case .verified(_):
					info.isPurchased = true
				default:
					info.isPurchased = false
				}
			}
		} else {
			let entitlement = await product.currentEntitlement
			switch entitlement {
			case .verified(_):
				info.isPurchased = true
			default:
				info.isPurchased = false
			}
		}

		return info
	}

	public func getProductPrice(productId: NSString) async throws -> PriceInfo {
		let productIdentifiers: Set<String> = [productId as String]
		let appProducts = try await Product.products(for: productIdentifiers)
		guard let product = appProducts.first else {
			throw NSError(domain: "GodotStoreKit2Proxy", code: 1, userInfo: [NSLocalizedDescriptionKey: "Product not found"])
		}

		return priceInfoFromProduct(product: product)
	}

	public func purchaseProduct(productId: String, quantity: Int) async throws -> TransactionData {
		let productIdentifiers: Set<String> = [productId]
		let appProducts = try await Product.products(for: productIdentifiers)
		guard let product = appProducts.first else {
			throw NSError(domain: "GodotStoreKit2Proxy", code: 1, userInfo: [NSLocalizedDescriptionKey: "Product not found"])
		}

		let result = try await product.purchase(options: [
			.quantity(quantity)
		])

		let data = TransactionData()
		data.productId = productId
		switch result{
		case .pending:
			data.transactionState = TransactionState.Pending.rawValue
		case .userCancelled:
			data.transactionState = TransactionState.Canceled.rawValue
		case .success(let verificationResult):
			switch verificationResult {
			case .verified(let transaction):
				await transaction.finish()
				data.transactionState = TransactionState.Purchased.rawValue
			case .unverified(let transaction, let verificationError):
				await transaction.finish()
				data.transactionState = TransactionState.Failed.rawValue
				data.error = verificationError.errorDescription!
			}
		@unknown default:
			data.error = "unknown"
			data.transactionState = TransactionState.Failed.rawValue
		}
		return data
	}

	public func restorePurchases() async throws -> Void {
		try await AppStore.sync()
	}
}

// Keep in sync wit C++ enum.
public enum TransactionState: Int {
	case Failed = 0
	case Refunded = 1
	case Pending = 2
	case Deferred = 3
	case Purchased = 4
	case Restored = 5
	case Expired = 6
	case Canceled = 7
};

@objcMembers
public class PriceInfo: NSObject {
	public var currencyValue: NSDecimalNumber = 0.0
	public var currencyCode = ""
	public var currencySymbol = "$"
	public var localizedDisplay = ""
}

@objcMembers
public class InitializationData: NSObject {
	var initialized: Bool = false;
	public var error = ""
}

@objcMembers
public class TransactionData: NSObject {
	public var productId = ""
	public var transactionState = TransactionState.Failed.rawValue
	public var error = ""
	public var purchaseDate: Date? = nil
	public var revocationDate: Date? = nil
}

@objcMembers
public class ProductInfo: NSObject {
	public var productId = ""
	public var displayName = ""
	public var productDescription = ""
	public var isPurchased = false
	public var priceInfo = PriceInfo()
}
