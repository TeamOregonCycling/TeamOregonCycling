class ProfileImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :aws

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    '/tmp/teamo-cache'
  end

  def content_type_whitelist
    %r{image/}
  end

  process resize_to_fill: [300, 300]
  process convert: 'png'

  def filename
    super.chomp(File.extname(super)) + '.png' if original_filename.present?
  end

  version :list_big do
    process resize_to_fill: [200, 200]
  end

  version :list_tiny do
    process resize_to_fill: [30, 30]
  end
end
