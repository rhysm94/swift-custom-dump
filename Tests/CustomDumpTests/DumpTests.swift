import CustomDump
import XCTest

#if canImport(CoreGraphics)
  import CoreGraphics
#endif

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

#if canImport(SwiftUI)
  import SwiftUI
#endif

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
final class DumpTests: XCTestCase {
  func testAnyType() {
    XCTAssertNoDifference(
      String(customDumping: Foo.Bar.self),
      """
      Foo.Bar.self
      """
    )

    struct Feature {
      struct State {}
    }
    XCTAssertNoDifference(
      String(customDumping: Feature.State.self),
      """
      DumpTests.Feature.State.self
      """
    )

    XCTAssertNoDifference(
      String(customDumping: (x: Double, y: Double).self),
      """
      (x: Double, y: Double).self
      """
    )

    XCTAssertNoDifference(
      String(customDumping: Double?.self),
      """
      Double?.self
      """
    )

    XCTAssertNoDifference(
      String(customDumping: [Int].self),
      """
      [Int].self
      """
    )

    XCTAssertNoDifference(
      String(customDumping: [String: Int].self),
      """
      [String: Int].self
      """
    )

    XCTAssertNoDifference(
      String(customDumping: [[Double: Double?]].self),
      """
      [[Double: Double?]].self
      """
    )

    XCTAssertNoDifference(
      String(customDumping: [[Double: Double]?].self),
      """
      [[Double: Double]?].self
      """
    )

    XCTAssertNoDifference(
      String(customDumping: [[Double: [Double]]]?.self),
      """
      [[Double: [Double]]]?.self
      """
    )

    XCTAssertNoDifference(
      String(customDumping: [[[Double: Double]]]?.self),
      """
      [[[Double: Double]]]?.self
      """
    )

    XCTAssertNoDifference(
      String(customDumping: [Double: [Double?]].self),
      """
      [Double: [Double?]].self
      """
    )

    XCTAssertNoDifference(
      String(customDumping: [Double: [Double]?].self),
      """
      [Double: [Double]?].self
      """
    )
  }

  func testClass() {
    let user = UserClass(
      id: 42,
      name: "Blob"
    )

    var dump = ""
    customDump(user, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      UserClass(
        id: 42,
        name: "Blob"
      )
      """
    )

    dump = ""
    customDump(user, to: &dump, maxDepth: 0)
    XCTAssertNoDifference(
      dump,
      """
      UserClass(…)
      """
    )

    let foo = RecursiveFoo()
    foo.foo = foo

    dump = ""
    customDump(foo, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      RecursiveFoo(
        foo: RecursiveFoo(↩︎)
      )
      """
    )
  }

  func testCollection() {
    let users = [
      User(
        id: 1,
        name: "Blob"
      ),
      User(
        id: 2,
        name: "Blob, Jr."
      ),
      User(
        id: 3,
        name: "Blob, Sr."
      ),
    ]

    var dump = ""
    customDump(users, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      [
        [0]: User(
          id: 1,
          name: "Blob"
        ),
        [1]: User(
          id: 2,
          name: "Blob, Jr."
        ),
        [2]: User(
          id: 3,
          name: "Blob, Sr."
        )
      ]
      """
    )

    dump = ""
    customDump(users, to: &dump, maxDepth: 1)
    XCTAssertNoDifference(
      dump,
      """
      [
        [0]: User(…),
        [1]: User(…),
        [2]: User(…)
      ]
      """
    )

    dump = ""
    customDump(users, to: &dump, maxDepth: 0)
    XCTAssertNoDifference(
      dump,
      """
      […]
      """
    )
  }

  func testDictionary() {
    var dump = ""
    customDump(
      [
        1: User(
          id: 1,
          name: "Blob"
        ),
        2: User(
          id: 2,
          name: "Blob, Jr."
        ),
      ],
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      [
        1: User(
          id: 1,
          name: "Blob"
        ),
        2: User(
          id: 2,
          name: "Blob, Jr."
        )
      ]
      """
    )

    dump = ""
    customDump(
      [
        ID(rawValue: "deadbeef"): User(
          id: 1,
          name: "Blob"
        ),
        ID(rawValue: "beefdead"): User(
          id: 2,
          name: "Blob, Jr."
        ),
      ],
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      [
        ID(rawValue: "beefdead"): User(
          id: 2,
          name: "Blob, Jr."
        ),
        ID(rawValue: "deadbeef"): User(
          id: 1,
          name: "Blob"
        )
      ]
      """
    )

    dump = ""
    customDump(
      OrderedDictionary(
        pairs: [
          2: User(
            id: 2,
            name: "Blob, Jr."
          ),
          1: User(
            id: 1,
            name: "Blob"
          ),
        ] as KeyValuePairs),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      [
        2: User(
          id: 2,
          name: "Blob, Jr."
        ),
        1: User(
          id: 1,
          name: "Blob"
        )
      ]
      """
    )
  }

  func testDictionary_Nested() {
    struct NestedDictionary {
      let content: [String: Int]
    }

    XCTAssertNoDifference(
      """
      DumpTests.NestedDictionary(
        content: [
          "a": 5,
          "b": 9,
          "c": 1,
          "d": -3,
          "e": 12
        ]
      )
      """,
      String(
        customDumping: NestedDictionary(
          content: ["a": 5, "b": 9, "c": 1, "d": -3, "e": 12]
        )
      )
    )
  }

  func testEnum() {
    var dump = ""
    customDump(Enum.foo, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      Enum.foo
      """
    )

    dump = ""
    customDump(Enum.bar(42), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      Enum.bar(42)
      """
    )

    dump = ""
    customDump(Enum.fu(bar: 42), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      Enum.fu(bar: 42)
      """
    )

    dump = ""
    customDump(Enum.baz(fizz: 0.9, buzz: "2"), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      Enum.baz(
        fizz: 0.9,
        buzz: "2"
      )
      """
    )

    dump = ""
    customDump(Enum.fizz(0.9, buzz: "2"), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      Enum.fizz(
        0.9,
        buzz: "2"
      )
      """
    )

    dump = ""
    customDump(Nested.nest(.fizz(0.9, buzz: "2")), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      Nested.nest(
        .fizz(
          0.9,
          buzz: "2"
        )
      )
      """
    )
  }

  func testOptional() {
    var dump = ""
    customDump(User?(.init(id: 42, name: "Blob")), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      User(
        id: 42,
        name: "Blob"
      )
      """
    )

    dump = ""
    customDump(User?(nil), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      nil
      """
    )
  }

  func testSet() {
    var dump = ""
    customDump(Set([1, 2, 3]), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      Set([
        1,
        2,
        3
      ])
      """
    )
  }

  func testSingleValue() {
    var dump = ""
    customDump(1, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      1
      """
    )

    dump = ""
    customDump(true, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      true
      """
    )
  }

  func testStruct() {
    let user = User(
      id: 42,
      name: "Blob"
    )

    var dump = ""
    customDump(user, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      User(
        id: 42,
        name: "Blob"
      )
      """
    )

    dump = ""
    customDump(user, to: &dump, maxDepth: 0)
    XCTAssertNoDifference(
      dump,
      """
      User(…)
      """
    )

    let pair = Pair(
      driver: User(
        id: 1,
        name: "Blob"
      ),
      passenger: User(
        id: 2,
        name: "Blob, Jr."
      )
    )

    dump = ""
    customDump(pair, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      Pair(
        driver: User(
          id: 1,
          name: "Blob"
        ),
        passenger: User(
          id: 2,
          name: "Blob, Jr."
        )
      )
      """
    )

    dump = ""
    customDump(pair, to: &dump, maxDepth: 1)
    XCTAssertNoDifference(
      dump,
      """
      Pair(
        driver: User(…),
        passenger: User(…)
      )
      """
    )
  }

  func testTuple() {
    var dump = ""
    customDump((1, 2), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      (
        1,
        2
      )
      """
    )

    dump = ""
    customDump((x: 1, y: 2, ()), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      (
        x: 1,
        y: 2,
        ()
      )
      """
    )
  }

  func testString() {
    var dump = ""
    customDump("Hello!", to: &dump)
    XCTAssertNoDifference(
      dump,
      #""Hello!""#
    )

    dump = ""
    customDump(#"Hello, "world!""#, to: &dump)
    XCTAssertNoDifference(
      dump,
      ##"#"Hello, "world!""#"##
    )

    dump = ""
    customDump(####"This has a "### in it"####, to: &dump)
    XCTAssertNoDifference(
      dump,
      #####"####"This has a "### in it"####"#####
    )

    dump = ""
    customDump("This has a \\ in it", to: &dump)
    XCTAssertNoDifference(
      dump,
      ##"#"This has a \ in it"#"##
    )

    dump = ""
    customDump("This has no special characters in it", to: &dump)
    XCTAssertNoDifference(
      dump,
      "\"This has no special characters in it\""
    )

    dump = ""
    customDump("This has a \t in it", to: &dump)
    XCTAssertNoDifference(
      dump,
      "\"This has a \\t in it\""
    )
  }

  func testMultilineString() {
    var dump = ""
    customDump("Hello,\nWorld!", to: &dump)
    XCTAssertNoDifference(
      dump,
      #"""
      """
      Hello,
      World!
      """
      """#
    )

    dump = ""
    customDump("Hello,\nWorld!"[...], to: &dump)
    XCTAssertNoDifference(
      dump,
      #"""
      """
      Hello,
      World!
      """
      """#
    )

    dump = ""
    customDump(
      Email(
        subject: "RE: Upcoming Event",
        body: """
          To whom it may concern,

          Look forward to it!

          Yours,
          Blob
          """
      ),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      Email(
        subject: "RE: Upcoming Event",
        body: \"\"\"
          To whom it may concern,
          \n\
          Look forward to it!
          \n\
          Yours,
          Blob
          \"\"\"
      )
      """
    )

    dump = ""
    customDump(
      ##"""
      print(
        #"""
        Hello, world!
        """#
      )
      """##,
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      ###"""
      ##"""
      print(
        #"""
        Hello, world!
        """#
      )
      """##
      """###
    )
  }

  func testAnyHashable() {
    var dump = ""
    customDump(AnyHashable(42), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      42
      """
    )

    dump = ""
    customDump(
      [
        AnyHashable(1): User(id: 1, name: "Blob"),
        AnyHashable("Blob, Jr."): User(id: 2, name: "Blob, Jr."),
      ],
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      [
        "Blob, Jr.": User(
          id: 2,
          name: "Blob, Jr."
        ),
        1: User(
          id: 1,
          name: "Blob"
        )
      ]
      """
    )
  }

  func testKeyPath() {
    var dump = ""

    // NB: This code path marks the expectation of relying on SE-0369's
    // `AnyKeyPath.debugDescription`, which currently has a crash related to dynamic member lookup:
    // https://github.com/apple/swift/issues/64865
    //
    // #if swift(>=5.8)
    //   if #available(macOS 13.3, iOS 16.4, watchOS 9.4, tvOS 16.4, *) {
    //     dump = ""
    //     customDump(\UserClass.name, to: &dump)
    //     XCTAssertNoDifference(
    //       dump,
    //       #"""
    //       \UserClass.name
    //       """#
    //     )
    //
    //     dump = ""
    //     customDump(\Pair.driver.name, to: &dump)
    //     XCTAssertNoDifference(
    //       dump,
    //       #"""
    //       \Pair.driver.name
    //       """#
    //     )
    //
    //     dump = ""
    //     customDump(\User.name.count, to: &dump)
    //     XCTAssertNoDifference(
    //       dump,
    //       #"""
    //       \User.name.count
    //       """#
    //     )
    //
    //     dump = ""
    //     customDump(\(x: Double, y: Double).x, to: &dump)
    //     XCTAssertNoDifference(
    //       dump,
    //       #"""
    //       \(x: Double, y: Double).x
    //       """#
    //     )
    //
    //     dump = ""
    //     customDump(\Item.$isInStock, to: &dump)
    //     XCTAssertNoDifference(
    //       dump,
    //       #"""
    //       \Item.$isInStock
    //       """#
    //     )
    //
    //     // NB: This currently crashes when using Swift's `debugDescription`:
    //     // https://github.com/apple/swift/issues/64865
    //     dump = ""
    //     customDump(\Wrapped<String>.count, to: &dump)
    //     XCTAssertNoDifference(
    //       dump,
    //       #"""
    //       \Wrapped.count
    //       """#
    //     )
    //     return
    //   }
    // #endif
    #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
      // Run twice to exercise cached lookup
      for _ in 1...2 {
        dump = ""
        customDump(\UserClass.name, to: &dump)
        XCTAssertNoDifference(
          dump,
          #"""
          \UserClass.name
          """#
        )

        dump = ""
        customDump(\Pair.driver.name, to: &dump)
        XCTAssertNoDifference(
          dump,
          #"""
          \Pair.driver.name
          """#
        )

        dump = ""
        customDump(\User.name.count, to: &dump)
        XCTAssertNoDifference(
          dump,
          #"""
          KeyPath<User, Int>
          """#
        )

        dump = ""
        customDump(\(x: Double, y: Double).x, to: &dump)
        XCTAssertNoDifference(
          dump,
          #"""
          WritableKeyPath<(x: Double, y: Double), Double>
          """#
        )

        dump = ""
        customDump(\Item.$isInStock, to: &dump)
        XCTAssertNoDifference(
          dump,
          #"""
          KeyPath<Item, Wrapped<Bool>>
          """#
        )

        dump = ""
        customDump(\Wrapped<String>.count, to: &dump)
        XCTAssertNoDifference(
          dump,
          #"""
          KeyPath<Wrapped<String>, Int>
          """#
        )
      }
    #else
      dump = ""
      customDump(\UserClass.name, to: &dump)
      XCTAssertNoDifference(
        dump,
        #"""
        KeyPath<UserClass, String>
        """#
      )

      dump = ""
      customDump(\Pair.driver.name, to: &dump)
      XCTAssertNoDifference(
        dump,
        #"""
        KeyPath<Pair, String>
        """#
      )

      dump = ""
      customDump(\User.name.count, to: &dump)
      XCTAssertNoDifference(
        dump,
        #"""
        KeyPath<User, Int>
        """#
      )

      dump = ""
      customDump(\(x: Double, y: Double).x, to: &dump)
      XCTAssertNoDifference(
        dump,
        #"""
        WritableKeyPath<(x: Double, y: Double), Double>
        """#
      )

      dump = ""
      customDump(\Item.$isInStock, to: &dump)
      XCTAssertNoDifference(
        dump,
        #"""
        KeyPath<Item, Wrapped<Bool>>
        """#
      )

      dump = ""
      customDump(\Wrapped<String>.count, to: &dump)
      XCTAssertNoDifference(
        dump,
        #"""
        KeyPath<Wrapped<String>, Int>
        """#
      )
    #endif
  }

  func testNamespacedTypes() {
    var dump = ""
    customDump(
      Namespaced.Class(x: 0),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      Namespaced.Class(x: 0)
      """
    )

    dump = ""
    customDump(
      Namespaced.Enum.x(0),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      Namespaced.Enum.x(0)
      """
    )

    dump = ""
    customDump(
      Namespaced.Struct(x: 0),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      Namespaced.Struct(x: 0)
      """
    )
  }

  func testGenerics() {
    var dump = ""
    customDump(
      Result<Result<Int, Error>, Error>.success(.success(42)),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      Result.success(
        .success(42)
      )
      """
    )
  }

  func testUnknownContexts() {
    struct Inline {}

    var dump = ""
    customDump(
      Inline.self,
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      DumpTests.Inline.self
      """
    )

    dump = ""
    customDump(
      Inline(),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      DumpTests.Inline()
      """
    )
  }

  func testCustomMirror() {
    var dump = ""
    customDump(Button(), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      Button.cancel(
        action: nil,
        label: "Cancel"
      )
      """
    )

    dump = ""
    customDump(
      LoginState(
        email: "blob@pointfree.co",
        password: "bl0bisawesome!",
        token: "secret"
      ),
      to: &dump
    )
    XCTAssertNoDifference(
      dump,
      """
      LoginState(
        email: "blob@pointfree.co",
        password: <redacted>
      )
      """
    )
  }

  func testCustomOverride() {
    var dump = ""
    customDump(Wrapper(rawValue: 42), to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      42
      """
    )
  }

  func testStandardLibrary() {
    var dump = ""
    customDump("©" as Character, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      "©"
      """
    )

    dump = ""
    customDump("Blob" as StaticString, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      "Blob"
      """
    )

    dump = ""
    customDump("©" as UnicodeScalar, to: &dump)
    XCTAssertNoDifference(
      dump,
      """
      "©"
      """
    )
  }

  func testSuperclass() {
    var dump = ""
    class Human {
      let name = "John"
      let email = "john@me.com"
      let age = 97
    }

    class Doctor: Human {
      let field = "Podiatry"
    }

    customDump(Doctor(), to: &dump)

    XCTAssertNoDifference(
      dump,
      """
      DumpTests.Doctor(
        name: "John",
        email: "john@me.com",
        age: 97,
        field: "Podiatry"
      )
      """
    )
  }

  func testLayersOfInheritance() {
    var dump = ""
    class Human {
      let name = "John"
      let email = "john@me.com"
      let age = 97
    }

    class Doctor: Human {
      let field = "Podiatry"
    }

    class Surgeon: Doctor {
      let skillLevel = "Expert"
    }

    customDump(Surgeon(), to: &dump)

    XCTAssertNoDifference(
      dump,
      """
      DumpTests.Surgeon(
        name: "John",
        email: "john@me.com",
        age: 97,
        field: "Podiatry",
        skillLevel: "Expert"
      )
      """
    )
  }

  func testRecursion() {
    class Human {
      let name: String

      init(name: String) {
        self.name = name
      }
    }

    class Child: Human {
      weak var parent: Parent?
    }

    class Parent: Human {
      let children: [Human]

      init(name: String, children: [Child]) {
        self.children = children
        super.init(name: name)

        children.forEach {
          $0.parent = self
        }
      }
    }

    let subject = Parent(
      name: "Arthur",
      children: [
        Child(name: "Virginia"),
        Child(name: "Ronald"),
        Child(name: "Fred"),
        Child(name: "George"),
        Child(name: "Percy"),
        Child(name: "Charles"),
      ])

    var dump = ""
    customDump(subject, to: &dump)

    XCTAssertNoDifference(
      dump,
      """
      DumpTests.Parent(
        name: "Arthur",
        children: [
          [0]: DumpTests.Child(
            name: "Virginia",
            parent: DumpTests.Parent(↩︎)
          ),
          [1]: DumpTests.Child#2(
            name: "Ronald",
            parent: DumpTests.Parent(↩︎)
          ),
          [2]: DumpTests.Child#3(
            name: "Fred",
            parent: DumpTests.Parent(↩︎)
          ),
          [3]: DumpTests.Child#4(
            name: "George",
            parent: DumpTests.Parent(↩︎)
          ),
          [4]: DumpTests.Child#5(
            name: "Percy",
            parent: DumpTests.Parent(↩︎)
          ),
          [5]: DumpTests.Child#6(
            name: "Charles",
            parent: DumpTests.Parent(↩︎)
          )
        ]
      )
      """
    )
  }

  func testRepetition() {
    class Human {
      let name = "John"
    }

    class User: Human {
      let email = "john@me.com"
      let age = 97

      let human: Human

      init(human: Human) {
        self.human = human
      }
    }

    let human = Human()
    let human2 = Human()

    let user = User(human: human)
    let user2 = User(human: human2)

    var dump = ""
    customDump(
      [
        human,
        human,
        human,
        human2,
        human2,
        human2,
        user,
        user,
        user,
        user2,
        user2,
        user2,
      ], to: &dump)

    XCTAssertNoDifference(
      dump,
      """
      [
        [0]: DumpTests.Human(name: "John"),
        [1]: DumpTests.Human(↩︎),
        [2]: DumpTests.Human(↩︎),
        [3]: DumpTests.Human#2(name: "John"),
        [4]: DumpTests.Human#2(↩︎),
        [5]: DumpTests.Human#2(↩︎),
        [6]: DumpTests.User(
          name: "John",
          email: "john@me.com",
          age: 97,
          human: DumpTests.Human(↩︎)
        ),
        [7]: DumpTests.User(↩︎),
        [8]: DumpTests.User(↩︎),
        [9]: DumpTests.User#2(
          name: "John",
          email: "john@me.com",
          age: 97,
          human: DumpTests.Human#2(↩︎)
        ),
        [10]: DumpTests.User#2(↩︎),
        [11]: DumpTests.User#2(↩︎)
      ]
      """
    )
  }

  #if (swift(>=5.7) && !targetEnvironment(macCatalyst) && (os(iOS) || os(tvOS) || os(watchOS))) || (swift(>=5.7.1) && os(macOS))
    func testDuration() {
      guard #available(macOS 13, iOS 16, watchOS 9, tvOS 16, *) else { return }

      XCTAssertNoDifference(
        String(customDumping: Duration.seconds(5)),
        """
        5 seconds
        """
      )

      XCTAssertNoDifference(
        String(customDumping: Duration.seconds(5) + .milliseconds(123)),
        """
        5 seconds, 123 milliseconds
        """
      )
    }
  #endif

  #if canImport(CoreGraphics)
    func testCoreGraphics() {
      var dump = ""
      customDump(
        CGRect(x: 0.5, y: 0.5, width: 1.5, height: 1.5),
        to: &dump
      )
      XCTAssertNoDifference(
        dump,
        """
        CGRect(
          origin: CGPoint(
            x: 0.5,
            y: 0.5
          ),
          size: CGSize(
            width: 1.5,
            height: 1.5
          )
        )
        """
      )
    }
  #endif

  #if canImport(SwiftUI)
    func testSwiftUI() {
      var dump = ""
      customDump(
        Animation.easeInOut,
        to: &dump
      )
      XCTAssertNoDifference(
        dump,
        """
        Animation.easeInOut
        """
      )
    }
  #endif
}
