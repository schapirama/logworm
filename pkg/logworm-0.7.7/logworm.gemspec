# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{logworm}
  s.version = "0.7.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pomelo, LLC"]
  s.date = %q{2010-06-24}
  s.description = %q{logworm logging tool}
  s.email = %q{schapira@pomelollc.com}
  s.extra_rdoc_files = ["CHANGELOG", "README", "lib/base/config.rb", "lib/base/db.rb", "lib/base/query_builder.rb", "lib/logworm.rb"]
  s.files = ["CHANGELOG", "Manifest", "README", "Rakefile", "lib/base/config.rb", "lib/base/db.rb", "lib/base/query_builder.rb", "lib/logworm.rb", "spec/base_spec.rb", "spec/builder_spec.rb", "spec/config_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tests/builder_test.rb", "logworm.gemspec"]
  s.homepage = %q{http://www.logworm.com}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Logworm", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{logworm}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{logworm logging tool}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<memcache-client>, [">= 0"])
      s.add_runtime_dependency(%q<hpricot>, [">= 0"])
      s.add_runtime_dependency(%q<oauth>, [">= 0"])
      s.add_runtime_dependency(%q<heroku>, [">= 0"])
      s.add_development_dependency(%q<memcache-client>, [">= 0"])
      s.add_development_dependency(%q<hpricot>, [">= 0"])
      s.add_development_dependency(%q<oauth>, [">= 0"])
      s.add_development_dependency(%q<heroku>, [">= 0"])
    else
      s.add_dependency(%q<memcache-client>, [">= 0"])
      s.add_dependency(%q<hpricot>, [">= 0"])
      s.add_dependency(%q<oauth>, [">= 0"])
      s.add_dependency(%q<heroku>, [">= 0"])
      s.add_dependency(%q<memcache-client>, [">= 0"])
      s.add_dependency(%q<hpricot>, [">= 0"])
      s.add_dependency(%q<oauth>, [">= 0"])
      s.add_dependency(%q<heroku>, [">= 0"])
    end
  else
    s.add_dependency(%q<memcache-client>, [">= 0"])
    s.add_dependency(%q<hpricot>, [">= 0"])
    s.add_dependency(%q<oauth>, [">= 0"])
    s.add_dependency(%q<heroku>, [">= 0"])
    s.add_dependency(%q<memcache-client>, [">= 0"])
    s.add_dependency(%q<hpricot>, [">= 0"])
    s.add_dependency(%q<oauth>, [">= 0"])
    s.add_dependency(%q<heroku>, [">= 0"])
  end
end
