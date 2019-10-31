# frozen_string_literal: true

namespace :fixtures do
  desc 'Dump DB'
  task dump_db: :environment do
    excludes_class = [ApplicationRecord, User]
    limit_records = %w[]

    FileUtils.rm_rf(Dir['test/fixtures/*'])
    Rails.application.eager_load!

    ActiveRecord::Base.descendants.each do |klass|
      next if excludes_class.include?(klass)

      puts "export #{klass}"

      if limit_records.include?(klass.to_s)
        klass.last(30).map(&:dump_fixture)
      else
        klass.all.map(&:dump_fixture)
      end
    end
  end
end
