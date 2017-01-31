require "./spec_helper"

module KeccakSpec
  Spec2.describe "SHA3 basic tests" do
    context "basic tests" do
      it "passes for the empty string" do
        expect(Digest::SHA3.hexdigest("")).to eq("a69f73cca23a9ac5c8b567dc185a756e97c982164fe25859e0d1dcc1475c80a615b2123af1f5f94c11e3e9402c3ac558f500199d95b6d3e301758586281dcd26")
      end

      it "passes for a common pangram" do
        expect(Digest::SHA3.hexdigest("The quick brown fox jumps over the lazy dog")).to eq("01dedd5de4ef14642445ba5f5b97c15e47b9ad931326e4b0727cd94cefc44fff23f07bf543139939b49128caf436dc1bdee54fcb24023a08d9403f9b4bf0d450")
        end
    end

    context "readme example" do
      let(:str) { "abc123" }

      it "passes for the 512-bit example" do
        expect(Digest::SHA3.hexdigest(str)).to eq("3274f8455be84b8c7d79f9bd93e6c8520d13f6bd2855f3bb9c006ca9f3cce25d4b924d0370f8af4e27a350fd2baeef58bc37e0f4e4a403fe64c98017fa012757")
      end

      it "passes for the 256-bit example" do
        inst = Digest::SHA3.new(256)
        inst.update(str)
        expect(inst.hexdigest).to eq("f58fa3df820114f56e1544354379820cff464c9c41cb3ca0ad0b0843c9bb67ee")
      end
    end

    # The below solutions are from:
    # http://research.omicsgroup.org/index.php/SHA-3#Examples_of_SHA-3_and_Keccak_variants
    EMPTY_STR_SOLUTIONS = [
      "6b4e03423667dbb73b6e15454f0eb1abd4597f9a1b078e3f5b5a6bc7",
      "a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a",
      "0c63a75b845e4f7d01107d852e4c2485c51a50aaaa94fc61995e71bbee983a2ac3713831264adb47fb6bd1e058d5f004",
      "a69f73cca23a9ac5c8b567dc185a756e97c982164fe25859e0d1dcc1475c80a615b2123af1f5f94c11e3e9402c3ac558f500199d95b6d3e301758586281dcd26"
    ]

    it "passes for the empty string with different hash sizes" do
      Digest::SHA3::HASH_SIZES.each_with_index do |hs, i|
        inst = Digest::SHA3.new(hs)
        inst.update("")
        expect(inst.hexdigest).to eq(EMPTY_STR_SOLUTIONS[i])
      end
    end
  end
end
