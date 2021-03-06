# Generates benchmark files to compare the Ruby Native C binding and this implementation in Crystal.
module BenchmarkGenerator
  TARGET_DIR = "#{__DIR__}/generated"
  NUM_ITERATIONS = 10_000
  FILE_HEADER = <<-EOL
  # Generated by #{__FILE__.sub(/.*?(?=benchmarks)/im, "")}
  # Do not modify directly.
  EOL

  def self.clear_target_dir
    Dir.mkdir TARGET_DIR unless File.exists?(TARGET_DIR)

    Dir.each_child(TARGET_DIR) do |path|
      next if path =~ /^\./

      File.delete("#{TARGET_DIR}/#{path}")
    end
  end

  def self.generate
    inputs = [] of String
    contents = File.read("spec/kat_data/sha3/ShortMsgKAT_512.txt").split("Len = ")

    contents.each do |test|
      lines = test.split("\n")

      if !lines.empty? && lines[0] !~ /^#/
        length = lines[0].to_i
        if length % 8 == 0
          inputs.push(lines[2].split(" = ").last.downcase)
        end
      end
    end

    if inputs.size > 0
      cr_content = <<-EOL
      #{FILE_HEADER}
      require "benchmark"
      require "../../src/sha3.cr"

      inputs = %w(#{inputs.join(" ")})

      print "Crystal: "
      puts Benchmark.measure {
        #{NUM_ITERATIONS}.times do
          inputs.each do |i|
            Digest::SHA3.hexdigest(i)
          end
        end
      }
      EOL

      File.write("#{TARGET_DIR}/benchmark.cr", cr_content)

      rb_content = <<-EOL
      #{FILE_HEADER}
      require 'benchmark'
      require 'sha3'

      inputs = %w(#{inputs.join(" ")})

      print "Ruby:    "
      puts Benchmark.measure {
        #{NUM_ITERATIONS}.times do
          inputs.each do |i|
            SHA3::Digest.hexdigest(:sha512, i)
          end
        end
      }
      EOL

      File.write("#{TARGET_DIR}/benchmark.rb", rb_content)
    end
  end
end

BenchmarkGenerator.clear_target_dir
BenchmarkGenerator.generate
