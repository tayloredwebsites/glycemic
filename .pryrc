
# turn off paging in pry using the PryByebug gem
# https://www.nikitakazakov.com/pry-debugging/
if defined?(PryByebug)
  Pry.config.pager = false
end