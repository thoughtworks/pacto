module Pacto
  class HashMergeProcessor
    def process(contract, values)
      unless values.nil?
        response_body = contract.response_body
        if response_body.respond_to?(:normalize_keys)
          contract.response_body = response_body.normalize_keys.deep_merge(values.normalize_keys)
        else
          contract.response_body = values
        end
      end
      contract
    end
  end
end