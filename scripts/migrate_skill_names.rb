#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "digest"
require "fileutils"
require "yaml"

root = File.expand_path("..", __dir__)
apply = ARGV.delete("--apply")
abort "Uso: ruby scripts/migrate_skill_names.rb [--apply]" unless ARGV.empty?

skill_paths = Dir.glob(File.join(root, "areas do direito", "**", "SKILL.md")).sort
migrations = []
skill_paths.each do |path|
  text = File.read(path)
  finish = text.index("\n---\n", 4)
  metadata = YAML.safe_load(text[4...finish], permitted_classes: [], aliases: false) || {}
  old_name = metadata.fetch("name")
  next if old_name.length < 64

  stem = old_name[0, 50].sub(/-+\z/, "")
  new_name = "#{stem}-#{Digest::SHA256.hexdigest(old_name)[0, 8]}"
  migrations << [old_name, new_name, path]
end

new_names = migrations.map { |_, new_name, _| new_name }
abort "Migração gerou nomes duplicados" unless new_names.uniq.length == new_names.length

puts "Skills a migrar: #{migrations.length}"
migrations.each { |old_name, new_name, path| puts "#{old_name}\t#{new_name}\t#{path.delete_prefix("#{root}/")}" }
exit unless apply

replacement_map = migrations.to_h { |old_name, new_name, _| [old_name, new_name] }
editable = Dir.glob(File.join(root, "areas do direito", "**", "*.{md,yaml}")) +
           Dir.glob(File.join(root, "agents", "*.md")) +
           Dir.glob(File.join(root, "governanca", "*.md")) +
           [File.join(root, "AGENTS.md")]

editable.uniq.each do |path|
  next unless File.file?(path)
  content = File.read(path)
  updated = replacement_map.reduce(content) { |memo, (old_name, new_name)| memo.gsub(old_name, new_name) }
  File.write(path, updated) if updated != content
end

migrations.each do |_old_name, new_name, skill_path|
  source_dir = File.dirname(skill_path)
  target_dir = File.join(File.dirname(source_dir), new_name)
  abort "Destino já existe: #{target_dir}" if File.exist?(target_dir)
  FileUtils.mv(source_dir, target_dir)
end

mapping_path = File.join(root, "governanca", "migracao-nomes-skills.tsv")
CSV.open(mapping_path, "w", col_sep: "\t", force_quotes: true) do |csv|
  csv << %w[nome_anterior nome_atual]
  migrations.each { |old_name, new_name, _| csv << [old_name, new_name] }
end

puts "Migração aplicada. Mapa salvo em #{mapping_path}"
