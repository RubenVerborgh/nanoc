require File.dirname(__FILE__) + '/../lib/nanoc.rb'

def in_dir(a_path)
  FileUtils.cd(File.join(a_path))
  yield
  FileUtils.cd(File.join(a_path.map { |n| '..' }))
end

def with_fixture(a_fixture)
  in_dir(['test', 'fixtures', a_fixture]) do
    yield
  end
end
