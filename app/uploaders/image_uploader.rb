class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Add a white list of extensions which are allowed to be uploaded
  def extension_allowlist
    %w(jpg jpeg png)
  end

  # Add a size range validation
  def size_range
    0..5.megabytes
  end

  # Provide a default URL as a default if there hasn't been a file uploaded
  def default_url(*args)
    "/images/fallback/default.png"
  end

  # Process files as they are uploaded
  process resize_to_fit: [800, 800]

  # Create different versions of your uploaded files
  version :thumb do
    process resize_to_fit: [200, 200]
  end

  version :default do
    process resize_to_fit: [400, 400]
  end
end
