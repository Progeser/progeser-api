# frozen_string_literal: true

require 'sidekiq/testing'

Sidekiq::Testing.inline!
ActiveJob::Base.queue_adapter = :inline
