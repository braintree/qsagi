module Qsagi
  class JsonSerializer
    def self.deserialize(message)
      JSON.parse(message)
    end

    def self.serialize(message)
      JSON.unparse(message)
    end
  end
end
