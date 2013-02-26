# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "parse_resource"
  s.version = "1.7.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alan deLevie"]
  s.date = "2013-02-26"
  s.description = ""
  s.email = "adelevie@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".travis.yml",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "fixtures/vcr_cassettes/test_all.yml",
    "fixtures/vcr_cassettes/test_attribute_getters.yml",
    "fixtures/vcr_cassettes/test_attribute_setters.yml",
    "fixtures/vcr_cassettes/test_authenticate.yml",
    "fixtures/vcr_cassettes/test_chained_wheres.yml",
    "fixtures/vcr_cassettes/test_count.yml",
    "fixtures/vcr_cassettes/test_create.yml",
    "fixtures/vcr_cassettes/test_created_at.yml",
    "fixtures/vcr_cassettes/test_destroy.yml",
    "fixtures/vcr_cassettes/test_destroy_all.yml",
    "fixtures/vcr_cassettes/test_each.yml",
    "fixtures/vcr_cassettes/test_find.yml",
    "fixtures/vcr_cassettes/test_find_all_by.yml",
    "fixtures/vcr_cassettes/test_find_by.yml",
    "fixtures/vcr_cassettes/test_first.yml",
    "fixtures/vcr_cassettes/test_id.yml",
    "fixtures/vcr_cassettes/test_limit.yml",
    "fixtures/vcr_cassettes/test_map.yml",
    "fixtures/vcr_cassettes/test_save.yml",
    "fixtures/vcr_cassettes/test_skip.yml",
    "fixtures/vcr_cassettes/test_update.yml",
    "fixtures/vcr_cassettes/test_updated_at.yml",
    "fixtures/vcr_cassettes/test_username_should_be_unique.yml",
    "fixtures/vcr_cassettes/test_where.yml",
    "lib/.DS_Store",
    "lib/kaminari_extension.rb",
    "lib/parse_resource.rb",
    "lib/parse_resource/base.rb",
    "lib/parse_resource/client.rb",
    "lib/parse_resource/errors.rb",
    "lib/parse_resource/parse_error.rb",
    "lib/parse_resource/parse_exceptions.rb",
    "lib/parse_resource/parse_settings.rb",
    "lib/parse_resource/parse_user.rb",
    "lib/parse_resource/parse_user_validator.rb",
    "lib/parse_resource/query.rb",
    "lib/parse_resource/query_methods.rb",
    "lib/parse_resource/types/parse_geopoint.rb",
    "parse_resource.gemspec",
    "parse_resource.yml",
    "rdoc/ParseResource.html",
    "rdoc/created.rid",
    "rdoc/index.html",
    "rdoc/lib/parse_resource_rb.html",
    "rdoc/rdoc.css",
    "test/active_model_lint_test.rb",
    "test/helper.rb",
    "test/test_parse_installation.rb",
    "test/test_parse_resource.rb",
    "test/test_parse_user.rb",
    "test/test_query.rb",
    "test/test_query_options.rb",
    "test/test_types.rb"
  ]
  s.homepage = "http://github.com/adelevie/parse_resource"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "An ActiveResource-like wrapper for the Parse REST api."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-client>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<settingslogic>, [">= 0"])
      s.add_runtime_dependency(%q<activemodel>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<reek>, [">= 0"])
      s.add_development_dependency(%q<rest-client>, [">= 0"])
      s.add_development_dependency(%q<activesupport>, [">= 0"])
      s.add_development_dependency(%q<activemodel>, [">= 0"])
      s.add_development_dependency(%q<vcr>, [">= 0"])
      s.add_development_dependency(%q<webmock>, [">= 0"])
    else
      s.add_dependency(%q<rest-client>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<settingslogic>, [">= 0"])
      s.add_dependency(%q<activemodel>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<reek>, [">= 0"])
      s.add_dependency(%q<rest-client>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<activemodel>, [">= 0"])
      s.add_dependency(%q<vcr>, [">= 0"])
      s.add_dependency(%q<webmock>, [">= 0"])
    end
  else
    s.add_dependency(%q<rest-client>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<settingslogic>, [">= 0"])
    s.add_dependency(%q<activemodel>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<reek>, [">= 0"])
    s.add_dependency(%q<rest-client>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<activemodel>, [">= 0"])
    s.add_dependency(%q<vcr>, [">= 0"])
    s.add_dependency(%q<webmock>, [">= 0"])
  end
end

