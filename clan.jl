#in this version members in clans, fit clans breed among themselves

using Random
using Distributions

mutable struct Clan
    members::Vector{Vector{Bool}}
    n::Int
    fit::Bool
end

function makeClan(members::Vector{Vector{Bool}})
    clan=Clan(members,length(members[1]),false)
    clan.fit=checkFit(clan)
    clan
end

function makeClan(n,clanN)
    members=[makeAgent(n) for _ in 1:clanN]
    makeClan(members)
end


function makeClan(n,clanN,p)
    members=[makeAgent(n,p) for _ in 1:clanN]
    makeClan(members)
end


function makeAgent(n::Int)
    rand(Bool,n)
end

function makeAgent(n::Int,p::Real)
    bernoulli_dist = Bernoulli(p)
    rand(bernoulli_dist, n)
end

function breed(agent1::Vector{Bool},agent2::Vector{Bool},mutation::Real)
    n = length(agent1)
    @assert length(agent2) == n "Vectors must be of the same length"
    
    splicePoint = rand(0:n)
    
    gene = vcat(agent1[1:splicePoint], agent2[splicePoint+1:end])

    for i in 1:length(gene)
        if rand()<mutation
            gene[i]=!gene[i]
        end
    end

    gene
    
end

function checkFit(clan::Clan)
    reduce((x,y) -> x & y, reduce((x, y) -> x .| y, clan.members))
end

function selectClan(clans::Vector{Clan}, lamb::Float64)

    p = ones(Float64, length(clans))
    for i in 1:length(clans)
        if clans[i].fit
            p[i] *= lamb
        end
    end
    
    total = sum(p)
    p /= total
    
    dist = Categorical(p)
    
    selected_index = rand(dist)
    
    return clans[selected_index]
end

function breedClan(clan::Clan,mutation::Real)
    members=Vector{Vector{Bool}}()

    for _ in 1:length(clan.members)
        p1=rand(1:length(clan.members))
        p2=p1
        while p1==p2
            p2=rand(1:length(clan.members))
        end
        push!(members,breed(clan.members[p1],clan.members[p2],mutation))
    end

    makeClan(members)
end

function success(clans::Vector{Clan})
    totalTrues = 0
    totalAgents = 0
    
    for clan in clans
        for member in clan.members
            totalTrues += count(x-> x==true, member)
            totalAgents += 1
        end
    end
    
    return totalTrues / totalAgents
end

function successClan(clans::Vector{Clan})
    totalTrues = 0
    totalClans = 0
    
    for clan in clans
        if clan.fit
            totalTrues += 1
        end
        totalClans += 1
    end
    
    return totalTrues / totalClans
end

n=20
lamb=5.0
mutation=0.00

e1=4
e2=10-e1

clanN=2^e1
worldN=2^e2

g=40

p=0.25

world=[makeClan(n,clanN,p) for _ in 1:worldN]

println(success(world)," ",successClan(world))

for _ in 1:g
    for i in 1:length(world)
        clan=selectClan(world,lamb)
        world[i]=breedClan(clan,mutation)
    end
    println(success(world)," ",successClan(world))

end



    




