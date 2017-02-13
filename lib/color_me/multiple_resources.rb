module ColorMe
  module MultipleResources
    def max_limit
      50
    end

    def get(params={})
      case params
      when Hash
        return get_with_params(params)
      when Fixnum
        return get_with_id(params)
      end
    end

    def put(params=[0,""])
      case params.first
      when Fixnum
        return put_with_id(params)
      else
        raise "no Fixnum params"
      end
    end

    def method_missing(method, *args)
      if method.match(/^(.*)_with_id/)
        action_with_id(args.first, $1)
      end
    end
    
    private

    
    def get_with_params(params)
      res = partial_get(params)
      total = [res[:meta][:total], params[:limit]].reject(&:nil?).min

      while res[collection_key].size < total do
        limit = [max_limit, total - res[collection_key].size].min
        offset = res[collection_key].size
        new_res = partial_get(params.merge(limit: limit, offset: offset))
        res[collection_key] += new_res[collection_key]
      end
      res
    end

    def partial_get(params={})
      action_url(endpoint + ColorMe.build_query(params))
    end

    def endpoint_with_id(id)
      dirname  = File.join(File.dirname(endpoint), File.basename(endpoint, ".*"))
      filename = id.to_s + File.extname(endpoint)
      File.join(dirname, filename)
    end
    
    def action_with_id(params, method = "get")
      case method
      when "get"
        action_url(endpoint_with_id(params), method)
      when "put"
        action_url(endpoint_with_id(params.first), method, params[1])
      end

    end


    
    def action_url(url, method = "get", params = nil)
      if params.nil?
        res = ColorMe.api.send(method, url)        
      else
        res = ColorMe.api.send(method, url, {params: params})
      end

      ColorMe.parse_json(res.body)
    end
  end
end

