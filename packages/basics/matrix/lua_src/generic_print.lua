-- GENERIC PRINT FUNCTION
matrix.__make_generic_print__ = function(name,getter)
  assert(name and getter)
  return function(self)
    local dims   = self:dim()
    local major  = (self.get_major_order and self:get_major_order()) or "row_major"
    local coords = {}
    local out    = {}
    local row    = {}
    local so_large = false
    for i=1,#dims do 
      coords[i]=1
      if dims[i] > 20 then so_large = true end
    end
    if not so_large then
      for i=1,self:size() do
	if #dims > 2 and coords[#dims] == 1 and coords[#dims-1] == 1 then
	  table.insert(out,
		       string.format("\n# pos [%s]",
				     table.concat(coords, ",")))
	end
	table.insert(row, getter(self:get(table.unpack(coords))))
	local j=#dims+1
	repeat
	  j=j-1
	  coords[j] = coords[j] + 1
	  if coords[j] > dims[j] then coords[j] = 1 end
	until j==1 or coords[j] ~= 1
	if coords[#coords] == 1 then
	  table.insert(out, table.concat(row, " ")) row={}
	end
      end
    else
      table.insert(out, "Large matrix, not printed to display")
    end
    table.insert(out, string.format("# %s of size [%s] in %s [%s]\n",
				    name,
				    table.concat(dims, ","), major,
				    self:get_reference_string()))
    return table.concat(out, "\n")
  end
end
