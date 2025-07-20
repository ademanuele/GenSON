# GenSON

**GenSON** is a Swift library that enables you to easily generate representative **JSON data** from any Swift type that conforms to `Decodable`. It can be used for:

- Mocking API responses
- Writing [Socialised unit tests](https://martinfowler.com/bliki/UnitTest.html) 
- Auto-generating sample data for UI/Snapshot testing
- Debugging Codable models

---

## ✨ Features

- ✅ Automatically generates JSON from any `Decodable` type  
- ✅ Supports nested models, optionals, arrays, dictionaries, etc.
- ✅ Configurable generated JSON values
- ✅ Zero setup required

---

## 🔧 Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/ademanuele/GenSON.git", from: "0.0.1")
]
```

Then import it in your code:

```swift
import GenSON
```

## 🚀 Usage

Generate JSON for a Type

```swift
struct User: Decodable {
    let id: String
    let name: String
    let isActive: Bool
}

let json: String = try User.generate()
print(json)
```

Output:

```json
{
  "id" : "1uTih9ZU1yJcIEFsVFHSoYelf32NPHssVR8eqLUGk",
  "isActive" : true,
  "name" : "qiMkyHIthSfxkdx2TbICDVq5KuxvBavZwkqrYpbXUXTIxIOlGXTrIyiZgpraF"
}
```

Optionally provide JSON generation options

```swift
let json: String = try User.generate(options: .init(stringLength: 3...5))
print(json)
```

Output:

```json
{
  "id" : "yhGf",
  "isActive" : true,
  "name" : "Ldc"
}
```

## 🧠 How It Works

**GenSON** works by passing the given `Decodable` model through a custom Foundation `Decoder` which navigates the object structure and generates dummy values for every property of the model.

## 🔒 Known Limitations & Issues

- Decoding of `enum` types is not supported yet.
- Providing your own values for a given object property is not supported yet.

## 🤝 Contributing

Contributions are very welcome!

- Fork the repo
- Create a new branch (git checkout -b feature/my-feature)
- Make your changes and commit (git commit -am 'Add new feature')
- Push to GitHub (git push origin feature/my-feature)
- Submit a Pull Request 🎉


Made with ❤️ in Swift.
