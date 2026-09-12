#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "yaml"

root = File.expand_path("..", __dir__)
skills_root = File.join(root, "areas do direito")
output = ARGV[0] ? File.expand_path(ARGV[0]) : File.join(root, "catalogo-skills.tsv")

rows = []
Dir.glob(File.join(skills_root, "**", "SKILL.md")).sort.each do |path|
  text = File.read(path)
  finish = text.index("\n---\n", 4)
  raise "Frontmatter inválido: #{path}" unless text.start_with?("---\n") && finish

  metadata = YAML.safe_load(text[4...finish], permitted_classes: [], aliases: false) || {}
  next if metadata.dig("metadata", "status") == "deprecated"

  relative = path.delete_prefix("#{root}/")
  area = relative.split(File::SEPARATOR)[1]
  title = text[/^#\s+(.+)$/, 1].to_s.strip
  name = metadata.fetch("name")
  description = metadata.fetch("description").gsub(/\s+/, " ").strip
  intent = name.sub(/\A[^-]+-/, "").tr("-", " ")
  routing = metadata.dig("metadata", "routing") || {}
  list = lambda { |key| Array(routing[key]).join(" | ") }

  rows << [
    area, name, title, intent, description,
    list.call("related_areas"), list.call("jurisdictions"), list.call("procedures"),
    list.call("phases"), list.call("client_sides"), list.call("deliverables"),
    list.call("triggers"), list.call("exclusions"), list.call("required_inputs"),
    list.call("alternatives"), list.call("official_sources"),
    routing["legal_cutoff"].to_s, routing["review_status"].to_s,
    routing["risk_level"].to_s, relative
  ]
end

CSV.open(output, "w", col_sep: "\t", force_quotes: true) do |csv|
  csv << %w[
    area name title intent description related_areas jurisdictions procedures phases
    client_sides deliverables triggers exclusions required_inputs alternatives official_sources
    legal_cutoff review_status risk_level path
  ]
  rows.each { |row| csv << row }
end

puts "Catálogo criado: #{output} (#{rows.length} skills)"
