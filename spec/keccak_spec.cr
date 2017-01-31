require "./spec_helper"

module KeccakSpec
  Spec2.describe "Keccak3 basic tests" do
    context "basic tests" do
      it "passes for the empty string" do
        expect(Digest::Keccak3.hexdigest("")).to eq("0eab42de4c3ceb9235fc91acffe746b29c29a8c366b7c60e4e67c466f36a4304c00fa9caf9d87976ba469bcbe06713b435f091ef2769fb160cdab33d3670680e")
      end

      it "passes for a common pangram" do
        expect(Digest::Keccak3.hexdigest("The quick brown fox jumps over the lazy dog")).to eq("d135bb84d0439dbac432247ee573a23ea7d3c9deb2a968eb31d47c4fb45f1ef4422d6c531b5b9bd6f449ebcc449ea94d0a8f05f62130fda612da53c79659f609")
      end
    end

    context "readme example" do
      let(:str) { "abc123" }

      it "passes for the 512-bit example" do
        expect(Digest::Keccak3.hexdigest(str)).to eq("17c4bf22aaa8fcd7ff070fd3435619b5666dc3eac901872c73f091d9f3753cd871161269f14741e3b263c616e9f4bb4314abcbb271b2796d14eb89434a0afd03")
      end

      it "passes for the 256-bit example" do
        inst = Digest::Keccak3.new(256)
        inst.update(str)
        expect(inst.hexdigest).to eq("719accc61a9cc126830e5906f9d672d06eab6f8597287095a2c55a8b775e7016")
      end
    end

    # The below solutions are from:
    #  http://research.omicsgroup.org/index.php/SHA-3#Examples_of_SHA-3_and_Keccak_variants
    EMPTY_STR_SOLUTIONS = [
      "f71837502ba8e10837bdd8d365adb85591895602fc552b48b7390abd",
      "c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470",
      "2c23146a63a29acf99e73b88f8c24eaa7dc60aa771780ccc006afbfa8fe2479b2dd2b21362337441ac12b515911957ff",
      "0eab42de4c3ceb9235fc91acffe746b29c29a8c366b7c60e4e67c466f36a4304c00fa9caf9d87976ba469bcbe06713b435f091ef2769fb160cdab33d3670680e"
    ]

    it "passes for the empty string with different hash sizes" do
      Digest::Keccak3::HASH_SIZES.each_with_index do |hs, i|
        inst = Digest::Keccak3.new(hs)
        inst.update("")
        expect(inst.hexdigest).to eq(EMPTY_STR_SOLUTIONS[i])
      end
    end
  end
end
