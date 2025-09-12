import Foundation

@objcMembers
public class GodotStoreKit2Proxy: NSObject {

	private var initialized = false;

	public func test() -> Bool {
		return true;
	}

	public func initialize() -> Void {
		initialized = true;
	}

	public func isInitialized() -> Bool {
		return initialized;
	}

	public func isProductAvailable(productId: NSString) -> Bool {
		return false;
	}

	public func isProductPurchased(productId: NSString) -> Bool {
		return false;
	}

	public func getProductPrices(productId: NSString) -> PriceInfo {
		return PriceInfo();
	}

	public func purchaseProduct(productId: NSString, quantity: Int, callback: (TransactionData) -> Void) -> Void {
		callback(TransactionData());
	}

	public func restorePurchases() -> Void {
	}
}

public enum TransactionState: Int {
	case Failed = 0
	case Refunded = 1
	case Purchasing = 2
	case Deferred = 3
	case Purchased = 4
	case Restored = 5
};

@objcMembers
public class PriceInfo: NSObject {
	public var currencyValue: Float = 0.0
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
	public var transactionState = TransactionState.Failed
	public var error = ""
}
