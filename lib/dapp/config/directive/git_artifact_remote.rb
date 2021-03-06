module Dapp
  module Config
    module Directive
      # GitArtifactRemote
      class GitArtifactRemote < GitArtifactLocal
        attr_reader :_url, :_name, :_branch, :_commit

        def initialize(url, **kwargs, &blk)
          raise Error::Config, code: :git_artifact_remote_unsupported_protocol, data: { url: url } unless %w(http https).include? URI(url.to_s).scheme

          @_url  = url
          @_name = url.gsub(%r{.*?([^\/ ]+)\.git}, '\\1')

          super(**kwargs, &blk)
        end

        def _export
          super do |export|
            export._url    = @_url
            export._name   = @_name
            export._branch ||= @_branch
            export._commit ||= @_commit
          end
        end

        # Export
        class Export < GitArtifactLocal::Export
          attr_accessor :_url, :_name, :_branch, :_commit

          def _artifact_options
            super.merge(name: _name, branch: _branch)
          end

          protected

          def branch(value)
            @_branch = value
          end

          def commit(value)
            @_commit = value
          end
        end

        protected

        def branch(value)
          @_branch = value
        end

        def commit(value)
          @_commit = value
        end
      end
    end
  end
end
