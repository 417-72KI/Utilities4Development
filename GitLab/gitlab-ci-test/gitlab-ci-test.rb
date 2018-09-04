#!/usr/bin/env ruby

require 'yaml'
require 'optparse'
require 'pp'

def prepare_test(skip_before_script, print_compiled_command)
    yaml = load_gitlab_ci()
    jobs = get_job_list(yaml)

    print("Select number of job to test:\n")
    jobs.keys.each_with_index { |e, i| print("#{i + 1}: #{e}\n")   }
    loop do
        input = STDIN.gets.to_i
        if input.between?(1, jobs.keys.length)
            key = jobs.keys[input - 1]
            print("start test for job '#{key}'\n")
            variables = yaml["variables"]
            job = jobs[key]
            start_test(job, variables, skip_before_script, print_compiled_command)
            break
        end
        print("Invalid input.\n")
    end
end

def start_test(job, variables, skip_before_script, print_compiled_command)
    set_environments(variables)

    before_script = skip_before_script ? nil : job['before_script']
    script = job['script']
    after_script = job['after_script']

    scripts = []
    if before_script
        scripts.concat(before_script)
    end
    if script
        scripts.concat(script)
    end
    if after_script
        scripts.concat(after_script)
    end
    scripts.each { |cmd| run_script(cmd, print_compiled_command) }
end

def run_script(script, print_compiled_command)
    print(script)
    print("\n")
    if print_compiled_command
        system("echo \"#{script}\"")
        print("\n")
    end
    system(script)
end

def get_job_list(yaml)
    global_conf = ["cache", "before_script", "after_script", "variables", "stages"]
    return yaml.select { |k, v| !k.start_with?(".") && !global_conf.include?(k) }
end

def load_gitlab_ci()
    fileName = '.gitlab-ci.yml'
    if File.exist?(fileName)
        yaml = YAML.load_file(fileName)
        if !yaml
            print("Error: Invalid format.\n")
            exit(1)
        end
        return yaml
    else
        print("Error: #{fileName} not found. This directory is not a repository for GitLab or GitLab-CI unavailable.\n")
        exit(1)
    end
end

def set_environments(environments)
    if environments.nil?
        return
    end
    environments.each { |key, value|
        # cmd = "export #{key}=\"#{value}\""
        # system(cmd)
        ENV[key] = value
    }
end

def print_gitlab_ci()
    yaml = load_gitlab_ci()
    pp yaml
end

def print_job_list()
    yaml = load_gitlab_ci()
    jobs = get_job_list(yaml)
    jobs.keys.each { |v| print("#{v}\n") }
end

def main(args)
    if args['mode']
        mode = args['mode']
        if mode == 'p'
            print_gitlab_ci()
        elsif mode == 'l'
            print_job_list()
        end
    else
        if args['secret_variables']
            secret_variables = args['secret_variables']
            .map { |v| v.split('=') }
            .map { |v| { v[0] => v[1] } }
            .reduce({}, :update)
            set_environments(secret_variables)
        end
        skip_before_script = false
        if args['skip_before_script']
            skip_before_script = args['skip_before_script']
        end
        prepare_test(skip_before_script, args['print_compiled_command'])
    end
end

if __FILE__ == $0
    args = {}
    opt = OptionParser.new
    opt.on('-s secret_variables', Array, 'Secret Variables set in GitLab-CI') { |v| args['secret_variables'] = v }
    opt.on('-b', '--skip-before-script', 'If before_script is not necessary to be executed many times, it skips before_script.') { |v| args['skip_before_script'] = true }
    opt.on('-c', '--print-compiled-command') { |v| args['print_compiled_command'] = true }
    opt.on('-p', '--print-gitlab_ci') { |v| args['mode'] = 'p' }
    opt.on('-l', '--list-jobs') { |v| args['mode'] = 'l' }
    opt.parse(ARGV)
    main(args)
end
