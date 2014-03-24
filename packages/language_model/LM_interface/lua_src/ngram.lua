get_table_from_dotted_string("ngram", true)

-- Auxiliar functions
local function exp10(value)
  return math.pow(10, value)
end

local function log10(value)
  return math.log(value) / math.log(10)
end

local function print_pw(flog, lastword, previousword, ngram_value, p)
  fprintf (flog, "\tp( %s | %s %s", lastword, previousword,
	   (ngram_value > 2 and "...") or "")
  fprintf (flog, ")\t= [%dgram] %g [ %f ]\n",
	   ngram_value, exp10(p), p)
end

function language_models.get_sentence_prob(lm, vocab, words, flog, debug_flag,
				 unk_id, init_id,
				 use_unk, use_bcc, use_ecc)
  local lmi = lm:get_interface()
  if use_unk == "none" then unk_id = -1 end
  local flog       = flog       or io.stdout
  local debug_flag = debug_flag or 0
  local word_ids
  word_ids = vocab:searchWordIdSequence(words, unk_id)
  local key
  if use_bcc then key = lmi:get_initial_key()
  else key = lmi:get_zero_key() end
  local result
  local sum      = 0
  local p
  local numwords    = #word_ids
  local ngram_value = order or lm:ngram_order()
  local numunks     = 0
  --if not unk_smooth then unk_smooth = 0 else
  --  unk_smooth        = log10(unk_smooth)
  --end
  local ini = 1
  local lastunk = -ngram_value
  local not_used_words = 0

  assert(lm:is_deterministic(),
         "Error: Expected a deterministic LM")

  for i=1,numwords do
    if word_ids[i] == -1 then
      numunks = numunks + 1
      lastunk = i
      key = lmi:get_zero_key()
    elseif i - lastunk >= ngram_value then
	result = lmi:get(key, word_ids[i])
	key,p = result:get(1)
      if word_ids[i] == unk_id then
	numunks = numunks + 1
      end
      if not is_stream or i >= ngram_value then
	--if use_unk == "all" then
	  p   = p / math.log(10)
	  sum = sum + p
	  if debug_flag >= 2 then
	    print_pw(flog,
		     (word_ids[i] ~= unk_id and words[i]) or "<unk>",
		     ((word_ids[i-1] ~= unk_id and words[i-1]) or words[i-1]) or "<s>",
		     ngram_value, p)
	  end
	--end
      end
    else
      result = lmi:get(key, word_ids[i])
      key,p = result:get(1)
      not_used_words = not_used_words + 1
    end
  end
  if use_unk ~= "all" then
    numwords = numwords - numunks - not_used_words
  end
  if not is_stream then
    if use_ecc then
      result = lmi:get(key, final_id)
      _,p = result:get(1)
      p   = p / math.log(10)
      sum = sum + p
      
      local last = #word_ids
      if debug_flag >= 2 then
	print_pw(flog,
		 "</s>",  
		 ((word_ids[last] ~= unk_id and words[last]) or words[last]) or "<s>",
		 ngram_value, p)
      end
    end
  else
    numwords = numwords - ngram_value + 1
  end
  
  if debug_flag >= 1 then
    fprintf (flog, "%d sentences, %d words, %d OOVs\n",
	     1, numwords, numunks)
    fprintf (flog, "0 zeroprobs, logprob= %.4f ppl= %.3f ppl1= %.3f\n",
	     sum,
	     exp10(-sum/(numwords+ ((use_ecc and 1) or 0) )),
	     exp10(-sum/numwords))
    fprintf (flog, "\n")
  end
  flog:flush()
  return sum,numwords,numunks
end

function language_models.get_prob_from_id_tbl(lm, word_ids, init_id, final_id,
				    use_bcc, use_ecc)
  local lmi = lm:get_interface()
  local key = lmi:get_initial_key()
  if not use_bcc then key = lmi:get_zero_key() end
  local sum      = 0
  local result
  local p
  local numwords    = #word_ids
  local ngram_value = lm:ngram_order()
  for i=1,numwords do
    if word_ids[i] ~= 0 then
      result = lmi:get(key, word_ids[i])
      assert(result:size() == 1,
             "Error: Expected a deterministic LM")
      key,p = result:get(1)
      sum = sum + p
    end
  end
  if use_ecc then
    result = lmi:get(key, final_id)
    assert(result:size() == 1,
           "Error: Expected a deterministic LM")
    _,p = result:get(1)
    sum = sum + p
  end
  return sum
end

function language_models.test_set_ppl(lm, vocab, testset, flog, debug_flag,
			    unk_word, init_word, final_word,
			    is_stream,
			    use_unk,
			    use_cache,
			    train_restriction,
			    cache_stop_token,
			    null_token,
			    order,
			    use_bcc,
			    use_ecc,
			    multi_class_table,
			    num_classes)

  local unk_id = -1
  if vocab:getWordId(unk_word) then unk_id = vocab:getWordId(unk_word) end
  
  local lines_it = iterator(io.lines("frase")):
  map( function(line) return iterator(line:gmatch("[^%s]+")) end )
  --[[
  for words_it in lines_it() do
    words_it:map( function(w) return vocab:getWordId(w) or unk_id end )
    ngram.get_sentence_prob( words_it, ... )
    -- dins del ngram:
    --   for word in words_it() do ... end
  end
  --]]

  local multi_class_table_inv
  if multi_class_table then
    multi_class_table_inv = table.invert(multi_class_table)
  end
  local totalwords     = 0
  local totalsentences = 0
  local totalunks      = 0
  local totalsum       = 0
  local unk_word       = unk_word or "<unk>"
  local init_word      = init_word or "<s>"
  local final_word     = final_word or "</s>"
  local unk_id         = -1
  if vocab:getWordId(unk_word) then unk_id = vocab:getWordId(unk_word) end
  local init_id  = vocab:getWordId(init_word)
  local final_id = vocab:getWordId(final_word)
  -- lm:restart()
  local count = 0
  for sentence in io.lines(testset) do
    local words = string.tokenize(sentence)
    local use_sentence = true
    if train_restriction then
      if words[1] ~= "<train>" then use_sentence = false end
      table.remove(words, 1)
    end
    if use_sentence then
      count = count + 1
      if #sentence > 0 and #words > 0 then
	if debug_flag >= 1 then fprintf(flog, "%s\n", sentence) end
	local sum,numwords,numunks =
	  ngram.get_sentence_prob(lm, vocab, words, flog, debug_flag,
				  unk_id, init_id, final_id,
				  is_stream, use_unk, order,
				  use_bcc, use_ecc,
				  multi_class_table,
				  multi_class_table_inv,
				  num_classes)
	totalsum       = totalsum + sum
	totalwords     = totalwords + numwords
	totalunks      = totalunks + numunks
	totalsentences = totalsentences + 1
      end
      -- if use_cache or math.mod(count, 1000) == 0 then lm:restart() end
      -- if use_cache then lm:restart() end
    end
    if use_cache then
      local word_ids
      word_ids = vocab:searchWordIdSequence(words, unk_id)
      for i=1,#word_ids do
	if words[i] == cache_stop_token then
	  lm:clearCache()
	elseif words[i] ~= null_token then
	  lm:cacheWord(word_ids[i])
	end
      end
      --lm:showCache()
    end
  end
  -- lm:restart()
  local entropy  = -totalsum/(totalwords + ((use_ecc and totalsentences) or 0))
  local ppl      = exp10(entropy)
  local entropy1 = -totalsum/totalwords
  local ppl1     = exp10(entropy1)

  if is_stream then ppl = ppl1 entropy = entropy1 end
  
  if debug_flag >= 0 then
    fprintf (flog, "file %s: %d sentences, %d words, %d OOVs\n",
	     testset,
	     totalsentences,
	     totalwords,
	     totalunks)
    flog:flush()
    fprintf (flog,
	     "0 zeroprobs, logprob= %f ppl= %f ppl1= %f\n",
	     totalsum,
	     ppl, ppl1)
    flog:close()
  end
  
  return {
    ppl          = ppl,
    ppl1         = ppl1,
    logprob      = totalsum,
    numwords     = totalwords,
    numunks      = totalunks,
    numsentences = totalsentences,
  }
end
