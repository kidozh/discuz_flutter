require 'fileutils'
require 'pathname'
require 'rubygems'

# Compile compatibility copies inside Pods rather than modifying shared pub
# cache files. Both Apple targets apply the same fixes on every pod install.
module ApplePluginCompatibility
  module_function

  def foundation_models(source, modern_sampling:)
    source = source.gsub(/(await MainActor\.run \{\n\s*)(self\.streamTasks\.removeValue\(forKey: streamId\))/, '\1_ = \2')
    source = source.gsub(
      'snapshot.content as? String ?? String(describing: snapshot.content)',
      'snapshot.content'
    )
    source = source.gsub('options.sampling =', 'options.samplingMode =') if modern_sampling

    # New SDKs add known transcript cases, so @unknown default still warns.
    # Preserve the previous fallback representation for any additional case.
    source = transform_method(source, 'private func mapTranscriptEntries(', 'private func availabilityReasonCode(') do |body|
      body = body.gsub('@unknown default:', 'default:')
      body = body.sub(
        /(case \.response\(let response\):\n\s*role = "response"\n\s*segmentsText = response\.segments\.map\(serializeSegment\)\n\s*content = segmentsText\.joined\(separator: "\\n"\)\n)(\s*\})/,
        "\\1            default:\n                role = \"unknown\"\n                let description = String(describing: entry)\n                segmentsText = [description]\n                content = description\n\\2"
      )
      body.sub(
        /(case \.structure\(let structuredSegment\):\n\s*return String\(describing: structuredSegment\.content\)\n)(\s*\})/,
        "\\1        default:\n            return String(describing: segment)\n\\2"
      )
    end
    transform_method(source, 'private func sanitizeGenerationError(', "\n}\n") do |body|
      body.sub(
        /(case \.unsupportedLanguageOrLocale\(_\):\n\s*return FoundationModelsError\.requestFailed\("Unsupported language or locale"\)\n)(\s*\})/,
        "\\1            default:\n                return error\n\\2"
      )
    end
  end

  def transform_method(source, start_marker, end_marker)
    start = source.index(start_marker)
    finish = start && source.index(end_marker, start + start_marker.length)
    return source unless finish

    source[0...start] + yield(source[start...finish]) + source[finish..]
  end

  def transform(target_name, filename, source, modern_sampling:)
    case [target_name, filename]
    when ['foundation_models_framework', 'FoundationModelsFrameworkPlugin.swift']
      foundation_models(source, modern_sampling: modern_sampling)
    when ['audio_session', 'AudioSessionPlugin.m']
      source.sub(
        '    [[AudioSessionPlugin alloc] initWithRegistrar:registrar];',
        '    (void)[[AudioSessionPlugin alloc] initWithRegistrar:registrar];'
      )
    when ['flutter_image_compress_macos', 'FlutterImageCompressMacosPlugin.swift']
      source = source.sub("import AVFoundation\n", "import AVFoundation\nimport UniformTypeIdentifiers\n") unless source.include?('import UniformTypeIdentifiers')
      source.gsub('kUTTypeJPEG', 'UTType.jpeg.identifier as CFString')
            .gsub('kUTTypePNG', 'UTType.png.identifier as CFString')
    else
      source
    end
  end

  def apply(installer, sdk_version:)
    modern_sampling = Gem::Version.new(sdk_version) >= Gem::Version.new('27.0')
    installer.pods_project.targets.each do |target|
      next unless %w[foundation_models_framework audio_session flutter_image_compress_macos].include?(target.name)

      target.source_build_phase.files_references.each do |reference|
        original = reference.real_path
        next unless original.file?

        source = original.read
        patched = transform(target.name, original.basename.to_s, source, modern_sampling: modern_sampling)
        next if patched == source

        destination = installer.sandbox.root.join('Compatibility', target.name, original.basename)
        FileUtils.mkdir_p(destination.dirname)
        destination.write(patched)
        reference.name = original.basename.to_s
        reference.source_tree = 'SOURCE_ROOT'
        reference.path = destination.relative_path_from(installer.sandbox.root).to_s
        Pod::UI.puts "Applied Apple SDK compatibility fixes to #{target.name}."
      end
    end
  end
end
