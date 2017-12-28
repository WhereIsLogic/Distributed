using Graphs

left = true
global leader = 0

function zad2(n)

    channels = [Channel{Tuple{Int, Int}}(n) for i=1:n]

    p = zeros(n)
    for i in 1:n
        x = rand(1:n^2)
        while x in p
            x = rand(1:n^2)
        end
        p[i] = x
    end

    println(p)

    g = simple_graph(n,  is_directed=false)
    v = sort(vertices(g))

    for i in 1:n
        if i != n
            add_edge!(g, v[i], v[i+1])
        else
            add_edge!(g, v[i], v[1])
        end
    end

    @sync for i = 1:n
      @async findLeader(i, channels, g, p, n)
    end
    println("LEADER: ", leader)
end


function findLeader(id, channels, g, p, n)

    global leader
    neighbours = out_neighbors(id, g)
    ngh = in_edges(id, g)
    neighbour = 0

    if (id-1)%n == 0
        neighbour = source(ngh[2], g)
    elseif left == true && (id-1)%n != 0
        neighbour = source(ngh[1], g)
    elseif left == false && (id-1)%n != 0
        neighbour = source(ngh[2], g)
    end
    println("N: ", neighbour)

    put!(channels[neighbour], (p[neighbour], id))

    while true
      (msg, senderId) = take!(channels[id])
      if msg == -1
          put!(channels[neighbour], (-1, id))
          break
      end
      println("MSG: ", msg, " ", "NGH: ", p[neighbour])
      if msg > p[id]
          put!(channels[neighbour], (msg, id))
      elseif msg < p[neighbour]
      else
        put!(channels[neighbour], (-1, id))
        leader = p[id]
        break
      end
    end
end

n = 5
zad2(n)
