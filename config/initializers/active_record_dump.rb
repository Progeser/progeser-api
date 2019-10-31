# frozen_string_literal: true

class ActiveRecord::Base
  def dump_fixture
    table_name = self.class.table_name.gsub(/public./, '')
    fixture_file = Rails.root.join(
      'test',
      'fixtures',
      "#{table_name}.yml"
    )

    File.open(fixture_file, 'a+') do |f|
      f.puts(
        {
          "#{table_name.singularize}_#{id}" => attributes
        }.to_yaml.sub!(/---\s?/, "\n")
      )
    end
  end
end
