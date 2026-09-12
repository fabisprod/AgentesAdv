#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "json"
require "fileutils"

root = File.expand_path("..", __dir__)
files = Dir.glob(File.join(root, "areas do direito", "**", "SKILL.md")).sort
changed = 0

files.each do |skill_path|
  text = File.read(skill_path)
  finish = text.index("\n---\n", 4)
  raise "Frontmatter inválido: #{skill_path}" unless text.start_with?("---\n") && finish

  skill = YAML.safe_load(text[4...finish], permitted_classes: [], aliases: false) || {}
  name = skill.fetch("name")
  ui_path = File.join(File.dirname(skill_path), "agents", "openai.yaml")
  unless File.exist?(ui_path)
    title = text[/^#\s+(.+)$/, 1].to_s.strip
    title = name.tr("-", " ") if title.empty?
    short = "Skill jurídica: #{title}"[0, 64].rstrip
    FileUtils.mkdir_p(File.dirname(ui_path))
    File.write(
      ui_path,
      [
        "interface:",
        "  display_name: #{JSON.generate(title)}",
        "  short_description: #{JSON.generate(short)}",
        "  default_prompt: #{JSON.generate("Use $#{name} para preparar #{title} com os dados do caso.")}" 
      ].join("\n") + "\n"
    )
    changed += 1
    next
  end

  ui_text = File.read(ui_path)
  ui = YAML.safe_load(ui_text, permitted_classes: [], aliases: false) || {}
  interface = ui.fetch("interface")
  next if interface.fetch("default_prompt", "").include?("$#{name}")

  title = interface.fetch("display_name")
  new_prompt = "Use $#{name} para preparar #{title} com os dados do caso."
  replacement = "  default_prompt: #{new_prompt.dump}"
  if ui_text.match?(/^\s{2}default_prompt:/)
    ui_text = ui_text.sub(/^\s{2}default_prompt:.*$/, replacement)
  else
    ui_text = ui_text.sub(/^interface:\s*$/, "interface:\n#{replacement}")
  end
  File.write(ui_path, ui_text)
  changed += 1
end

puts "Metadados atualizados: #{changed}"
