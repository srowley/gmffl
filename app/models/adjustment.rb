class Adjustment < ApplicationRecord

  belongs_to :franchise

  def self.import_xml(league)
    Adjustment.delete_all
    doc = Nokogiri::XML(open(league.adjustments_url))
    adjustment_records = []
    adjustment_nodes = doc.xpath("//salaryAdjustment[@timestamp>1520013527]")
    adjustment_nodes.each do |a|
      adjustment_records << self.new(amount:             a["amount"].to_i,
                                     description:        a["description"],
                                     franchise_id:       a["franchise_id"])
      end
    self.import adjustment_records
  end
end
