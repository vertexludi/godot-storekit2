# Godot StoreKit 2

This plugin provides an API to use the StoreKit 2 framework in Godot Engine, allowing you to implement in-app purchases and subscriptions for your iOS games.

>[!NOTE]
> This plugin is still in ongoing development so the API isn't stable and there might be bugs.

## Installation

1. Download the ZIP file of the latest release from the [releases page](https://github.com/vertexludi/godot-storekit2/releases) according to your Godot version.
2. Extract it on the `ios/plugins` folder in your project.
3. Enable the `Godot Storekit 2` plugin in the export preset under `Plugins`.

## Usage

In a script, create an object of type `GodotStoreKit2`. Use strings with the `ClassDB` singleton to avoid errors on other platforms since the class is only available on iOS:

```gdscript
var store_kit

func _ready() -> void:
	if ClassDB.class_exists("GodotStoreKit2"):
		store_kit = ClassDB.instantiate("GodotStoreKit2")
```

Then you can use the `store_kit` variable to access the plugin api.

Asynchronous methods return a `Signal` object you can use `await` to get the result more easily. E.g.:

```gdscript
var product_info = await store_kit.request_product_info("my_product_id")
print(product_info)
```

## API

### Methods

`request_product_info(product_id: String) -> Signal`

Requests information about a product. Emits the `product_info_received` signal when the information is available.

**Parameters:**

- `product_id`: The product ID as defined in App Store Connect or the StoreKit configuration file.

`purchase_product(product_id: String, quantity: int) -> Signal`

Initiates the purchase of a product. Emits the `transaction_state_changed` signal when the purchase is completed.

**Parameters:**

- `product_id`: The product ID as defined in App Store Connect or the StoreKit configuration file.
- `quantity`: The quantity of the product to purchase (for consumables).

`sync() -> Signal`

Synchronizes the app's transactions with the App Store. This usually does not need to be called, but it can be used in a "Restore purchases" button. Note that this will request the user to authenticate with Apple, so don't call it without user interaction.

Emits the `synchronized` signal when the synchronization is complete.

### Signals

`product_info_received(product_info: Dictionary)`

Emitted when product information is received after being requested.

**Parameters:**

- `product_info`: A dictionary containing the product information with the following keys:
  - `error: String`: An error message if the request failed, empty if successful. It will be the only key if there's an error.
  - `product_id: String`: The product ID.
  - `display_name: String`: The display name of the product (localized).
  - `description: String`: The description of the product (localized).
  - `is_purchased`: A boolean indicating if the product has been purchased (for non-consumables and subscriptions).
  - `currency_value: float`: The price of the product in the local currency. There may be imprecision.
  - `currency_code: String`: The ISO 4217 currency code (e.g. "USD") based on the user's' locale.
  - `currency_symbol: String`: The currency symbol (e.g. "$") based on the user's locale.
  - `localized_price: String`: The price formatted as a localized string (e.g. "$0.99").
  
`transaction_state_changed(transaction: Dictionary)`

Emitted when a transaction state changes, such as when a purchase is completed. This may also be emitted at the start of the application for any transactions that happen externally, such as refunds or purchases in another device.

**Parameters:**

- `transaction`: A dictionary containing the transaction information with the following keys:
  - `error: String`: An error message if the transaction failed, empty if successful. It will be the only key if there's an error.
  - `product_id: String`: The product ID.
  - `transaction_state: TransactionState`: The state of the transaction as an enum value. See the `TransactionState` enum for possible values.

### Enums

`TransactionState`

An enum representing the state of a transaction. These are the possible values:

- `FAILED`: The transaction failed to complete.
- `REFUNDED`: The user refunded the product or subscription.
- `PENDING`: The transation has not yet been completed.
- `PURCHASED`: The product or subscription was succesfully purchased.
- `RESTORED`: The product or subscription was restored.
- `EXPIRED`: The subscription has expired.
- `CANCELLED`: The transaction was cancelled by the user.
