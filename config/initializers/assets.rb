if Rails.application.config.respond_to?(:assets)
  Rails.application.config.assets.precompile += %w(stormpath.css)
end
