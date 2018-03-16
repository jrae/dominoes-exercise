class Dominoes

  def self.chain(dominoes_array)
    return [] if dominoes_array.empty?
    return single_play(dominoes_array.first) if dominoes_array.length == 1

    grouped_by_number = dominoes_array.flatten.group_by{|x| x}.flatten

    number_matches =  grouped_by_number.select{|y| y.is_a?(Array) }
    # .sort_by{|arr| arr.length}

    return [] unless number_matches.present?

    @original_dominoes = dominoes_array.collect.with_index do |d, index|
      Dominoe.new(d[0], d[1])
    end

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
    matching = dominoes.collect.with_index { |dom, index| [dom, index] if dom.has_number?(number) }.compact
    return nil if matching.size < 2
    first = dominoes.delete_at(matching[1][1])
    second = dominoes.delete_at(matching[0][1])
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

  def reversed_dominoes
    dominoes.inject([]) { |res, dom| res.insert(0, dom.reverse)}
  end

  def merge(new_dominoe_chain, dominoe_stack)
    return if new_dominoe_chain.nil?

    if right_end == new_dominoe_chain.left_end
      @dominoes += new_dominoe_chain.dominoes
    elsif right_end == new_dominoe_chain.right_end
      @dominoes += new_dominoe_chain.reversed_dominoes
    elsif left_end == new_dominoe_chain.left_end
      @dominoes = @dominoes.reverse += new_dominoe_chain.dominoes
    elsif left_end == new_dominoe_chain.right_end
      @dominoes = @dominoes.reverse += new_dominoe_chain.reversed_dominoes
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
    # elsif dominoe.left == left_end
    #   @dominoes = dominoes.insert(0, dominoe.reverse)
    # elsif dominoe.right == left_end
    #   @dominoes = dominoes.insert(0, dominoe)
    end
    self
  end

end

