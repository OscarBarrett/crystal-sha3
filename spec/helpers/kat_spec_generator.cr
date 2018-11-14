# Generates specs that check against the KAT data for Keccak3 and SHA3
# Keccak3 KAT data is from: http://keccak.noekeon.org/KeccakKAT-3.zip
# SHA3 KAT data is from:    https://github.com/gvanas/KeccakCodePackage/tree/master/TestVectors
module KATSpecGenerator
  TARGET_DIR = "spec/generated"

  def self.clear_target_dir
    print "Clearing target directory..."
    Dir.mkdir TARGET_DIR unless File.exists?(TARGET_DIR)

    Dir[TARGET_DIR + "/*"].each do |path|
      File.delete("#{path}")
    end

    puts "done"
  end

  def self.generate(data_dir, digest_klass)
    print "Generating KAT specs for Digest::#{digest_klass}..."

    Dir[data_dir + "/*"].each do |path|
      next if path =~ /ExtremelyLongMsg/ # Skipped for now.

      name = File.basename path, ".txt"
      hash_length = path.split('_')[1].split('.')[0]

      test_content = String.new

      contents = File.read("#{path}").split("Len = ")
      contents.each do |test|
        lines = test.split("\n")

        if !lines.empty? && lines[0] !~ /^#/
          length = lines[0].to_i
          if length % 8 == 0
            update_param = %{""}
            if length != 0
              update_param = %{"#{[lines[1].split(" = ").last][0]}".hexbytes}
            end

            md = lines[2].split(" = ").last.downcase
            test_name = "test_#{name}_#{length}"

            # define_test(test_name, hash_length, msg_raw, md)
            test_content += <<-EOL
              it "passes for length #{length}" do
                inst = Digest::#{digest_klass}.new(#{hash_length}_u32)
                inst.update(#{update_param})
                result = inst.hexdigest

                expect("#{md}").to eq(result)
              end
            \n
            EOL
          end
        end
      end

      if test_content.size > 0
        # Wrap the test content in the necessary outer blocks
        test_content = <<-EOL
        # Generated by #{__FILE__.sub(/.*?(?=spec)/im, "")}
        # Do not modify directly.
        require "../spec_helper"

        Spec2.describe "#{digest_klass}_#{name}" do
        #{test_content}
        end
        EOL

        # Write the test content to file
        File.write(p("#{TARGET_DIR}/#{digest_klass}_#{name}_spec.cr"), test_content)
      end
    end

    puts "done"
  end
end

KATSpecGenerator.clear_target_dir
KATSpecGenerator.generate "spec/kat_data/keccak3", "Keccak3"
KATSpecGenerator.generate "spec/kat_data/sha3", "SHA3"
