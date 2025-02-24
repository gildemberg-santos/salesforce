class String
  def to_bool
    return false if self == false || blank? || self =~ /^(false|f|no|n|0|não|nao)$/i
    return true if self == true || self =~ /^(true|t|yes|y|1|sim|s)$/i

    nil
  end
end

class NilClass
  def to_bool
    nil
  end
end

class TrueClass
  def to_bool
    true
  end
end

class FalseClass
  def to_bool
    false
  end
end
