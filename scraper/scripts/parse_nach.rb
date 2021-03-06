require 'nokogiri'
require 'json'
require 'uri'

doc = Nokogiri::HTML(open('nach.html'))

header_cleared = false

banks = Hash.new

# These are invalid sublets
# given out by RBI
# because they result in 1 bank
# having 2 different codes
IGNORED_SUBLETS = [
  # Typo? in this one (AKJB|AJKB)
  'AKJB0000001',
  # DLSC and DSCB are the same
  'DLSC0000001',
  # FIRN and FIRX are the same
  'FIRN0000001',
  # KANG and KCOB are the same
  'KANG0000001',
  # SJSB and SJSX are the same
  'SJSB0000001',
  # SKSB and SHKX are the same
  'SKSB0000001',
  # UFSB and UJVN are the same
  'UJVN0000001',
  # PKGB and PKGX are the same
  'PKGB0000001',
]

doc.css('table')[0].css('tr').each do |row|
    if header_cleared
        data = row.css('td')
        ifsc = data[4].text.strip
        bank_code = data[1].text.strip
        if ifsc.size == 11 and ifsc[0..3] != bank_code and IGNORED_SUBLETS.include?(ifsc)==false
            banks[ifsc] = bank_code
        end
    end
    header_cleared = true
end

File.open("../../src/sublet.json", "w") do |f|
    f.write JSON.pretty_generate(Hash[banks.sort])
end
