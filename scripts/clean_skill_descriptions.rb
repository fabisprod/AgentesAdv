#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

root = File.expand_path("..", __dir__)
apply = ARGV.delete("--apply")
abort "Uso: ruby scripts/clean_skill_descriptions.rb [--apply]" unless ARGV.empty?

changes = []
Dir.glob(File.join(root, "areas do direito", "**", "SKILL.md")).sort.each do |path|
  text = File.read(path)
  finish = text.index("\n---\n", 4)
  next unless text.start_with?("---\n") && finish

  metadata = YAML.safe_load(text[4...finish], permitted_classes: [], aliases: false) || {}
  description = metadata["description"].to_s.strip
  next unless description.end_with?("...") && description.include?("Contextos:")

  cleaned = description.sub(/\s+Contextos:\s*.*/m, "").strip
  next if cleaned.empty?
  changes << [path, metadata, text[(finish + 5)..], cleaned]
end

puts "Descrições a limpar: #{changes.length}"
changes.first(20).each { |path, _, _, _| puts path.delete_prefix("#{root}/") }
exit unless apply

changes.each do |path, metadata, body, cleaned|
  metadata["description"] = cleaned
  frontmatter = YAML.dump(metadata).sub(/\A---\s*\n/, "")
  File.write(path, "---\n#{frontmatter}---\n#{body}")
end

puts "Descrições atualizadas: #{changes.length}"
