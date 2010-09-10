class Sound < ActiveRecord::Base
  include Commentable

  has_attached_file :wav,
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path => "sounds/:id/:style.:extension"

  has_attached_file :mp3,
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path => "sounds/:id/:style.:extension"

  validates_attachment_presence :wav

  has_attached_file :sfs,
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path => "sounds/:id/:style.:extension"

  validates_attachment_presence :sfs

  acts_as_archive

  belongs_to :user

  before_validation :convert_to_mp3

  def sfs_base64
    open(sfs.url, "rb") do |f|
      Base64.encode64(f.read())
    end
  end

  def display_name
    if title.blank?
      "Sound #{id}"
    else
      title
    end
  end

  def to_param
    if title.blank?
      id
    else
      "#{id}-#{title.seo_url}"
    end
  end

  def reconvert_to_mp3
    wavfile = Tempfile.new(".wav")
    wavfile.binmode

    open(wav.url) do |f|
      wavfile << f.read
    end

    wavfile.close

    convert_tempfile(wavfile)
  end

  def convert_to_mp3
    tempfile = wav.queued_for_write[:original]

    unless tempfile.nil?
      convert_tempfile(tempfile)
    end
  end

  def convert_tempfile(tempfile)
    dst = Tempfile.new(".mp3")

    cmd_args = [File.expand_path(tempfile.path), File.expand_path(dst.path)]
    system("lame", *cmd_args)

    dst.binmode
    io = StringIO.new(dst.read)
    dst.close

    io.original_filename = "sound.mp3"
    io.content_type = "audio/mpeg"

    self.mp3 = io
  end
end
