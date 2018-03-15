class Dominoes

  def self.chain(dominoes_array)
    return [] if dominoes_array.empty?
    return single_play(dominoes_array.first) if dominoes_array.length == 1

    grouped_by_number = dominoes_array.flatten.group_by{|x| x}.flatten

    number_matches =  grouped_by_number.select{|y| y.is_a?(Array) }

    return [] unless number_matches.present?

    @original_dominoes = dominoes_array.collect{|d| Dominoe.new(d[0], d[1])}

    merge_matches(number_matches, @original_dominoes.clone)
  end

  def self.merge_matches(number_matches, cloned_dominoes)
    chained_list = extract_pair(number_matches.pop[0], cloned_dominoes)
    return nil if chained_list.nil?

    number_matches.each do |match|
      chained_list.merge(extract_pair(match[0], cloned_dominoes), cloned_dominoes)
    end

    while popped = cloned_dominoes.pop do
      chained_list = chained_list.try_adding(popped)
    end

    chained_list.dominoes if success(chained_list.dominoes)
  end

  def self.success(chain)
    chain&.length == @original_dominoes.length
  end

  def self.extract_pair(number, dominoes)
    matching = dominoes.select { |dom| dom.has_number?(number) }
    return nil if matching.size < 2
    first = dominoes.delete(matching[0])
    second = dominoes.delete(matching[1]) || first
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
    end
  end
end


class DominoeChain

  attr_reader :dominoes

  def initialize(dominoes)
    @dominoes = dominoes
  end

  def left_end
    dominoes.first.left
  end

  def right_end
    dominoes.last.right
  end

  def merge(new_dominoe_chain, dominoe_stack)
    return if new_dominoe_chain.nil?

    if right_end == new_dominoe_chain.left_end
      @dominoes += new_dominoe_chain.dominoes
    elsif right_end == new_dominoe_chain.right_end
      @dominoes += new_dominoe_chain.dominoes.reverse
    elsif left_end == new_dominoe_chain.left_end
      @dominoes = @dominoes.reverse += new_dominoe_chain.dominoes
    elsif left_end == new_dominoe_chain.right_end
      @dominoes = @dominoes.reverse += new_dominoe_chain.dominoes.reverse
    else
      # if you can't merge them put them back
      dominoe_stack += new_dominoe_chain.dominoes
    end
  end

  def try_adding(dominoe)
    if dominoe.left == right_end
      @dominoes = dominoes << dominoe
    elsif dominoe.right == right_end
      @dominoes = dominoes << dominoe.reverse
    # Not sure why the rules don't allow adding to the start
    # elsif dominoe.left == dominoes.left
      # dominoes =  dominoes << self.reverse
    #   return dominoes.insert(0, dominoe.reverse)
    # elsif dominoe,right == dominoes.left_end
    #   return dominoes.insert(0, dominoe)
    end
    self
  end

end

