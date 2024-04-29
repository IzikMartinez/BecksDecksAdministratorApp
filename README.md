# Beck's Decks Admin
This is a simple application intended for mobile and desktop use that enables my client to perform simple CRUD operations on the products stocked on his web store.

To use, you will need a supabase project to act as the backend, and will need to supply your own authentication key with appropriate RLS privileges. 

## Functionality
- Add products
- Remove products
- Edit products
These operations involve adding/altering prices, descriptions, product names, and product images to an SQL table titled "PRODUCTS"
The file management of the app expects all product images to be in a bucket titled "product_images"

## Notes on iOS
This application is currently not tested on, or intended for use with iOS. Any functionality listed above may not work