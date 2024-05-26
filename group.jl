#in this version agents are put in groups
#speed of breeding depends on how long to be put in a fit group

using Random
using Distributions

mutable struct Group
    members::Vector{Vector{Bool}}
    n::Int
    fit::Bool
    t::Int #time the Group becomes fit
end

function makeGroup(members::Vector{Vector{Bool}},t,tN)
    group=Group(members,length(members[1]),false,tN+1)
    group.fit=checkFit(group)
    if group.fit
        group.t=t
    end
    group
end

function makeGroup(n,groupN)
    members=[makeAgent(n) for _ in 1:groupN]
    makeGroup(members)
end


function makeGroup(n,groupN,p)
    members=[makeAgent(n,p) for _ in 1:groupN]
    makeGroup(members)
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

function checkFit(group::Group)
    reduce((x,y) -> x & y, reduce((x, y) -> x .| y, group.members))
end

function selectGroup(groups::Vector{Group}, lamb::Float64)

    p = ones(Float64, length(groups))
    for i in 1:length(groups)
        if groups[i].fit
            p[i] *= lamb
        end
    end
    
    total = sum(p)
    p /= total
    
    dist = Categorical(p)
    
    selected_index = rand(dist)
    
    return groups[selected_index]
end


function selectAgent(groups::Vector{Group}, p::Vector{Float64})
    
    total = sum(p)
    p /= total
    
    dist = Categorical(p)
    
    selected_index = rand(dist)
    
    return rand(groups[selected_index])
end



function groupP(groups::Vector{Group}, value::Function)
    p=Vector{Float64}(undef,length(groups))

    for i in 1:length(groups)
        p[i]=value(groups[i].g)
    end

    return p
end

    
function breedGroup(group::Group,mutation::Real)
    members=Vector{Vector{Bool}}()

    for _ in 1:length(group.members)
        p1=rand(1:length(group.members))
        p2=p1
        while p1==p2
            p2=rand(1:length(group.members))
        end
        push!(members,breed(group.members[p1],group.members[p2],mutation))
    end

    makeGroup(members)
end

function success(groups::Vector{Group})
    totalTrues = 0
    totalAgents = 0
    
    for group in groups
        for member in group.members
            totalTrues += count(x-> x==true, member)
            totalAgents += 1
        end
    end
    
    return totalTrues / totalAgents
end

n=20
lamb=5.0
mutation=0.00

e1=4
e2=10-e1

groupN=2^e1
worldN=2^e2

gN=40
tN=20

pOn=0.25

value(t)=tN+2-t

agents=[makeAgent(n,pOn) for _ in 1:2^{e1+e2)]

world=Vector{Group}()

for i in 1:worldN
    push!(world,makeGroup(agents[i*groupN:(1+1)*groupN-1],1))
end

println(success(world))

for g in 1:gN
    global world
    for t in 1:tN
        agents=Vector{Agent}()
        newWorld=Vector{Group}()
        for w in 1:length(world)
            if !world[w].fit
                append!(agents,world[w].members)
            else
                push!(newWorld,world[w])
            end
        end
        
        shuffle!(agents)
        newWorldN=length(agents)/groupN
        
        for i in 1:newWorldN
            push!(newWorld,makeGroup(agents[i*groupN:(1+1)*groupN-1],t,tN))
        end

        world=copy(newWorld)

        println(success(world))
        
    end

    pSelect=groupP(groups,value)

    agents=Vector{Agents}(undef,worldN*groupN)
    
    for a in 1:worldN*groupN
        selectAgent(groups,pSelect)
        agent[a]=breed(selectAgent(groups,pSelect),selectAgent(groups,pSelect))
    end


    for i in 1:worldN
        push!(world,makeGroup(agents[i*groupN:(1+1)*groupN-1],1))
    end
    

end


    




