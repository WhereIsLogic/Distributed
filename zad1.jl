using Graphs

function rootProcess(id, channels, parents, children, g)
  #send search
  #root sends id to it's neighbours
  parents[id] = id
  neighbours = out_neighbors(id, g)
  for idn in neighbours
    put!(channels[idn], (:search, id))
  end
  rec = 0
  exp = 2*length(neighbours)
  while rec < exp
    (msg, senderId) = take!(channels[id])
    rec += 1
    if msg == :search
      put!(channels[senderId], (:goaway, id))
    elseif msg == :youAreMyFather
      push!(children[id], senderId)
    end
  end
end

function nodeProcess(id, channels, parents, children, g)
  #if received search for the first time from v
      # father = v
      # send search to neighbours
      # send "you are my father" do v
  #if w received "you are my parent" from w
      #children = children + {w}
  neighbours = out_neighbors(id, g)
  rec = 0
  exp = 2*length(neighbours)
  while rec < exp
    (msg, senderId) = take!(channels[id])
    rec += 1
      if msg == :search
        if parents[id] == 0
          put!(channels[senderId], (:youAreMyFather, id))
          parents[id] = senderId
          for idn in neighbours
            put!(channels[idn], (:search, id))
          end
        else
          put!(channels[senderId], (:goaway, id))
        end
      elseif msg == :youAreMyFather
        push!(children[id], senderId)
      end
    end
end

function zad1()
  n = 6
  g = simple_graph(n,  is_directed=false)

#  for i = 1 : n-1
#    x = rand(1:n)
#    y = rand(1:n)
#    if !has_edge(g, x, y) && !has_edge(g, y, x) && x != y
#      add_edge!(g, x, y)
#    end
#  end

  add_edge!(g, 1, 2)
  add_edge!(g, 1, 3)
  add_edge!(g, 3, 4)
  add_edge!(g, 3, 5)
  add_edge!(g, 5, 6)

  root = 1
  parents = zeros(n)
  children = [Set{Int}() for i=1:n]
  channels = [Channel{Tuple{Symbol, Int}}(out_degree(i, g)) for i=1:n]

  @sync for i = 1:n
    if i == root
      @async rootProcess(i, channels, parents, children, g)
    else
      @async nodeProcess(i, channels, parents, children, g)
    end
  end
  println("PARENTS:")
  println(parents)
  println("CHILDREN:")
  println(children)
end

zad1()
