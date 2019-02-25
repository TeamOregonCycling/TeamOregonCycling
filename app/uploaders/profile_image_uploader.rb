class ProfileImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :aws

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_whitelist
    %w(jpg jpeg gif png)
  end

  process resize_to_fit: [400, 400]

  version :list_big do
    process resize_to_fit: [200, 200]
  end

  version :list_tiny do
    process resize_to_fit: [30, 30]
  end
end
