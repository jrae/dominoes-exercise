class Dominoes

  def self.chain(dominoes_array)
    return [] if dominoes_array.empty?
    return single_play(dominoes_array.first) if dominoes_array.length == 1

    number_match =  dominoes_array.flatten.group_by{|x| x}.flatten.select{|y| y.is_a?(Array)}.sort_by(&:size).last

    return [] unless number_match.present?

    dominoes = dominoes_array.collect{|d| Dominoe.new(d[0], d[1])}
    attempt_complete_chain(dominoes, number_match[0])
  end

  def self.attempt_complete_chain(dominoes, number, attempt=0)
    doms = dominoes.clone

    puts "number #{number}"

    chained_list = start_chain(number, doms, attempt)
    return nil if chained_list.empty?

    doms -= chained_list

    while popped = doms.pop do
      puts "popped #{popped}"
      puts "chained #{chained_list}"
      puts "doms #{doms}"
      chained_list = popped.add_to_chain(chained_list)
    end

    # if chained_list&.length != dominoes.length
    #   return attempt_complete_chain(dominoes, number, attempt+1)
    # end

    chained_list
  end

  def self.start_chain(number, dominoes, offset)
    matching = dominoes.select { |dom| dom.has_number?(number) }
    return [] if matching.size + offset < 2
    matching[0 + offset].new_chain(matching[1 + offset])
  end

  def self.single_play(dominoe)
    return [dominoe] if dominoe[0] == dominoe[1]
  end

end

class Dominoe < Struct.new(:left, :right)

  def first
    left
  end

  def last
    right
  end

  def is_double?
    left == right
  end

  def reverse
    Dominoe.new(right, left)
  end

  def has_number?(num)
    left == num || right == num
  end

  def add_to_chain(dominoes)
    puts "add_to_chain #{self}"
    puts "current_ch #{dominoes}"
    if left == dominoes.last.right
      dominoes = dominoes << self
    elsif right == dominoes.last.right
      dominoes =  dominoes << self.reverse

    # elsif left == dominoes.first.left
    #   return dominoes.insert(0, self.reverse)
    # elsif right == dominoes.first.left
    #   return dominoes.insert(0, self)
    end

    dominoes
  end

  def new_chain(other_dominoe)
    if right == other_dominoe.left
      [self, other_dominoe]
    elsif right == other_dominoe.right
      [self, other_dominoe.reverse]
    elsif left == other_dominoe.left
      [self.reverse, other_dominoe]
    elsif left == other_dominoe.right
      [self.reverse, other_dominoe.reverse]
    else
      nil
    end

  end
end

