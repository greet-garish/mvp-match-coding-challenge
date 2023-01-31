# MVP Match chalenge

Chalenge can be found [here](https://mvpmatch.notion.site/Backend-1-9a5476e6cb7848ec9f620ce8a64c0d06)

Install with `bundle`

Run specs with `rspec`

Boot server with `rails s`

Some requests have been recorded in postman and can be imported by importing the file `Vending Machine.postman_collection.json`

Future work:
- Sessions are currently stored on an hash and need to be moved into a the database in order to share sessions between server instances
- Producst index endpoint should be paginated
- Add transaltions
- Add a linter like rubocop
- Use the same database as would be used in prod, for example postgres instead of sqlite
- Passwords should have a stronger validation
- Products could be db constrained to sellers


