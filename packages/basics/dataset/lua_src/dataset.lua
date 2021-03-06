function dataset.to_fann_file_format(input_dataset, output_dataset)
  local numpat = input_dataset:numPatterns()
  if (output_dataset:numPatterns() ~= numpat) then
    error("dataset.to_fann_file_format input and output dataset has different number of patterns")
  end
  local resul = {}
  table.insert(resul,string.format("%d %d %d",numpat,
			       input_dataset:patternSize(),
			       output_dataset:patternSize()))
  for i=1,numpat do
    table.insert(resul,table.concat(input_dataset:getPattern(i)," "))
    table.insert(resul,table.concat(output_dataset:getPattern(i)," "))
  end
  return table.concat(resul,"\n")
end

function dataset.create_fann_file(filename, input_dataset, output_dataset)
  local str  = dataset.to_fann_file_format(input_dataset,output_dataset)
  local fich = io.open(filename,"w")
  fich:write(str)
  fich:close()
end

-----------------------------------------------------------------------------

local lua_filter,lua_filter_methods = class("dataset.token.lua_filter")
get_table_from_dotted_string("dataset.token", true) -- global environment
dataset.token.lua_filter = lua_filter -- global environment

function lua_filter:constructor(t)
  local params = get_table_fields({
				    dataset = { mandatory=true },
				    filter  = { mandatory=true,
						type_match="function" },
				  }, t)
  self.ds=params.dataset
  self.filter=params.filter
  if class.is_a(ds,dataset) then self.ds = dataset.token_wrapper(self.ds) end
end

function lua_filter_methods:numPatterns() return self.ds:numPatterns() end

function lua_filter_methods:patternSize() return self.ds:patternSize() end

function lua_filter_methods:getPattern(idx)
  local output = self.filter( self.ds:getPattern(idx) )
  assert( class.is_a(output,token.base), "The output of the filter must be a token")
  return output
end

function lua_filter_methods:getPatternBunch(idxs)
  local output = self.filter( self.ds:getPatternBunch(idx) )
  assert( class.is_a(output,token.base), "The output of the filter must be a token")
  return output
end
