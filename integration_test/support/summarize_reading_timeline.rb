require 'json'

report = JSON.parse(File.read(ARGV.fetch(0)))
report.fetch('phases').each do |phase|
  events = phase.dig('timeline', 'events') || []
  spans = []
  events.group_by { |e| [e['pid'], e['tid']] }.each_value do |thread|
    stack = []
    thread.each_with_index.sort_by { |e, i| [e['ts'] || 0, i] }.each do |event, _|
      case event['ph']
      when 'B'
        stack.push(event)
      when 'E'
        first = stack.pop
        next unless first && first['name'] == event['name']
        spans.push(first.merge('duration_us' => event['ts'] - first['ts']))
      when 'X'
        spans.push(event.merge('duration_us' => event['dur']))
      end
    end
  end
  groups = spans.group_by { |e| e['name'] }.select do |name, _|
    name.match?(/BUILD|LAYOUT|PAINT|HtmlWidget|Discuz\.|GC/)
  end
  summary = groups.transform_values do |items|
    times = items.map { |e| e['duration_us'] }.sort
    { count: times.length, max_ms: times.last / 1000.0,
      total_ms: times.sum / 1000.0 }
  end
  output = { phase: phase['name'], synchronous_timeline: summary }
  frames = report.fetch('raw_frames').select do |f|
    f['wall_us'] >= phase['start_wall_us'] && f['wall_us'] < phase['end_wall_us']
  end
  if (peak = frames.max_by { |f| f['build_us'] }) && peak['build_us'] > 16000
    output[:slowest_frame] = peak
    output[:within_slowest_frame] = spans.select do |e|
      e['ts'] >= peak['vsync_us'] &&
        e['ts'] + e['duration_us'] <= peak['vsync_us'] + peak['total_us'] &&
        e['duration_us'] > 1000
    end.sort_by { |e| -e['duration_us'] }.first(18).map do |e|
      e.slice('name', 'ts', 'duration_us', 'tid')
    end
  end
  puts JSON.pretty_generate(output)
end
