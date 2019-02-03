Welcome to C++ unit testing with CMake and conan.io demo project for TN-TECH blog article.
===

Complete blog article can be seen here: [https://tn-tech.co.rs](https://tn-tech.co.rs).

Requirements
---
- Modern C++17 compiler
- CMake version >= 3.12
- Boost libraries
- GTest libraries

Demo project scope
---

The scope of this demo project is to:
- Create a small library that will convert any input via stream in simplified properties file format (no groups) to JSON format (not pretty printed) and save it via stream.
- Property name can have only letters, numbers and underscores but must start with letter.
- The lines that are ill-formed should be ignored.
- If multiple properties with same name/key are given, the last one will be used.
- Anything is allowed as value, including empty string as long it is in one line.

Sample input:
```text
location=/var/tmp
extension=log
pattern=log-%YYYY%MM%DD
blabla+foo
maxfilesize=16MB
indexlocation=suffix
compress-no
``` 

Sample output:
```json
{
  "location": "/var/tmp","extension": "/log","pattern": "log-%YYYY%MM%DD","maxfilesize": "16MB","indexlocation": "suffix"
}
```

