Gem::Specification.new do |spec|
  spec.name = "parshap-csv_parser"
  spec.version = "1.1.0"
  spec.authors = ["Parsha Pourkhomami"]
  spec.email = ["parshap+gem@gmail.com"]
  spec.summary = "High-level CSV parser"
  spec.homepage = "https://github.com/parshap/csv-parser"
  spec.license = "Public Domain"
  spec.require_paths = ["lib"]

  spec.files = `git ls-files`.split($/)
  spec.test_files = spec.files.grep(/^test/)

  spec.add_development_dependency "test-unit"
end
