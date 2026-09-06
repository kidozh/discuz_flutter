# Read-only offline report analysis. No device access and no Flutter frame loop.
require 'json'

report = JSON.parse(File.read(ARGV.fetch(0)))
phases = report.fetch('phases')
frames = report.fetch('raw_frames')
samples = report.fetch('samples')
rate = report.fetch('device').fetch('maximumFramesPerSecond')
budget = 1_000_000.0 / rate

def distribution(values)
  sorted = values.sort
  return nil if sorted.empty?
  { p95_ms: sorted[(sorted.length * 0.95).ceil - 1] / 1000.0,
    p99_ms: sorted[(sorted.length * 0.99).ceil - 1] / 1000.0,
    max_ms: sorted.last / 1000.0 }
end

output = report.slice('completed', 'scenario', 'error', 'stop_reason', 'elapsed_s', 'reading')
output['thermal_states'] = samples.map { |s| s['thermal'] }.uniq
output['worst_thermal_raw'] = samples.map { |s| s['worstThermalRaw'] }.max
output['brightness_range'] = samples.map { |s| s['brightness'] }.minmax
output['rss_mb_range'] = samples.map { |s| s['rss_bytes'] / 1048576.0 }.minmax
output['gesture_count'] = report.fetch('gestures').length
output['phases'] = phases.map do |phase|
  start_time = phase.fetch('start_wall_us')
  end_time = phase.fetch('end_wall_us')
  selected = frames.select { |f| f['wall_us'] >= start_time && f['wall_us'] < end_time }
  readings = samples.select { |s| s['wall_us'] >= start_time && s['wall_us'] <= end_time }
  first, last = readings.first, readings.last
  cpu_percent = if readings.length >= 2 && first['cpuTimeAvailable'] && last['cpuTimeAvailable']
    elapsed = last['uptimeSeconds'] - first['uptimeSeconds']
    if elapsed > 0
      100 * (last['cpuUserSeconds'] + last['cpuSystemSeconds'] -
          first['cpuUserSeconds'] - first['cpuSystemSeconds']) / elapsed
    end
  end
  over = selected.count { |f| f['build_us'] > budget || f['raster_us'] > budget }
  { name: phase['name'], seconds: phase['actual_duration_s'],
    frames: selected.length, build: distribution(selected.map { |f| f['build_us'] }),
    raster: distribution(selected.map { |f| f['raster_us'] }),
    over_budget: over,
    over_budget_percent: selected.empty? ? nil : 100.0 * over / selected.length,
    process_cpu_percent_one_core: cpu_percent }
end
puts JSON.pretty_generate(output)
