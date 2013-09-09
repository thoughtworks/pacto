module Pacto
  class HashMergeProcessor
    def process(response_body, values = {})
      unless values.nil?
        if response_body.respond_to?(:normalize_keys)
          response_body = response_body.normalize_keys.deep_merge(values.normalize_keys)
        else
          response_body = values
        end
      end
      response_body.to_s
    end
  end
end