class Dominoes

  def self.chain(dominoes_array)
    return [] if dominoes_array.empty?
    return single_play(dominoes_array.first) if dominoes_array.length == 1

    number_matches =  dominoes_array.flatten.group_by{|x| x}.flatten.select{|y| y.is_a?(Array)}.sort_by(&:size)

    return [] unless number_matches.present?

    @dominoes = dominoes_array.collect{|d| Dominoe.new(d[0], d[1])}

    loop_matches(number_matches)
  end

  def self.loop_matches(number_matches)
    number_matches.each do |first_match|
      result = attempt_complete_chain(@dominoes.clone, first_match)
      return result if result&.length == @dominoes.length
    end
    return nil
  end

  def self.attempt_complete_chain(cloned_doms, matches)

    # puts "matching numbers #{matches}"

    chained_list = start_chain(matches[0], cloned_doms)

    return nil if chained_list.empty?

    while popped = cloned_doms.pop do
      # puts "popped #{popped}"
      # puts "chained #{chained_list}"
      # puts "cloned_doms #{cloned_doms}"
      chained_list = popped.add_to_chain(chained_list)
    end

    # if chained_list&.length != @dominoes.length && matches.length > 2
    #   return attempt_complete_chain(dominoes, number, attempt+1)
    # end

    chained_list
  end

  def self.start_chain(number, dominoes)
    matching = dominoes.select { |dom| dom.has_number?(number) }
    return [] if matching.size < 2
    first = matching[0]
    second = matching[1]
    chain = first.new_chain(second)
    dominoes.delete(first)
    dominoes.delete(second)
    chain
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
    # puts "add_to_chain #{self}"
    # puts "current_ch #{dominoes}"
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

