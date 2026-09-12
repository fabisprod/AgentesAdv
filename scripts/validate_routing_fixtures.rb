#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "set"

root = File.expand_path("..", __dir__)
catalog = File.join(root, "catalogo-skills.tsv")
fixtures = File.join(root, "governanca", "casos-teste-roteamento.tsv")

names = CSV.read(catalog, headers: true, col_sep: "\t").map { |row| row.fetch("name") }.to_set
errors = []

CSV.read(fixtures, headers: true, col_sep: "\t").each do |row|
  allowed = row.fetch("candidatas_aceitaveis").to_s.split(" | ").reject(&:empty?)
  forbidden = row.fetch("candidatas_proibidas").to_s.split(" | ").reject(&:empty?)
  errors << "#{row['id']}: resultado inválido" unless %w[executar esclarecer lacuna].include?(row.fetch("resultado"))
  errors << "#{row['id']}: candidato aceitável inexistente #{(allowed - names.to_a).join(', ')}" unless (allowed - names.to_a).empty?
  errors << "#{row['id']}: candidato proibido inexistente #{(forbidden - names.to_a).join(', ')}" unless (forbidden - names.to_a).empty?
  errors << "#{row['id']}: lacuna não deve indicar candidata" if row.fetch("resultado") == "lacuna" && !allowed.empty?
  errors << "#{row['id']}: caso ambíguo sem perguntas críticas" if row.fetch("resultado") == "esclarecer" && row.fetch("perguntas_criticas").to_s.strip.empty?
end

puts "Casos de roteamento validados: #{CSV.read(fixtures, headers: true, col_sep: "\t").length}"
if errors.empty?
  puts "Erros: 0"
else
  errors.each { |error| warn "ERROR\t#{error}" }
  exit 1
end
