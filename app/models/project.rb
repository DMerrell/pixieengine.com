class Project < ActiveRecord::Base
  belongs_to :user
  
  after_create :clone_repo

  BRANCH_NAME = "pixie"
  
  def base_path
    Rails.root.join 'public', 'production', 'projects'
  end

  def path
    base_path.join(id.to_s).to_s
  end

  def web_path
    "/production/projects/#{id}/"
  end

  def clone_repo
    if remote_origin
      system "git", "clone", remote_origin, path
      system "cd #{path} && git checkout -b #{BRANCH_NAME}"
    end
  end

  def git_push
    system "cd #{path} && git push origin #{BRANCH_NAME}"
  end

  def git_commit
    #TODO: Maybe scope to specific files
    system "cd #{path} && git add ."

    #TODO: Shell escape user display name and add to commit message
    system "cd #{path} && git commit -am 'pixie'"
  end

  def save_file(path, contents)
    #TODO: Verify path is not sketch
    return if path.index ".."

    filepath = File.join self.path, path

    File.open(filepath, 'w') do |file|
      file.write(contents)
    end

    git_commit
    git_push
  end

  def file_info
    file_node_data path, path
  end

  def file_node_data(file_path, project_root_path)
    filename = File.basename file_path

    if File.directory? file_path
      {
        :name => filename,
        :ext => "directory",
        :files => Dir.new(file_path).map do |filename|
          next if filename[0...1] == "."

          file_node_data(File.join(file_path, filename), project_root_path)
        end.compact
      }
    elsif File.file? file_path
      ext = File.extname(filename)[1..-1]
      contents = File.read(file_path) if ext == "js"
      {
        :name => filename,
        :contents => contents,
        :ext => ext,
        :size => File.size(file_path),
        :path => file_path.sub(project_root_path, ''),
      }
    end
  end

  def has_access?(user)
    #TODO: Project memberships

    user == self.user
  end
end
