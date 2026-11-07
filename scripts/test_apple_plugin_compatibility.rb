require 'minitest/autorun'
require 'tmpdir'
require_relative 'apple_plugin_compatibility'

module Pod
  module UI
    def self.puts(_message); end
  end
end

class ApplePluginCompatibilityTest < Minitest::Test
  SOURCE = <<~'SWIFT'.freeze
    class Plugin {
        private func makeGenerationOptions() {
            options.sampling = .greedy
        }
        private func mapTranscriptEntries() {
            switch entry {
            case .response(let response):
                role = "response"
                segmentsText = response.segments.map(serializeSegment)
                content = segmentsText.joined(separator: "\n")
            }
        }
        private func serializeSegment() {
            switch segment {
            case .structure(let structuredSegment):
                return String(describing: structuredSegment.content)
            }
        }
        private func availabilityReasonCode() {}
        private func sanitizeGenerationError() {
            switch generationError {
            case .unsupportedLanguageOrLocale(_):
                return FoundationModelsError.requestFailed("Unsupported language or locale")
            }
        }
    }
  SWIFT

  def test_new_sdk_transcript_and_error_cases_preserve_fallbacks
    patched = ApplePluginCompatibility.foundation_models(SOURCE, modern_sampling: true)
    assert_includes patched, 'options.samplingMode = .greedy'
    assert_includes patched, 'let description = String(describing: entry)'
    assert_includes patched, 'return String(describing: segment)'
    assert_includes patched, "default:\n                return error"
    assert_equal patched, ApplePluginCompatibility.foundation_models(patched, modern_sampling: true)
  end

  def test_previous_unknown_transcript_fallbacks_do_not_duplicate
    patched = ApplePluginCompatibility.foundation_models(SOURCE, modern_sampling: true)
    legacy = patched.sub('default:', '@unknown default:')
    assert_equal patched, ApplePluginCompatibility.foundation_models(legacy, modern_sampling: true)
  end

  def test_older_sdks_keep_the_available_sampling_api
    patched = ApplePluginCompatibility.foundation_models(SOURCE, modern_sampling: false)
    assert_includes patched, 'options.sampling = .greedy'
    refute_includes patched, 'options.samplingMode'
  end

  def test_only_discarded_stream_cleanup_results_change
    source = <<~SWIFT
      let existingTask = await MainActor.run { self.streamTasks[streamId] }
      await MainActor.run {
          self.streamTasks.removeValue(forKey: streamId)
      }
      let cumulative = snapshot.content as? String ?? String(describing: snapshot.content)
    SWIFT
    patched = ApplePluginCompatibility.foundation_models(source, modern_sampling: true)
    assert_includes patched, 'let existingTask = await MainActor.run { self.streamTasks[streamId] }'
    assert_includes patched, '_ = self.streamTasks.removeValue(forKey: streamId)'
    assert_includes patched, 'let cumulative = snapshot.content'
    refute_includes patched, 'as? String'
  end

  class Reference
    attr_accessor :name, :source_tree, :path

    def initialize(path, root)
      @path, @root = path, root
    end

    def real_path
      source_tree == 'SOURCE_ROOT' ? @root.join(path) : Pathname.new(path)
    end
  end

  def test_build_references_use_local_copies_and_leave_dependency_source_intact
    Dir.mktmpdir do |directory|
      root = Pathname.new(directory)
      original = root.join('package', 'FoundationModelsFrameworkPlugin.swift')
      FileUtils.mkdir_p(original.dirname)
      original.write(SOURCE)
      pods = root.join('Pods')
      reference = Reference.new(original.to_s, pods)
      phase = Struct.new(:files_references).new([reference])
      target = Struct.new(:name, :source_build_phase).new('foundation_models_framework', phase)
      project = Struct.new(:targets).new([target])
      sandbox = Struct.new(:root).new(pods)
      installer = Struct.new(:pods_project, :sandbox).new(project, sandbox)

      ApplePluginCompatibility.apply(installer, sdk_version: '27.2')
      assert_equal SOURCE, original.read
      assert_equal 'SOURCE_ROOT', reference.source_tree
      assert reference.real_path.to_s.start_with?(pods.to_s)
      assert_includes reference.real_path.read, 'options.samplingMode'
      copied = reference.real_path.read
      ApplePluginCompatibility.apply(installer, sdk_version: '27.2')
      assert_equal copied, reference.real_path.read
    end
  end
end
