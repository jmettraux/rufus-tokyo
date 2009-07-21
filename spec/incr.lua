
--
-- Taken from http://tokyocabinet.sourceforge.net/tyrantdoc/#luaext
--

function incr (key, value)
  value = tonumber(value)
  if not value then
    return nil
  end
  local old = tonumber(_get(key))
  if old then
    value = value + old
  end
  if not _put(key, value) then
    return nil
  end
  return value
end

function hi()
   return "Hi!"
end
