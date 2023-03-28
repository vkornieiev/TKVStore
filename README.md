# TKVStore

Transactional key-value store implementation is Swift, with example project.

## Description

### Key features

* Extendable interface
* Thread safe access
* Unit Tests covered
* Pure SwifUI Test App

### Supported commands

```
SET <key> <value> // store the value for key
GET <key> // return the current value for key
DELETE <key> // remove the entry for key
COUNT <value> // return the number of keys that have the given value
BEGIN // start a new transaction
COMMIT // complete the current transaction
ROLLBACK // revert to state prior to BEGIN call
```

## Screenshots

<img src="https://user-images.githubusercontent.com/13338518/228077215-e2eaa9f5-f36c-4907-b5cf-323889ad7464.png" width="350"> <img src="https://user-images.githubusercontent.com/13338518/228077217-4331f18c-6514-4901-bd10-0c6c4bb4bc37.png" width="350">

## License

[MIT](https://choosealicense.com/licenses/mit/)
