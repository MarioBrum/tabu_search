using Random

function readArq(path)
    open(path, "r") do f
        nroTarefas = 0
        nroOperadores = 0

        # Tenta encontrar as duas primeiras linhas com inteiros
        while !eof(f) && (nroTarefas == 0 || nroOperadores == 0)
            linha = readline(f)
            partes = split(linha)
            for p in partes
                try
                    n = parse(Int, p)
                    if nroTarefas == 0
                        nroTarefas = n
                    elseif nroOperadores == 0
                        nroOperadores = n
                    end
                    if nroTarefas != 0 && nroOperadores != 0
                        break
                    end
                catch
                end
            end
        end

        if nroTarefas == 0 || nroOperadores == 0
            error("Não foi possível encontrar nroTarefas e nroOperadores no arquivo.")
        end

        # read matrix
        p = zeros(Float64, nroOperadores, nroTarefas)
        i = 1
        while i <= nroOperadores && !eof(f)
            linha = readline(f)
            if isempty(linha) || occursin(r"[A-Za-z]", linha)
                continue
            end
            valores = try
                parse.(Float64, split(linha))
            catch
                continue
            end
            if length(valores) == nroTarefas
                p[i, :] .= valores
                i += 1
            end
        end

        return p
    end
end

function makespan(p::Matrix{Float64}, cuts::Vector{Int}, perm::Vector{Int})
    nroTarefas = size(p, 2)
    m = size(p, 1)

    if length(cuts) != m - 1
        error("Número de cortes inválido: esperava $(m - 1), recebeu $(length(cuts))")
    end
    if length(perm) != m
        error("Número de operadores inválido: esperava $m, recebeu $(length(perm))")
    end

    bounds = [1; cuts; nroTarefas + 1]
    times = Float64[]
    for k in 1:m
        start_idx = bounds[k]
        end_idx = bounds[k+1] - 1
        if start_idx > end_idx
            push!(times, 0.0)
        else
            push!(times, sum(p[perm[k], start_idx:end_idx]))
        end
    end

    return maximum(times), times
end

function tabu_search(p::Matrix{Float64}; max_iter=1000, tabu_tenure=5)
    nroTarefas = size(p, 2)
    m = size(p, 1)

    # Inicializa cortes uniformes (m-1 cortes)
    size_block = floor(Int, nroTarefas / m)
    cuts = collect(size_block:size_block:(size_block * (m - 1)))
    # Se faltar cortar no fim, corrige
    while length(cuts) < m - 1
        push!(cuts, nroTarefas - 1)
    end

    perm = shuffle(1:m)

    best_cuts = copy(cuts)
    best_perm = copy(perm)
    best_cost, _ = makespan(p, best_cuts, best_perm)

    tabu_cuts = Vector{Vector{Int}}()
    tabu_perm = Vector{Vector{Int}}()

    for iter in 1:max_iter
        best_neighbor = nothing
        best_neighbor_cost = Inf

        # Gera vizinhança: tenta mover cada corte +-1 e permutar operadores adjacentes
        for k in 1:length(cuts)
            for delta in [-1, 1]
                new_cuts = copy(cuts)
                new_cuts[k] += delta

                # Verifica se cortes estão em ordem e dentro dos limites
                if (k > 1 && new_cuts[k] <= new_cuts[k - 1]) || (k < length(cuts) && new_cuts[k] >= new_cuts[k + 1])
                    continue
                end
                if new_cuts[k] < 1 || new_cuts[k] > nroTarefas - 1
                    continue
                end

                # Tenta trocar operadores adjacentes na permutação
                for i in 1:(m - 1)
                    new_perm = copy(perm)
                    new_perm[i], new_perm[i + 1] = new_perm[i + 1], new_perm[i]

                    # Checa tabu
                    if any(x -> x == new_cuts, tabu_cuts) && any(x -> x == new_perm, tabu_perm)
                        continue
                    end

                    cost, _ = makespan(p, new_cuts, new_perm)
                    if cost < best_neighbor_cost
                        best_neighbor = (copy(new_cuts), copy(new_perm))
                        best_neighbor_cost = cost
                    end
                end
            end
        end

        # Atualiza solução
        if best_neighbor !== nothing
            cuts, perm = best_neighbor
            if best_neighbor_cost < best_cost
                best_cuts = copy(cuts)
                best_perm = copy(perm)
                best_cost = best_neighbor_cost
            end

            push!(tabu_cuts, copy(cuts))
            push!(tabu_perm, copy(perm))

            if length(tabu_cuts) > tabu_tenure
                popfirst!(tabu_cuts)
                popfirst!(tabu_perm)
            end
        else
            # Não encontrou vizinho melhor, para
            break
        end
    end

    return best_cost, best_cuts, best_perm
end

# main
if abspath(PROGRAM_FILE) == @__FILE__
    #nome arquivo de entrada
    arq = "tba10.txt"
    println("Lendo arquivo de entrada " * arq )
    p = readArq(arq)

    println("Executando busca tabu ...")
    #best_cost, best_cuts, best_perm = tabu_search(p)

    # println("\n===== RESULTADOS =====")
    # println("Melhor makespan encontrado: ", best_cost)
    # println("Melhores cortes (índices das tarefas): ", best_cuts)
    # println("Permutação dos operadores: ", best_perm)

    local minimal = Inf
    best_cuts = []
    best_perm = []
    for i in 1:10
      best_cost, best_cuts, best_perm = tabu_search(p)
      println(arq," ID: ",i," value: ",best_cost)
      if best_cost < minimal
        minimal = best_cost
      end
    end

    println("Menor custo: ", minimal)


end
