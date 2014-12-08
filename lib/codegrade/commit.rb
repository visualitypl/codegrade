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

      return [] if commit.parents.size > 1

      diff = commit.parents[0].diff(commit)

      diff.deltas.each do |delta|
        next if delta.status == :deleted

        files.push(delta.new_file[:path])
      end

      files
    end
  end
end