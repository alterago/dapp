module Dapp
  # Project
  class Project
    # Command
    module Command
      # Push
      module Push
        def push(repo)
          validate_repo_name(repo)
          log_step_with_indent(:stages) { stages_push(repo) } if with_stages?
          build_configs.each do |config|
            log_dimg_name_with_indent(config) do
              Dimg.new(config: config, project: self, ignore_git_fetch: true, should_be_built: true).tap do |dimg|
                dimg.export!(repo, format: push_format(config._name))
              end
            end
          end
        end

        protected

        def with_stages?
          !!cli_options[:with_stages]
        end
      end
    end
  end # Project
end # Dapp
