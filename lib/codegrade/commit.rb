module Codegrade
  class Commit
    attr_reader :sha, :working_directory

    def initialize(working_directory = '.', sha = nil)
      @working_directory = File.expand_path(working_directory)
      @sha = sha
    end

    def author
      commit.author
    end

    def message
      commit.message
    end

    def files
      parse_git_tree(commit.tree, working_directory)
    end

    private

    def repo
      @repo ||= Rugged::Repository.new(working_directory)
    end

    def commit
      @commit ||= sha.nil? ? repo.last_commit : repo.lookup(sha)
    end

    def parse_git_tree(tree, path)
      files = []

      tree.walk_blobs do |root, entry|
        path = File.expand_path(root, working_directory)
        files.push(File.join(path, entry[:name]))
      end

      files
    end
  end
end