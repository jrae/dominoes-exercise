class Dominoes

  def self.chain(dominoes_array)
    return [] if dominoes_array.empty?
    return single_play(dominoes_array.first) if dominoes_array.length == 1

    # potential optimisation but not necassary
    # number_matches = dominoes_array.flatten.group_by{|x| x}.flatten.select{|y| y.is_a?(Array) }
    # return [] unless number_matches.present?

    dominoes = dominoes_array.collect.with_index do |d, index|
      Dominoe.new(d[0], d[1])
    end

    @original_length = dominoes.length

    insertion_sort(dominoes)
  end

  def self.insertion_sort(dominoes)
    dominoe_chains = []
    while popped = dominoes.pop do
      dominoe_chains = add_dominoe_to_chains(popped, dominoe_chains)
    end
    return merge_chains(dominoe_chains)&.dominoes
  end

  def self.merge_chains(dominoe_chains)
    while result = dominoe_chains.pop do
      if dominoe_chains.any?
        merge_result_into_chains(result, dominoe_chains)
      else
        return result if success(result)
      end
    end
  end

  def self.merge_result_into_chains(chain_to_merge, other_chains)
    other_chains.each do |chain|
      break if chain.merge!(chain_to_merge)
    end
    other_chains
  end

  def self.add_dominoe_to_chains(dom, chains)
    added_to_chain = false
    chains.each do |chain|
      added_to_chain = chain.try_adding(dom)
      break if added_to_chain
    end
    chains << DominoeChain.new([dom]) unless added_to_chain
    chains
  end

  def self.success(chain)
    chain.dominoes.length == @original_length
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

  def merge!(new_dominoe_chain)
    return if new_dominoe_chain.nil?

    if right_end == new_dominoe_chain.left_end
      @dominoes += new_dominoe_chain.dominoes
    elsif right_end == new_dominoe_chain.right_end
      @dominoes += new_dominoe_chain.reversed_dominoes
    elsif left_end == new_dominoe_chain.left_end
      @dominoes = reversed_dominoes + new_dominoe_chain.dominoes
    elsif left_end == new_dominoe_chain.right_end
      @dominoes = reversed_dominoes + new_dominoe_chain.reversed_dominoes
    # else
      # if you can't merge them put them back
      # dominoe_stack += new_dominoe_chain.dominoes
    end
  end

  def try_adding(dominoe)
    if dominoe.left == right_end
      @dominoes = dominoes << dominoe
    elsif dominoe.right == right_end
      @dominoes = dominoes << dominoe.reverse
    elsif dominoe.left == left_end
      @dominoes = dominoes.insert(0, dominoe.reverse)
    # Not sure why the rules don't allow adding to the start
    # elsif dominoe.right == left_end
    #   @dominoes = dominoes.insert(0, dominoe)
    else
      return nil
    end
    self
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

end

