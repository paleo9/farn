# take an array, return a string of each 
# element separated by a comma

def to_csv(s_array)
  str = ""
  for i in 0..(s_array.length-1)
    str += s_array[i]
    if i < (s_array.length-1)
        str += ", "
    end
  end
  return str
end


