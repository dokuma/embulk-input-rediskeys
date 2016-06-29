
Gem::Specification.new do |spec|
  spec.name          = "embulk-input-rediskeys"
  spec.version       = "0.1.0"
  spec.authors       = ["dokuma"]
  spec.summary       = "Redis input plugin for Embulk"
  spec.description   = "Loads records from Redis."
  spec.email         = ["dokuma.h@gmail.com"]
  spec.licenses      = ["MIT"]
  spec.homepage      = "https://github.com/dokuma/embulk-input-rediskeys"

  spec.files         = `git ls-files`.split("\n") + Dir["classpath/*.jar"]
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'redis', ['>= 3.0.5']
  spec.add_development_dependency 'embulk', ['>= 0.8.9']
  spec.add_development_dependency 'bundler', ['>= 1.10.6']
  spec.add_development_dependency 'rake', ['>= 10.0']
end
