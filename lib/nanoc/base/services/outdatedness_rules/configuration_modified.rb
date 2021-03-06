module Nanoc::Int::OutdatednessRules
  class ConfigurationModified < Nanoc::Int::OutdatednessRule
    extend Nanoc::Int::Memoization

    affects_props :raw_content, :attributes, :compiled_content, :path

    def apply(_obj, outdatedness_checker)
      if config_modified?(outdatedness_checker)
        Nanoc::Int::OutdatednessReasons::ConfigurationModified
      end
    end

    private

    memoized def config_modified?(outdatedness_checker)
      obj = outdatedness_checker.site.config
      ch_old = outdatedness_checker.checksum_store[obj]
      ch_new = Nanoc::Int::Checksummer.calc(obj)
      ch_old != ch_new
    end
  end
end
