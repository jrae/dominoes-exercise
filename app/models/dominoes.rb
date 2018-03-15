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
      return result if success(result)
    end
    return nil
  end

  def self.success(chain)
    chain&.length == @dominoes.length
  end

  def self.attempt_complete_chain(cloned_dominoes, matches)

    puts "matching numbers #{matches}"

    chained_list = start_chain(matches[0], cloned_dominoes)

    return nil if chained_list.nil?

    while popped = cloned_dominoes.pop do
      # puts "popped #{popped}"
      # puts "chained #{chained_list}"
      # puts "cloned_dominoes #{cloned_dominoes}"
      chained_list = chained_list.add(popped)
    end

    # if !success(chained_list) && matches.length > 2 && matches.length > attempt
    #   return attempt_complete_chain(@dominoes.clone, matches)
    # end

    chained_list.dominoes_chain
  end

  def self.start_chain(number, dominoes)
    matching = dominoes.select { |dom| dom.has_number?(number) }
    return nil if matching.size < 2
    first = dominoes.delete(matching[0])
    second = dominoes.delete(matching[1])
    first.new_chain(second)
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

  def new_chain(other_dominoe)
    if right == other_dominoe.left
      DominoeChain.new([self, other_dominoe])
    elsif right == other_dominoe.right
      DominoeChain.new([self, other_dominoe.reverse])
    elsif left == other_dominoe.left
      DominoeChain.new([self.reverse, other_dominoe])
    elsif left == other_dominoe.right
      DominoeChain.new([self.reverse, other_dominoe.reverse])
    else
      nil
    end
  end
end


class DominoeChain

  attr_reader :dominoes_chain

  def initialize(dominoes)
    @dominoes_chain = dominoes
  end

  def left_end
    dominoes_chain.first.left
  end

  def right_end
    dominoes_chain.last.right
  end

  def reverse
    DominoeChain.new(dominoes_chain.reverse)
  end

  def merge(other_dominoe_chain)
    if right_end == other_dominoe_chain.left_end
      DominoeChain.new(dominoes_chain + other_dominoe_chain.dominoes_chain)
    elsif right == other_dominoe_chain.right
      DominoeChain.new(dominoes_chain + other_dominoe_chain.dominoes_chain.reverse)
    elsif left == other_dominoe_chain.left
      DominoeChain.new(dominoes_chain.reverse + other_dominoe_chain.dominoes_chain)
      [self.reverse, other_dominoe_chain]
    elsif left == other_dominoe_chain.right
      DominoeChain.new(dominoes_chain.reverse + other_dominoe_chain.dominoes_chain.reverse)
    else
      nil
    end
  end

  def add(dominoe)
    if dominoe.left == right_end
      @dominoes_chain = dominoes_chain << dominoe
    elsif dominoe.right == right_end
      @dominoes_chain = dominoes_chain << dominoe.reverse
    # Not sure why the rules don't allow adding to the start
    # elsif dominoe.left == dominoes.left
      # dominoes_chain =  dominoes_chain << self.reverse
    #   return dominoes_chain.insert(0, dominoe.reverse)
    # elsif dominoe,right == dominoes.left_end
    #   return dominoes_chain.insert(0, dominoe)
    end
    self
  end

end

