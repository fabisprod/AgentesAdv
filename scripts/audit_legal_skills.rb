#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

root = File.expand_path("..", __dir__)
files = Dir.glob(File.join(root, "areas do direito", "**", "SKILL.md")).sort
errors = []
warnings = []
names = Hash.new { |hash, key| hash[key] = [] }
titles = Hash.new { |hash, key| hash[key] = [] }

files.each do |path|
  relative = path.delete_prefix("#{root}/")
  text = File.read(path)
  finish = text.index("\n---\n", 4)
  unless text.start_with?("---\n") && finish
    errors << "#{relative}: frontmatter ausente ou inválido"
    next
  end

  begin
    metadata = YAML.safe_load(text[4...finish], permitted_classes: [], aliases: false) || {}
  rescue StandardError => e
    errors << "#{relative}: YAML inválido (#{e.message.lines.first.strip})"
    next
  end

  name = metadata["name"].to_s
  description = metadata["description"].to_s.strip
  deprecated = metadata.dig("metadata", "status") == "deprecated"
  errors << "#{relative}: name ausente" if name.empty?
  errors << "#{relative}: description ausente" if description.empty?
  if name.length >= 64
    message = "#{relative}: name deve ter menos de 64 caracteres (#{name.length})"
    deprecated ? warnings << "#{message}; pacote legado desativado" : errors << message
  end
  warnings << "#{relative}: description termina truncada em reticências" if description.end_with?("...")
  warnings << "#{relative}: quantidade ímpar de cercas de código" if text.scan(/^```/).length.odd?
  names[name] << relative unless name.empty?
  title = text[/^#\s+(.+)$/, 1].to_s.strip
  routing_area = metadata.dig("metadata", "routing", "area").to_s.strip
  titles[title] << [relative, routing_area] unless title.empty? || deprecated

  ui_path = File.join(File.dirname(path), "agents", "openai.yaml")
  unless File.exist?(ui_path)
    warnings << "#{relative}: agents/openai.yaml ausente"
    next
  end

  begin
    ui = YAML.safe_load(File.read(ui_path), permitted_classes: [], aliases: false) || {}
    prompt = ui.dig("interface", "default_prompt").to_s
    warnings << "#{relative}: default_prompt não menciona $#{name}" unless prompt.include?("$#{name}")
  rescue StandardError => e
    errors << "#{ui_path.delete_prefix("#{root}/")}: YAML inválido (#{e.message.lines.first.strip})"
  end
end

names.each do |name, paths|
  errors << "nome duplicado #{name}: #{paths.join(', ')}" if paths.length > 1
end

titles.each do |title, paths|
  next unless paths.length > 1

  areas = paths.map { |_path, area| area }.reject(&:empty?).uniq
  if areas.length > 1
    puts "INFO\ttítulo compartilhado #{title}, distinguido por área: #{areas.join(', ')}"
  else
    warnings << "título duplicado #{title}: #{paths.map(&:first).join(', ')}"
  end
end

puts "Skills auditadas: #{files.length}"
puts "Erros: #{errors.length}"
errors.each { |item| puts "ERROR\t#{item}" }
puts "Avisos: #{warnings.length}"
warnings.each { |item| puts "WARN\t#{item}" }

exit(errors.empty? ? 0 : 1)
